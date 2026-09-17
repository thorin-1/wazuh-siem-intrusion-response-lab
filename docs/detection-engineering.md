# Detection Engineering

## Detection strategy

The lab combines Suricata network signatures with Wazuh correlation and Sysmon endpoint telemetry. Four custom Suricata rules were created to make the test scenarios deterministic and observable. Wazuh then maps the custom signature messages to level-8 rules so they stand above routine low-severity events and meet the configured notification threshold.

## Detection matrix

| Scenario | Suricata SID | Threshold | Wazuh rule | Result |
|---|---:|---|---:|---|
| SYN/Nmap-style scan | `9000001` | 20 SYN packets / 10 s per source | `100010` | Level 8 |
| SSH brute-force pattern | `9000002` | 5 SYN packets to TCP/22 / 60 s per source | `100011` | Level 8 |
| ICMP flood / ping sweep | `9000003` | 30 echo requests / 10 s per source | `100012` | Level 8 |
| SYN flood / DoS | `9000004` | 100 SYN packets / 5 s per source | `100013` | Level 8 + Active Response |

## Response-audit rules

Two additional Wazuh rules provide visibility into the response itself:

- `100014` — Windows Application Event ID `9001`; source IP was blocked by Windows Firewall; level 8.
- `100015` — Windows Application Event ID `9002`; temporary block was removed; level 5.

Both match the custom event provider `Wazuh-Suricata-Response`.

## Why level 8?

Level 8 was used as the portfolio lab's high-confidence custom-detection threshold and aligned with the configured email alert threshold. This kept routine events below the notification threshold while making the four controlled detections immediately visible.

## Layered detection observation

During SSH brute-force validation, Wazuh's native host/log rules also detected authentication activity independently of the Suricata-derived custom rule. This is useful evidence that network telemetry and host telemetry can corroborate the same incident from different sources.

The exact custom rules are in `../configs/suricata/local.rules` and `../configs/wazuh/local_rules.xml`.
