# CV and GitHub Copy

## Recommended GitHub repository name

`wazuh-siem-intrusion-response-lab`

## GitHub description

Three-VM defensive security lab using Wazuh, Suricata and Sysmon with custom detections, SIEM alerting and PowerShell-driven Windows Firewall Active Response.

## Suggested topics

`wazuh` `suricata` `sysmon` `siem` `soc` `blue-team` `intrusion-detection` `active-response` `powershell` `windows-server` `cybersecurity` `security-lab`

## CV project entry — concise

**Wazuh SIEM Intrusion Detection & Automated Response Lab** — GitHub  
Built a three-VM defensive security lab using Wazuh, Suricata, Sysmon and Windows Server. Integrated network and endpoint telemetry, developed custom detections for reconnaissance, brute-force and DoS activity, and implemented a PowerShell-based Wazuh Active Response that temporarily blocks detected source IPs through Windows Firewall. Validated the full attack → detection → alert → containment → recovery lifecycle in a controlled environment.

## CV bullets — ATS-friendly

- Deployed and configured Wazuh SIEM across Ubuntu Server and Windows Server endpoints; integrated Suricata EVE JSON, Windows Event Logs and Sysmon telemetry.
- Engineered four custom Suricata detections and Wazuh severity rules for network scanning, SSH brute-force patterns, ICMP flooding and SYN-flood activity.
- Developed a stateful PowerShell Wazuh Active Response that extracts the detected source IP, creates a temporary Windows Firewall block, and logs block/unblock events back into the SIEM.
- Troubleshot SIEM ingestion and reliability issues including JSON field limits, event-queue saturation, DHCP/capture instability, Windows service execution and rule-parent matching.

## Interview talking points

1. Why Suricata and Wazuh were used together instead of relying on one telemetry source.
2. Why custom Suricata alerts were reclassified to Wazuh level 8.
3. Why automated blocking was limited to one high-volume scenario and given a timeout.
4. Why the original `route-null` approach failed and how reading `alert.data.src_ip` directly simplified the response.
5. How EVE JSON tuning and Wazuh agent buffering improved reliability under load.
6. How Sysmon provides endpoint context that network IDS telemetry cannot provide by itself.

## One-line LinkedIn/portfolio version

Built a Wazuh + Suricata + Sysmon home SOC lab with custom detection engineering and an auditable PowerShell Active Response that automatically contains and then releases a detected SYN-flood source through Windows Firewall.
