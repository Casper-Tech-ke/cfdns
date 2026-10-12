# Security Policy

## Supported versions

Only the latest version on the `main` branch receives security fixes. Update with:

```bash
curl -fsSL https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main/cfdns -o /usr/local/bin/cfdns && chmod +x /usr/local/bin/cfdns
```

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/Casper-Tech-ke/cfdns/security) of this repository
2. Click **Report a vulnerability**
3. Describe the problem

Please include:

- What the issue is and what an attacker could do with it
- Steps to reproduce it (commands, inputs, your OS)
- The version or commit you tested
- A suggested fix, if you have one

What to expect (best effort, this is a small project):

- An acknowledgment within a few days
- A fix or a clear answer as soon as it can be verified
- Credit in the release notes if you want it

## Scope

**In scope**

- Bugs in `cfdns` or `install.sh` that could expose credentials, change the wrong DNS record, or break the server's Caddy configuration
- Ways to bypass the zone guard or the confirmation prompts
- Command injection through names, values, or flags

**Out of scope**

- Vulnerabilities in Cloudflare, Caddy, `jq`, `curl`, or Debian themselves (report those to their maintainers)
- Problems that need an attacker who already has root on your server
- Misconfiguration on your side, such as sharing your API token

## How `cfdns` protects you

- Your API token and Zone ID are saved only on your server, in `/root/.cfdns.env` with permissions `600`. They are never sent anywhere except the Cloudflare API, and never stored in this repository.
- Names outside your own zone are refused.
- `update` and `delete` show exactly what will change and wait for you to type `yes`.
- If a name matches more than one record, nothing is changed.
- `cfdns site` backs up the Caddyfile, validates the new config before reloading, and rolls back automatically if it is rejected.

## Recommendations for users

- **Use a least-privilege token.** Create it with the **Edit zone DNS** template and limit it to one zone. Do not use your Global API Key.
- **Never commit credentials.** Do not put your token in any repository, issue, or chat.
- **Rotate a leaked token right away** at https://dash.cloudflare.com/profile/api-tokens (roll or delete it), then re-run the installer.
- **Review before you pipe to bash.** To inspect the installer first:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main/install.sh -o install.sh
  less install.sh
  bash install.sh
  ```
- **Keep the server updated:** `apt update && apt upgrade`.
- **Protect your server login:** use SSH keys, and consider disabling password logins.
- **Use Full (strict)** SSL mode in Cloudflare (see the README).

## Removing your credentials

```bash
rm /root/.cfdns.env
```

Then delete the token in the Cloudflare dashboard.

---

Created & maintained by **XSPACE TECH DEVS** | GitHub: [Casper-Tech-ke](https://github.com/Casper-Tech-ke)
