# Kali Port & Vulnerability Scanner

A robust, comprehensive Bash-based tool for Kali Linux that performs fast port scanning, service detection, and automated vulnerability discovery with CVE lookup.

## 🎯 Features

- **Fast Port Scanning**: Leverages nmap with optimized settings for quick discovery
- **Service Version Detection**: Identifies running services, products, and versions
- **Automated Vulnerability Discovery**: 
  - Local nmap NSE scripts (vulners, vuln)
  - SearchSploit integration for exploit matching
  - Online CVE databases (Vulners API, CVE CIRCL)
- **Multiple Output Formats**: JSON (machine-readable) and HTML (human-readable)
- **Flexible Targeting**: Single IP, hostname, CIDR range, or file with multiple targets
- **Rate Limiting**: Configurable threading and politeness for online queries
- **Comprehensive Reporting**: Terminal summary, JSON data, and beautiful HTML reports

## ⚠️ Legal Notice

**THIS TOOL IS FOR AUTHORIZED SECURITY TESTING ONLY**

You **MUST** have explicit written authorization to scan target systems. Unauthorized port scanning and vulnerability assessment is:
- **Illegal** in most jurisdictions
- **Unethical** and violates computer fraud laws
- May result in **criminal prosecution** and civil liability

Always obtain proper authorization before use. The authors assume no liability for misuse of this tool.

## 📋 Requirements

### Required Dependencies

- **nmap** (with NSE scripts) - Port scanning and service detection
- **curl** - HTTP requests for online queries
- **jq** - JSON parsing and manipulation
- **xmlstarlet** or **xmllint** - XML parsing
- **bash** 4.0+ - Shell scripting

### Optional Dependencies

- **searchsploit** (exploitdb package) - Local exploit database queries
- **masscan** - Alternative fast port scanner
- **python3** with **requests** - Enhanced API queries
- **nmap NSE scripts**: vulners.nse, vulscan.nse

### Installation on Kali Linux

```bash
# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y nmap curl jq xmlstarlet exploitdb

# Install optional packages
sudo apt-get install -y masscan python3 python3-pip

# Install Python dependencies (optional)
pip3 install requests

# Update nmap scripts
sudo nmap --script-updatedb

# Clone vulners NSE script (if not present)
cd /usr/share/nmap/scripts/
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
sudo nmap --script-updatedb
```

## 🚀 Quick Start

### Basic Usage

```bash
# Make script executable
chmod +x kali-port-vuln-scanner.sh

# Quick scan of single host
./kali-port-vuln-scanner.sh --target 192.168.1.10 --fast

# Comprehensive scan with all common ports
./kali-port-vuln-scanner.sh --target 10.0.0.5

# Scan specific port range
./kali-port-vuln-scanner.sh --target example.com --ports 80,443,8080
```

### Advanced Usage

```bash
# Scan multiple targets from file
./kali-port-vuln-scanner.sh --target targets.txt --threads 10

# Full port scan (1-65535)
./kali-port-vuln-scanner.sh --target 192.168.1.0/24 --ports 1-65535

# Local-only scan (no internet queries)
./kali-port-vuln-scanner.sh --target 10.0.0.5 --no-online --format json

# Scan with Vulners API key for enhanced CVE data
./kali-port-vuln-scanner.sh --target example.com --use-vulners-api YOUR_API_KEY

# Verbose output with custom output directory
./kali-port-vuln-scanner.sh --target 192.168.1.10 --verbose --output-dir ./my-scan
```

## 📖 Command-Line Options

### Required Arguments

| Option | Description |
|--------|-------------|
| `--target <IP\|host\|file>` | Target IP address, hostname, CIDR range, or file containing targets |

### Optional Arguments

| Option | Default | Description |
|--------|---------|-------------|
| `--ports <range\|common>` | `common` | Port range (e.g., `1-65535`, `80,443`, or `common` for top 1000) |
| `--fast` | disabled | Use faster scan profile (less accurate but quicker) |
| `--output-dir <dir>` | `./reports/TIMESTAMP` | Output directory for reports |
| `--format <json\|html\|all>` | `all` | Output format selection |
| `--use-vulners-api <key>` | none | Vulners API key for enhanced CVE lookup |
| `--no-online` | disabled | Skip online vulnerability queries (local-only mode) |
| `--threads <n>` | `5` | Number of parallel threads for online queries |
| `--verbose` | disabled | Enable verbose output for debugging |
| `--help` | - | Display help message |

## 🔑 API Keys

### Vulners API

To use the Vulners API for enhanced vulnerability data:

