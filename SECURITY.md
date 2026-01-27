# Security Policy

## Supported Versions
We provide security updates for actively maintained services in the DEAF-FIRST Platform:

| Service     | Supported | Notes                          |
|-------------|-----------|--------------------------------|
| DeafAUTH    | ✅        | Identity and authentication    |
| PinkSync    | ✅        | 1 Layer Accessibility Control |
| Fibonrose   | ✅        | Trust metrics and AI workflows |
| Pinkflow    | ✅        | AI & Accessibility pipelines |
| VR4deaf     | ✅        | VR pathways and immersive apps |

Older versions or archived builds are not supported.

---

## Reporting a Vulnerability
We take security seriously. If you discover a vulnerability:

1. **Do not open a public issue.**
2. Email the security steward team at: `security@yourdomain.org`
3. Include:
   - A clear description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested mitigation (if known)

We will acknowledge receipt within **24 hours** and provide updates within **7 days**.

---

## Development Practices
- All code must pass linting, tests, and security scans before merging.
- Secrets are stored in `.env` files or vaults — never committed.
- Dependencies are pinned (`deno.lock`, `package-lock.json`) and audited regularly.
- Role-based access enforced across all services, with DeafAUTH as the identity backbone.

---

## Data Protection
- Each service uses its own Postgres schema (`deafauth`, `pinksync`, `fibonrose`, etc.).
- Sensitive data is encrypted at rest and in transit (TLS, AES).
- Logs exclude secrets and personally identifiable information (PII).

---

## Incident Response
- Vulnerabilities reported via email or GitHub Security tab.
- Critical issues addressed within **24 hours**.
- Non-critical issues addressed within **7 days**.
- All incidents documented in the repository.

---

## Compliance & Accessibility
- WCAG 2.1 AAA accessibility standards are enforced across all apps.
- GDPR/CCPA compliance is maintained for user data.
- Quarterly audits ensure compliance and accessibility.

---

## Continuous Improvement
- This policy is reviewed quarterly.
- New projects must adopt this policy before deployment.
- Contributors are encouraged to propose improvements via pull requests.

---

## Contact
For security concerns, contact:  
**Security Steward Team**  
Email: `security@360magicians.com`
