# Troubleshooting and Engineering Decisions

This was the most important practical part of the project. Several failures were not caused by the detection logic itself; they appeared in packet capture, addressing, event volume, Windows execution context and SIEM processing.

| Problem | Diagnosis | Resolution | Lesson |
|---|---|---|---|
| Parrot image contained a `.vmdk` but no `.vmx` | Pre-built disk without VMware configuration | Created a new VM shell and attached the existing disk | Understand the VM artifact format before rebuilding an image |
| ET rules produced `file.magic` and industrial-protocol errors | Some rules/features were unsupported or irrelevant in the Windows build | Accepted non-relevant `file.magic` limitations and removed irrelevant DNP3/ENIP/Modbus rule files | Validate the engine against the rules actually required by the lab |
| Suricata crashed when capturing by Windows adapter name | Windows capture-path instability | Used the endpoint IP (`192.168.226.130`) as the capture interface | Packet-capture configuration can fail independently of rule correctness |
| Suricata Windows service crashed in SYSTEM context | Service-mode instability (`0xc0000005`) while interactive execution was stable | Replaced service mode with a highest-privilege Task Scheduler startup task | Persistence method is part of operational reliability |
| Wazuh reported `Too many fields for JSON decoder` | Suricata stats events contained a large nested field set | Restricted EVE JSON to `alert` events; disabled stats/flow/http/dns/tls/files/etc. | Collect the telemetry needed for the use case instead of everything available |
| Wazuh agent queue filled during flood tests | Default buffer was too small for Suricata + Sysmon event volume | Increased `queue_size` from 5000 to 20000 and `events_per_second` from 500 to 1000 | Detection load must be considered when sizing collectors |
| DHCP change broke capture/agent paths | Endpoint address changed after configuration | Converted all three core VMs to static addresses | Stable addressing matters in tightly coupled lab integrations |
| Duplicate/invalid Wazuh agent registration | Re-authentication created a hostname-based duplicate | Removed stale entries and re-registered one explicitly named `WIN-SRV25` agent | Keep endpoint identity consistent during troubleshooting |
| XML edits caused Wazuh outages | Missing/truncated tags and command ordering errors | Validated after edits with Wazuh configuration tests and service logs | Syntax validation should be part of every configuration change |
| Built-in `route-null` response could not reliably obtain source IP | Suricata exposed `src_ip`; attempted response path expected a usable `srcip` field | Replaced it with custom PowerShell reading `parameters.alert.data.src_ip` directly | Prefer transparent, auditable response logic when abstraction becomes unreliable |
| Custom block/unblock events were collected but initially not alerting | Windows Application informational events followed the level-0 parent path | Attached `100014/100015` to parent rule `60600` and validated with `wazuh-logtest` | Understand the rule tree, not just individual match fields |
| Alert mail stopped during repeated testing | Notification/mail limits were reached | Increased the relevant test limits and verified queue/mailbox state | Rate limits are expected controls; distinguish them from detection failures |

## Key takeaway

The completed lab reinforced a SOC engineering principle: a detection is useful only when the entire telemetry and response path is reliable. Packet capture, log volume, transport buffering, rule parsing, endpoint execution and notification controls all influence whether a technically correct rule produces an operationally useful outcome.