1. **Register** at [https://vulners.com/](https://vulners.com/)
2. **Get your API key** from your account dashboard
3. **Use the key** with `--use-vulners-api YOUR_KEY`

Example:
```bash
./kali-port-vuln-scanner.sh --target 192.168.1.10 --use-vulners-api abc123xyz456
```

### CVE CIRCL (No API Key Required)

The tool uses [CVE CIRCL](https://cve.circl.lu/) as a fallback when no Vulners API key is provided. This service is free but has rate limits.

## 📊 Output Structure

### JSON Output

```json
{
  "scan_metadata": {
    "target": "192.168.1.10",
    "scan_time": "2025-10-05T05:43:46Z",
    "scanner_version": "1.0.0"
  },
  "services": [
    {
      "port": 80,
      "protocol": "tcp",
      "service": "http",
      "product": "nginx",
      "version": "1.14.0",
      "extrainfo": "Ubuntu",
      "nmap_vuln_scripts": [
        {
          "id": "vulners",
          "output": "CVE-2019-9511..."
        }
      ],
      "searchsploit_matches": [
        {
          "Title": "nginx 1.14.0 - Denial of Service",
          "Path": "/usr/share/exploitdb/exploits/linux/dos/12345.txt"
        }
      ],
      "cves": [
        {
          "id": "CVE-2019-9511",
          "summary": "HTTP/2 implementation vulnerable to resource loops",
          "cvss": 7.5,
          "published": "2019-08-13",
          "references": ["https://nvd.nist.gov/vuln/detail/CVE-2019-9511"]
        }
      ]
    }
  ]
}
```

### HTML Output

The HTML report includes:
- **Executive Summary**: Visual cards showing vulnerability counts by severity
- **Service Details**: Each discovered service with full information
- **CVE Listings**: All discovered CVEs with CVSS scores and descriptions
- **Exploit Matches**: SearchSploit results with exploit paths
- **Responsive Design**: Works on desktop and mobile devices

### Terminal Output

Real-time progress updates and a comprehensive summary:
```
[INFO] Starting initial port discovery scan...
[SUCCESS] Initial scan completed
[INFO] Running service version detection on ports: 22,80,443
[SUCCESS] Service detection completed
[INFO] Analyzing vulnerabilities for port 80 (http)...
[SUCCESS] Scan completed successfully!

═══════════════════════════════════════════════════════════
                    SCAN SUMMARY                           
═══════════════════════════════════════════════════════════

Target:       192.168.1.10
Scan Time:    2025-10-05T05:43:46Z
Services:     3

Services Discovered:
  Port 22/tcp - ssh [OpenSSH 7.6p1]
  Port 80/tcp - http [nginx 1.14.0]
  Port 443/tcp - ssl/http [nginx 1.14.0]

Vulnerability Summary:
  Port 80 (http):
    - CVEs: 5
    - Exploits: 2

Total CVEs Found: 5
Total Exploits Found: 2
```

## 🧪 Testing

### Integration Test

Run the included integration test against localhost:

```bash
cd tests
chmod +x test_local_scan.sh
./test_local_scan.sh
```

This test will:
1. Scan localhost (127.0.0.1)
2. Verify JSON output schema
3. Check for required fields
4. Validate report generation

### Manual Testing

```bash
# Test against a local service
./kali-port-vuln-scanner.sh --target 127.0.0.1 --ports 22,80 --verbose

# Test with sample targets file
echo "127.0.0.1" > test_targets.txt
echo "localhost" >> test_targets.txt
./kali-port-vuln-scanner.sh --target test_targets.txt --no-online
```

## 🏗️ Project Structure

```
kali-port-vuln-scanner/
├── kali-port-vuln-scanner.sh    # Main scanner script
├── lib/
│   ├── parse_nmap_xml.sh        # XML parsing helper
│   ├── query_vulners.py         # Python API query helper
│   └── generate_html.sh         # HTML report generator
├── tests/
│   └── test_local_scan.sh       # Integration test
├── examples/
│   ├── report.json              # Sample JSON output
│   ├── report.html              # Sample HTML output
│   └── targets.txt              # Sample targets file
└── README.md                    # This file
```

## 🔧 Troubleshooting

### Common Issues

**1. "Permission denied" when running nmap**
```bash
# Run with sudo or add user to sudoers for nmap
sudo ./kali-port-vuln-scanner.sh --target 192.168.1.10
```

**2. "xmlstarlet: command not found"**
```bash
sudo apt-get install xmlstarlet
```

**3. "No open ports found"**
- Verify target is reachable: `ping <target>`
- Check firewall rules
- Try with `--fast` flag disabled for more thorough scanning

**4. "Online queries failing"**
- Check internet connectivity
- Verify API keys are correct
- Use `--no-online` flag for local-only scanning
- Check rate limits (add delays with `--threads 1`)

**5. "vulners.nse not found"**
```bash
cd /usr/share/nmap/scripts/
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
sudo nmap --script-updatedb
```

### Debug Mode

Enable verbose output for troubleshooting:
```bash
./kali-port-vuln-scanner.sh --target 192.168.1.10 --verbose
```

## 🎓 Usage Scenarios

### Scenario 1: Quick Security Assessment

**Goal**: Quickly assess a single server for known vulnerabilities

```bash
./kali-port-vuln-scanner.sh --target web-server.example.com --fast
```

### Scenario 2: Comprehensive Network Audit

**Goal**: Deep scan of entire network with full port range

```bash
./kali-port-vuln-scanner.sh --target 192.168.1.0/24 --ports 1-65535 --threads 20
```

### Scenario 3: Offline Environment Scan

**Goal**: Scan systems in air-gapped network (no internet)

```bash
./kali-port-vuln-scanner.sh --target internal-servers.txt --no-online
```

### Scenario 4: Compliance Reporting

**Goal**: Generate formal reports for compliance audit

```bash
./kali-port-vuln-scanner.sh \
  --target production-servers.txt \
  --format all \
  --output-dir ./compliance-reports/$(date +%Y%m%d) \
  --use-vulners-api YOUR_KEY
```

### Scenario 5: Continuous Monitoring

**Goal**: Regular automated scanning with cron

```bash
# Add to crontab (crontab -e)
0 2 * * * /path/to/kali-port-vuln-scanner.sh --target /path/to/targets.txt --output-dir /var/scans/$(date +\%Y\%m\%d) --no-online
```

## 🔒 Security Best Practices

1. **Authorization**: Always obtain written permission before scanning
2. **Scope**: Define and stick to authorized IP ranges
3. **Timing**: Schedule scans during maintenance windows
4. **Rate Limiting**: Use `--threads` to control scan intensity
5. **Data Protection**: Secure scan reports (contain sensitive information)
6. **Logging**: Keep audit logs of all scanning activities
7. **API Keys**: Store API keys securely (environment variables, not in scripts)

### Secure API Key Usage

```bash
# Store API key in environment variable
export VULNERS_API_KEY="your_api_key_here"

# Use in script
./kali-port-vuln-scanner.sh --target 192.168.1.10 --use-vulners-api "$VULNERS_API_KEY"
```

## 🚧 Limitations

- **Root/Sudo Required**: SYN scans require elevated privileges
- **Network Visibility**: Can only detect services that respond to probes
- **False Positives**: Version-based matching may report non-applicable CVEs
- **Rate Limits**: Online APIs have rate limits (use `--threads` to control)
- **Firewall Evasion**: Does not include advanced evasion techniques
- **IPv6**: Currently optimized for IPv4 (IPv6 support via nmap)

## 🛠️ Advanced Configuration

### Custom Nmap Options

Edit the script to add custom nmap options:

```bash
# In kali-port-vuln-scanner.sh, modify the nmap_opts variable
nmap_opts="-Pn -sS --open -T4 --min-rate 1000 --max-retries 2"
```

### Custom Vulnerability Sources

Add additional vulnerability sources by modifying the `aggregate_vulnerabilities` function:

```bash
# Example: Add custom vulnerability database
custom_vulns=$(query_custom_db "$product" "$version")
```

## 📚 Additional Resources

- [Nmap Documentation](https://nmap.org/book/man.html)
- [Vulners API Documentation](https://vulners.com/docs)
- [CVE CIRCL API](https://cve.circl.lu/api/)
- [SearchSploit Usage](https://www.exploit-db.com/searchsploit)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

## 👥 Authors

Security Research Team

## 🐛 Bug Reports

Report issues with:
- Operating system and version
- Exact command used
- Error messages
- Expected vs actual behavior

## 📝 Changelog

### Version 1.0.0 (2025-10-05)
- Initial release
- Fast port scanning with nmap
- Service version detection
- Local vulnerability scanning (nmap NSE, searchsploit)
- Online CVE lookup (Vulners, CVE CIRCL)
- JSON and HTML report generation
- Multi-threading support
- Comprehensive error handling

---

## ⚠️ Final Reminder

**GET WRITTEN PERMISSION BEFORE SCANNING THIRD-PARTY SYSTEMS**

Unauthorized scanning is illegal. This tool is designed for:
- Authorized penetration testing
- Security audits with permission
- Educational purposes on your own systems
- Compliance assessments with proper authorization

**The authors and contributors are not responsible for misuse of this tool.**

---

**Happy (Authorized) Scanning! 🔍🛡️**
