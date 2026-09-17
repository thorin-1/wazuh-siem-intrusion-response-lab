# Validation Plan and Results

> Run these tests only in an isolated lab or against systems for which you have explicit authorization.

## Validation principle

Each scenario was checked across multiple stages rather than treating a single alert as proof of success:

**traffic generated → Suricata alert → Wazuh custom rule → dashboard/notification → response (where applicable)**

## Scenario 1 — SYN/Nmap-style scan

**Purpose:** Validate reconnaissance detection.  
**Expected path:** Suricata `9000001` → Wazuh `100010` → level-8 dashboard event and notification.

Example controlled-lab command:

```bash
nmap -Pn -sS 192.168.226.130
```

## Scenario 2 — SSH brute-force pattern

**Purpose:** Validate repeated connection attempts to SSH and compare network/host visibility.  
**Expected path:** Suricata `9000002` → Wazuh `100011`; host-side authentication rules may also fire when applicable.

Example form used in the lab:

```bash
hydra -l testuser -P <lab-wordlist> ssh://<authorized-lab-target>
```

## Scenario 3 — ICMP flood / ping sweep

**Purpose:** Validate threshold-based ICMP detection.  
**Expected path:** Suricata `9000003` → Wazuh `100012` → level-8 event.

```bash
ping -f -c 50 192.168.226.130
```

## Scenario 4 — SYN flood with containment

**Purpose:** Validate detection plus automated containment and recovery.  
**Expected path:** `9000004` → `100013` → firewall block → `100014` → 60-second timeout → unblock → `100015`.

```bash
sudo hping3 -S --flood -p 80 192.168.226.130
```

Stop the generator promptly after the alert is produced.

## Evidence checklist

For a repeat run, capture:

- Suricata `eve.json`/`fast.log` detection.
- Wazuh rule ID and level.
- Wazuh dashboard event.
- Notification email for level-8 detections.
- `Get-NetFirewallRule` output during the SYN-flood block window.
- Active Response audit log (`Command=add`, `check_keys`, `BLOCKED`, `Command=delete`, `UNBLOCKED`).
- Wazuh `100013 → 100014 → 100015` event sequence.

The repository's `screenshots/` directory contains the evidence captured during the completed implementation.
