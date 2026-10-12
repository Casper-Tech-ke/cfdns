<div align="center">

<img src="assets/banner.svg" alt="Cloudflare DNS Recorder" width="100%">

<a href="https://github.com/Casper-Tech-ke/cfdns"><img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=20&duration=3000&pause=900&color=36BCF7&center=true&vCenter=true&width=640&lines=Manage+Cloudflare+DNS+from+your+terminal;Add+%C2%B7+Update+%C2%B7+Proxy+%C2%B7+Delete;One-line+install%2C+zero+config+files;Created+by+XSPACE+TECH+DEVS" alt="Typing animation"></a>

<br>

<img src="https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white" alt="bash">
<img src="https://img.shields.io/badge/Cloudflare-DNS-F6821F?logo=cloudflare&logoColor=white" alt="Cloudflare">
<img src="https://img.shields.io/badge/install-one%20line-36bcf7" alt="one-line install">
<img src="https://img.shields.io/badge/by-XSPACE%20TECH%20DEVS-c084fc" alt="XSPACE TECH DEVS">

<br><br>

A small command-line tool to create and manage Cloudflare DNS records from your server's terminal.

<img src="assets/demo.svg" alt="cfdns demo" width="720">

</div>

## Features

- Add, update, list, and delete DNS records (A, AAAA, CNAME, TXT, MX, and more)
- Switch the Cloudflare proxy (orange/grey cloud) with one command
- Short names: `cfdns add api` becomes `api.yourdomain.com`
- Zone guard: refuses any name outside your own domain
- Confirmation prompt before every update and delete
- Ambiguity protection: if a name has several records, it asks you to narrow it down instead of guessing
- One-line install with an interactive setup

## Requirements

- A server running Debian or Ubuntu, with root access
- A domain on Cloudflare
- `curl` and `jq` (the installer sets these up for you)

## Installation

Run this on your server:

```bash
curl -fsSL https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main/install.sh | bash
```

The installer will:

1. Install the dependencies
2. Install the `cfdns` command to `/usr/local/bin`
3. Ask for your Cloudflare **API token** and **Zone ID**, save them, and verify the connection

### Getting your API token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **Create Token** and use the **Edit zone DNS** template
3. Choose your domain under **Zone Resources**
4. Create the token and copy it (it is only shown once)

### Getting your Zone ID

Open your domain in the Cloudflare dashboard. The Zone ID is on the **Overview** page, in the right sidebar under **API**.

Your token and Zone ID are saved only on your server, in `/root/.cfdns.env` (permissions `600`). They are never stored in this repository.

## Usage

```bash
cfdns                 # show the banner and help
cfdns verify          # check the token and zone
cfdns list            # show all records
```

### Commands

| Command | What it does |
|---|---|
| `cfdns verify` | Checks your token and shows the zone name |
| `cfdns list` | Lists all records with type, value, proxy status, and priority |
| `cfdns add NAME [VALUE] [flags]` | Creates a record |
| `cfdns update NAME NEWVALUE [flags]` | Changes a record (asks to confirm) |
| `cfdns proxy NAME [on\|off]` | Shows or switches the proxy |
| `cfdns delete NAME [flags]` | Removes a record (asks to confirm) |

### Flags

| Flag | Meaning |
|---|---|
| `--type T`, `-t T` | Record type (A, AAAA, CNAME, TXT, MX, ...). Default for `add` is `A` |
| `--priority N` | MX priority (defaults to 10 for MX records) |
| `--match TEXT`, `-m TEXT` | Pick one record when a name has several (matches part of its value) |
| `--proxy`, `-p` | Orange cloud (proxied) |
| `--dns-only`, `-d` | Grey cloud (DNS only) |

### Naming

`NAME` can be short (`api`), full (`api.yourdomain.com`), or `@` for the root domain.

## Examples

### A records

```bash
cfdns add myapp                       # points to this server's IP, proxied
cfdns add myapp --dns-only            # grey cloud
cfdns add myapp 1.2.3.4 --proxy       # custom IP
cfdns update myapp 5.6.7.8
```

### CNAME

```bash
cfdns add www yourdomain.com --type CNAME
```

### TXT (quote the value)

```bash
cfdns add @ "v=spf1 include:mailgun.org ~all" --type TXT
cfdns add _dmarc "v=DMARC1; p=none" --type TXT
```

### MX

```bash
cfdns add @ mx.example.com --type MX --priority 10
cfdns add @ mx2.example.com --type MX --priority 20
```

### Proxy

```bash
cfdns proxy myapp          # show current state
cfdns proxy myapp on       # orange cloud
cfdns proxy myapp off      # grey cloud
```

### Changing or removing one of several records

A name like `@` can hold many records at once. Use `--type` and `--match` to say which one you mean:

```bash
cfdns update @ "v=spf1 -all" --type TXT --match spf1
cfdns delete @ --type MX --match mx2
```

If you don't narrow it down, `cfdns` lists the candidates and stops.

## Safety

- **Zone guard:** a name that ends outside your domain (e.g. `test.other.com`) is refused.
- **Confirmation:** `update` and `delete` show exactly what will change and wait for you to type `yes`.
- **No guessing:** if more than one record matches, nothing is changed.
- **Proxy rules:** only A, AAAA, and CNAME records can be proxied. Other types are always DNS only.

## Making a subdomain live (example with Caddy)

DNS only points visitors to your server. To serve an app on `myapp.yourdomain.com`:

1. Create the record:
   ```bash
   cfdns add myapp
   ```
2. Add this to `/etc/caddy/Caddyfile` (replace the port with your app's port):
   ```
   myapp.yourdomain.com {
       reverse_proxy localhost:3001
   }
   ```
3. Reload Caddy:
   ```bash
   systemctl reload caddy
   ```
4. In Cloudflare, set **SSL/TLS** to **Full (strict)**.

Make sure ports 80 and 443 are open in your server firewall.

## Updating

```bash
curl -fsSL https://raw.githubusercontent.com/Casper-Tech-ke/cfdns/main/cfdns -o /usr/local/bin/cfdns && chmod +x /usr/local/bin/cfdns
```

Your saved token and Zone ID are kept.

## Uninstalling

```bash
rm /usr/local/bin/cfdns /root/.cfdns.env
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `Could not read your zone` | Re-run the installer and re-enter a valid token and Zone ID |
| `Refusing: ... is outside your zone` | Use a short name (`api`) or a name ending in your domain |
| `has N matching records` | Add `--type` and/or `--match` to pick one |
| `Failed: Authentication error` | The token is wrong or lacks permission. Create a new one with the Edit zone DNS template |
| `502` after going live | The app is not running on that port. Check `pm2 status` |
| `521` | Cloudflare can't reach your server. Check Caddy and ports 80/443 |
| `525` / `526` | SSL mode mismatch. Use Full (strict) with a valid certificate on the server |

## Limitations

- One zone (domain) per installation
- Records are managed by name, so use `--type` and `--match` when a name has several

<div align="center">

---

Created & maintained by **XSPACE TECH DEVS** | GitHub: [Casper-Tech-ke](https://github.com/Casper-Tech-ke)

</div>
