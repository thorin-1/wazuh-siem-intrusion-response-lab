# Security and Responsible Use

This repository documents a private, controlled cybersecurity lab. The detection rules and response scripts are intended for defensive learning and authorized testing.

- Do not run scanning, brute-force or traffic-flooding tools against systems without explicit authorization.
- Review and tune thresholds before adapting any automatic blocking logic to a production environment.
- Test Active Response actions in a non-production environment first; false positives can deny legitimate access.
- Never commit Wazuh credentials, API tokens, enrollment secrets, SSH keys, real production addresses, mailbox credentials, packet captures containing sensitive traffic, or VM disk images.

If adapting the PowerShell response, validate the source-IP field and consider allowlists for trusted infrastructure before enabling automated containment.
