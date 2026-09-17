# Architecture

## Design goal

The lab separates attack simulation, endpoint monitoring and centralized analysis into three virtual machines. This makes the telemetry path visible and allows each stage of the detection pipeline to be validated independently.

## Components

### Ubuntu Server 24.04 — `192.168.226.129`

The Ubuntu VM is the SIEM core. It runs the Wazuh manager, indexer and dashboard, with local Postfix delivery for alert notifications. A local Suricata installation was also present. The VM was allocated 4 vCPU, 8 GB RAM and a 60 GB virtual disk.

### Windows Server 2025 — `192.168.226.130`

The Windows endpoint is the monitored target. It runs the Wazuh agent, Suricata 8.0.6, Npcap and Sysmon using the SwiftOnSecurity configuration. Windows Firewall is also the enforcement point for the custom Active Response. The VM was allocated 2 vCPU, 4 GB RAM and a 60 GB virtual disk.

### Parrot Security OS — `192.168.226.131`

Parrot is the validation host. It generates controlled Nmap, Hydra, ICMP and SYN-flood traffic used to prove that the detections and response chain work. The VM was allocated 2 vCPU and 4 GB RAM.

## Telemetry flow

1. Network traffic reaches the Windows endpoint.
2. Suricata inspects traffic and writes matching alerts to `eve.json`.
3. The Wazuh Windows agent ingests EVE JSON, Windows Application/Security events and the Sysmon Operational channel.
4. The Wazuh manager applies built-in and custom rules.
5. Custom Suricata matches are elevated to level 8 for visibility and notification.
6. For the SYN-flood rule, Wazuh Active Response invokes the Windows-side response script.
7. The script creates a temporary inbound Windows Firewall block and writes an auditable Windows event.
8. Wazuh ingests the response event so the defensive action is visible alongside the attack.
9. After 60 seconds, Wazuh issues the delete action and the script removes the firewall rule.

## Addressing decision

The lab initially used DHCP. A Windows lease change broke Suricata's configured capture path and contributed to agent instability. The three core systems were therefore moved to static addresses on `192.168.226.0/24`.

See `architecture.svg` for the visual data-flow diagram.
