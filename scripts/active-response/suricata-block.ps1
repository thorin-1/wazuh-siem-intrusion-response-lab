$logFile = "C:\Program Files (x86)\ossec-agent\active-response\suricata-block.log"

function Write-ARLog {
    param([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format s) $Message"
}

try {
    # Read the initial JSON message sent by Wazuh
    $inputJson = [Console]::In.ReadLine()

    if ([string]::IsNullOrWhiteSpace($inputJson)) {
        Write-ARLog "ERROR: No JSON received from Wazuh"
        exit 1
    }

    $event = $inputJson | ConvertFrom-Json
    $command = $event.command
    $srcIp = $event.parameters.alert.data.src_ip

    Write-ARLog "Command=$command SourceIP=$srcIp"

    if ([string]::IsNullOrWhiteSpace($srcIp)) {
        Write-ARLog "ERROR: No Suricata src_ip found"
        exit 1
    }

    $ruleName = "Wazuh-Suricata-Block-$srcIp"

    if ($command -eq "add") {
        # Stateful Active Response handshake with wazuh-execd
        $checkKeys = @{
            version = 1
            origin = @{
                name = "suricata-block"
                module = "active-response"
            }
            command = "check_keys"
            parameters = @{
                keys = @($srcIp)
            }
        } | ConvertTo-Json -Compress -Depth 5

        [Console]::Out.WriteLine($checkKeys)
        [Console]::Out.Flush()
        Write-ARLog "Sent check_keys for SourceIP=$srcIp"

        $responseJson = [Console]::In.ReadLine()

        if ([string]::IsNullOrWhiteSpace($responseJson)) {
            Write-ARLog "ERROR: No check_keys response received"
            exit 1
        }

        $response = $responseJson | ConvertFrom-Json
        Write-ARLog "check_keys response=$($response.command)"

        if ($response.command -eq "abort") {
            Write-ARLog "ABORTED duplicate response for SourceIP=$srcIp"
            exit 0
        }

        if ($response.command -ne "continue") {
            Write-ARLog "ERROR: Unexpected Wazuh response=$($response.command)"
            exit 1
        }

        Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue |
            Remove-NetFirewallRule

        New-NetFirewallRule `
            -DisplayName $ruleName `
            -Direction Inbound `
            -RemoteAddress $srcIp `
            -Action Block `
            -Profile Any `
            -ErrorAction Stop

        Write-ARLog "BLOCKED SourceIP=$srcIp"

        Write-EventLog `
            -LogName Application `
            -Source "Wazuh-Suricata-Response" `
            -EventId 9001 `
            -EntryType Information `
            -Message "WAZUH SURICATA ACTIVE RESPONSE: BLOCKED SourceIP=$srcIp"
    }
    elseif ($command -eq "delete") {
        Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue |
            Remove-NetFirewallRule

        Write-ARLog "UNBLOCKED SourceIP=$srcIp"

        Write-EventLog `
            -LogName Application `
            -Source "Wazuh-Suricata-Response" `
            -EventId 9002 `
            -EntryType Information `
            -Message "WAZUH SURICATA ACTIVE RESPONSE: UNBLOCKED SourceIP=$srcIp"
    }
    else {
        Write-ARLog "ERROR: Invalid command=$command"
        exit 1
    }
}
catch {
    Write-ARLog "ERROR: $($_.Exception.Message)"
    exit 1
}

exit 0
