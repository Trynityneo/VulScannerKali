# Installation Guide

This guide provides detailed installation instructions for the Kali Port & Vulnerability Scanner.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation on Kali Linux](#installation-on-kali-linux)
- [Installation on Other Debian-Based Systems](#installation-on-other-debian-based-systems)
- [Installation on Other Linux Distributions](#installation-on-other-linux-distributions)
- [Post-Installation Setup](#post-installation-setup)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

- **Operating System**: Kali Linux (recommended) or any Linux distribution
- **Architecture**: x86_64 (64-bit)
- **RAM**: Minimum 2GB (4GB+ recommended for large scans)
- **Disk Space**: Minimum 500MB for dependencies
- **Network**: Internet connection for online vulnerability queries (optional)
- **Privileges**: Root/sudo access for port scanning

### Required Skills

- Basic command-line knowledge
- Understanding of networking concepts
- Familiarity with port scanning and security testing

## Installation on Kali Linux

Kali Linux comes with most required tools pre-installed. Follow these steps:

### Step 1: Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### Step 2: Install Required Packages

```bash
sudo apt-get install -y \
    nmap \
    curl \
    jq \
    xmlstarlet \
    exploitdb \
    git
```

### Step 3: Install Optional Packages

```bash
# Install masscan for faster scanning
sudo apt-get install -y masscan

# Install Python and requests library
sudo apt-get install -y python3 python3-pip
pip3 install requests
```

### Step 4: Update Nmap Scripts

```bash
# Update nmap script database
sudo nmap --script-updatedb

# Install vulners NSE script
cd /usr/share/nmap/scripts/
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
sudo nmap --script-updatedb
```

### Step 5: Clone or Download Scanner

```bash
# Option A: Clone from repository (if available)
git clone https://github.com/yourusername/kali-port-vuln-scanner.git
cd kali-port-vuln-scanner

# Option B: Download and extract
# (If you received this as a zip file)
unzip kali-port-vuln-scanner.zip
cd kali-port-vuln-scanner
```

### Step 6: Set Permissions

```bash
# Make scripts executable
chmod +x kali-port-vuln-scanner.sh
chmod +x lib/*.sh
chmod +x lib/*.py
chmod +x tests/*.sh
```

### Step 7: Verify Installation

```bash
./kali-port-vuln-scanner.sh --help
```

## Installation on Other Debian-Based Systems

For Ubuntu, Debian, and other Debian-based distributions:

### Step 1: Add Kali Repositories (Optional)

If you want to use Kali-specific tools:

```bash
# Add Kali repository
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | sudo tee /etc/apt/sources.list.d/kali.list

# Add Kali GPG key
wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add -

# Update package lists
sudo apt-get update
```

### Step 2: Install Dependencies

```bash
sudo apt-get install -y \
    nmap \
    curl \
    jq \
    xmlstarlet \
    git \
    python3 \
    python3-pip

# Install exploitdb (from Kali repo if added)
sudo apt-get install -y exploitdb || echo "exploitdb not available, will skip searchsploit features"

# Install Python dependencies
pip3 install requests
```

### Step 3: Continue with Steps 4-7 from Kali Installation

## Installation on Other Linux Distributions

### Fedora/RHEL/CentOS

```bash
# Install dependencies
sudo dnf install -y nmap curl jq python3 python3-pip git

# Install xmlstarlet
sudo dnf install -y xmlstarlet

# Install Python dependencies
pip3 install requests

# Download and install exploitdb manually
git clone https://github.com/offensive-security/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
```

### Arch Linux

```bash
# Install dependencies
sudo pacman -S nmap curl jq xmlstarlet python python-pip git

# Install exploitdb from AUR
yay -S exploitdb

# Install Python dependencies
pip install requests
```

### openSUSE

```bash
# Install dependencies
sudo zypper install nmap curl jq python3 python3-pip git

# Install xmlstarlet
sudo zypper install xmlstarlet

# Install Python dependencies
pip3 install requests
```

## Post-Installation Setup

### 1. Configure Nmap for Non-Root Users (Optional)

To run nmap without sudo:

```bash
# Set capabilities (be aware of security implications)
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip $(which nmap)
```

**Warning**: This allows any user to run nmap with elevated privileges. Only do this on systems you control.

### 2. Set Up API Keys

#### Vulners API Key

1. Register at [https://vulners.com/](https://vulners.com/)
2. Get your API key from the dashboard
3. Store it securely:

```bash
# Option A: Environment variable
echo 'export VULNERS_API_KEY="your_api_key_here"' >> ~/.bashrc
source ~/.bashrc

# Option B: Secure file
echo "your_api_key_here" > ~/.vulners_api_key
chmod 600 ~/.vulners_api_key
```

### 3. Create Alias (Optional)

```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'alias vuln-scan="/path/to/kali-port-vuln-scanner.sh"' >> ~/.bashrc
source ~/.bashrc

# Now you can use:
vuln-scan --target 192.168.1.10
```

### 4. Set Up Logging Directory

```bash
# Create a dedicated directory for scan reports
mkdir -p ~/security-scans
chmod 700 ~/security-scans

# Use it with the scanner
./kali-port-vuln-scanner.sh --target 192.168.1.10 --output-dir ~/security-scans/$(date +%Y%m%d)
```

## Verification

### 1. Check Dependencies

```bash
# Run dependency check
./kali-port-vuln-scanner.sh --help

# Manual check
command -v nmap && echo "✓ nmap installed"
command -v curl && echo "✓ curl installed"
command -v jq && echo "✓ jq installed"
command -v xmlstarlet && echo "✓ xmlstarlet installed"
command -v searchsploit && echo "✓ searchsploit installed"
```

### 2. Run Test Suite

```bash
cd tests
sudo ./test_local_scan.sh
```

### 3. Test Basic Scan

```bash
# Scan localhost
sudo ./kali-port-vuln-scanner.sh --target 127.0.0.1 --ports 22,80 --no-online
```

## Troubleshooting

### Issue: "nmap: command not found"

**Solution**:
```bash
sudo apt-get install nmap
```

### Issue: "Permission denied" when running nmap

**Solution**:
```bash
# Run with sudo
sudo ./kali-port-vuln-scanner.sh --target 192.168.1.10

# Or set capabilities (see Post-Installation Setup)
```

### Issue: "xmlstarlet: command not found"

**Solution**:
```bash
sudo apt-get install xmlstarlet
```

### Issue: "searchsploit: command not found"

**Solution**:
```bash
# On Kali
sudo apt-get install exploitdb

# On other systems
git clone https://github.com/offensive-security/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
```

### Issue: "vulners.nse not found"

**Solution**:
```bash
cd /usr/share/nmap/scripts/
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
sudo nmap --script-updatedb
```

### Issue: Python module 'requests' not found

**Solution**:
```bash
pip3 install requests
```

### Issue: "Operation not permitted" errors

**Solution**:
- Ensure you're running with sudo
- Check firewall rules
- Verify network connectivity

### Issue: Scans are very slow

**Solutions**:
- Use `--fast` flag for quicker scans
- Reduce port range with `--ports`
- Increase threads with `--threads 10`
- Check network latency

### Issue: No vulnerabilities found

**Possible causes**:
- Services are up-to-date (good!)
- `--no-online` flag is set (only local checks)
- Network issues preventing online queries
- API rate limiting

**Solutions**:
- Remove `--no-online` flag
- Add Vulners API key with `--use-vulners-api`
- Check internet connectivity
- Wait and retry (rate limiting)

## Uninstallation

To remove the scanner:

```bash
# Remove scanner directory
rm -rf /path/to/kali-port-vuln-scanner

# Remove alias (if added)
# Edit ~/.bashrc and remove the alias line

# Optional: Remove dependencies (be careful!)
# sudo apt-get remove nmap curl jq xmlstarlet exploitdb
```

## Getting Help

If you encounter issues not covered here:

1. Check the [README.md](README.md) for usage examples
2. Run with `--verbose` flag for detailed output
3. Check log files in the output directory
4. Review nmap documentation: `man nmap`
5. Open an issue on the project repository

## Next Steps

After installation:

1. Read the [README.md](README.md) for usage examples
2. Review the [examples/](examples/) directory
3. Run the test suite to verify functionality
4. Start with safe targets (your own systems with permission)
5. Always get authorization before scanning

---

**Remember**: Always obtain written permission before scanning any systems you don't own!
