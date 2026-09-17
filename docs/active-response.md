# Automated Response

## Objective

The response goal was to determine whether a high-confidence network detection could trigger a controlled, temporary containment action on the monitored Windows endpoint.

## Final workflow

1. Suricata SID `9000004` detects the SYN-flood pattern.
2. Wazuh rule `100013` raises the event to level 8.
3. The Wazuh manager invokes the `suricata-block` Active Response on the Windows agent.
4. `suricata-block.cmd` launches the PowerShell implementation.
5. PowerShell reads the JSON message from standard input and extracts `parameters.alert.data.src_ip`.
6. For an `add` action, the script performs Wazuh's stateful `check_keys` handshake.
7. If Wazuh returns `continue`, a Windows Firewall inbound block is created for the source address.
8. The script writes Application Event ID `9001` from provider `Wazuh-Suricata-Response`.
9. Wazuh rule `100014` records the containment action.
10. The manager's 60-second timeout causes a `delete` action.
11. The script removes the firewall rule and writes Event ID `9002`.
12. Wazuh rule `100015` records the recovery action.

## Why a custom response was used

Wazuh's built-in `route-null` path was attempted first. The Suricata JSON field was `src_ip`, while the attempted Active Response path expected a usable dynamic source field (`srcip`). A custom decoder was tested but remained unreliable during the same period that EVE field-volume and agent-connectivity problems were being diagnosed.

The final PowerShell design reads the source address directly from the Active Response JSON. This proved easier to audit and more reliable in this environment.

## Safety controls

- Response is tied only to the SYN-flood custom rule.
- The firewall rule is inbound and source-specific.
- The action is temporary (60 seconds).
- `check_keys` supports Wazuh's stateful response behaviour and duplicate handling.
- Block and unblock actions are written back into the monitoring pipeline.

## Files

- `../scripts/active-response/suricata-block.cmd`
- `../scripts/active-response/suricata-block.ps1`
- `../configs/wazuh/active-response.example.xml`
