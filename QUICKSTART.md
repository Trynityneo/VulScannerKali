# Quick Start Guide

Get up and running with the Kali Port & Vulnerability Scanner in 5 minutes.

## 1. Installation (2 minutes)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y nmap curl jq xmlstarlet exploitdb

# Make script executable
chmod +x kali-port-vuln-scanner.sh
chmod +x lib/*.sh lib/*.py tests/*.sh
```

## 2. Verify Installation (30 seconds)

```bash
# Check dependencies
./kali-port-vuln-scanner.sh --help

# Should display help message
```

## 3. Run Your First Scan (2 minutes)

### Option A: Scan Localhost (Safe)

```bash
# Quick scan of your local machine
sudo ./kali-port-vuln-scanner.sh --target 127.0.0.1 --fast --no-online
```

### Option B: Scan a Target (With Permission!)

```bash
# Replace with your authorized target
sudo ./kali-port-vuln-scanner.sh --target 192.168.1.10 --fast
```

## 4. View Results (30 seconds)

```bash
# Results are in ./reports/TIMESTAMP/

# View JSON report
cat reports/*/report.json | jq '.'

# Open HTML report in browser
firefox reports/*/report.html
```

## Common Commands

### Quick Scan
```bash
sudo ./kali-port-vuln-scanner.sh --target TARGET --fast
```

### Full Scan
```bash
sudo ./kali-port-vuln-scanner.sh --target TARGET --ports 1-65535
```

### Local-Only (No Internet)
```bash
sudo ./kali-port-vuln-scanner.sh --target TARGET --no-online
```

### With Vulners API
```bash
sudo ./kali-port-vuln-scanner.sh --target TARGET --use-vulners-api "YOUR_KEY"
```

### Multiple Targets
```bash
# Create targets file
echo "192.168.1.10" > targets.txt
echo "192.168.1.20" >> targets.txt

# Scan all targets
sudo ./kali-port-vuln-scanner.sh --target targets.txt
```

## Troubleshooting

### "Permission denied"
```bash
# Run with sudo
sudo ./kali-port-vuln-scanner.sh --target TARGET
```

### "Command not found: nmap"
```bash
sudo apt-get install nmap
```

### "No open ports found"
```bash
# Target may be down or firewalled
# Try with verbose mode
sudo ./kali-port-vuln-scanner.sh --target TARGET --verbose
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) for real-world scenarios
- Check [INSTALL.md](INSTALL.md) for advanced setup
- Run tests: `cd tests && sudo ./test_local_scan.sh`

## ⚠️ Legal Reminder

**ALWAYS GET WRITTEN PERMISSION BEFORE SCANNING!**

Unauthorized scanning is illegal. Only scan systems you own or have explicit authorization to test.

---

**Happy (Authorized) Scanning!** 🔍
