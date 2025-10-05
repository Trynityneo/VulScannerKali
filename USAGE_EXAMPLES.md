# Usage Examples

Comprehensive examples for using the Kali Port & Vulnerability Scanner in various scenarios.

## Table of Contents

- [Basic Scans](#basic-scans)
- [Advanced Scans](#advanced-scans)
- [Target Specification](#target-specification)
- [Output Control](#output-control)
- [Performance Tuning](#performance-tuning)
- [Vulnerability Discovery](#vulnerability-discovery)
- [Real-World Scenarios](#real-world-scenarios)
- [Automation and Scripting](#automation-and-scripting)

## Basic Scans

### Quick Scan of Single Host

```bash
# Scan common ports on a single host
./kali-port-vuln-scanner.sh --target 192.168.1.10

# Fast scan (less accurate but quicker)
./kali-port-vuln-scanner.sh --target 192.168.1.10 --fast

# Scan specific ports
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 22,80,443
```

### Scan with Verbose Output

```bash
# Enable verbose mode for debugging
./kali-port-vuln-scanner.sh --target 192.168.1.10 --verbose
```

### Local-Only Scan (No Internet)

```bash
# Skip online vulnerability queries
./kali-port-vuln-scanner.sh --target 192.168.1.10 --no-online
```

## Advanced Scans

### Full Port Scan

```bash
# Scan all 65535 ports
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 1-65535

# Full scan with fast mode
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 1-65535 --fast
```

### Scan with Vulners API

```bash
# Use Vulners API for enhanced CVE data
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --use-vulners-api "YOUR_API_KEY"

# Using environment variable
export VULNERS_API_KEY="your_key_here"
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --use-vulners-api "$VULNERS_API_KEY"
```

### Custom Port Ranges

```bash
# Web services only
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 80,443,8080,8443

# Database ports
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 3306,5432,1433,27017

# Common services
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 21,22,23,25,80,443,3389

# Port range
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 1-1024
```

## Target Specification

### Single IP Address

```bash
./kali-port-vuln-scanner.sh --target 192.168.1.10
```

### Hostname

```bash
./kali-port-vuln-scanner.sh --target web-server.example.com
```

### CIDR Range

```bash
# Scan entire subnet
./kali-port-vuln-scanner.sh --target 192.168.1.0/24

# Smaller range
./kali-port-vuln-scanner.sh --target 10.0.0.0/28
```

### Multiple Targets from File

```bash
# Create targets file
cat > targets.txt << EOF
192.168.1.10
192.168.1.20
web-server.example.com
10.0.0.0/24
EOF

# Scan all targets
./kali-port-vuln-scanner.sh --target targets.txt
```

### Localhost Scanning

```bash
# Scan local machine
./kali-port-vuln-scanner.sh --target 127.0.0.1
./kali-port-vuln-scanner.sh --target localhost
```

## Output Control

### JSON Output Only

```bash
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --format json
```

### HTML Output Only

```bash
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --format html
```

### All Formats (Default)

```bash
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --format all
```

### Custom Output Directory

```bash
# Specify output directory
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --output-dir /home/user/scans/production

# Organized by date
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --output-dir ~/scans/$(date +%Y-%m-%d)

# Organized by target
TARGET="192.168.1.10"
./kali-port-vuln-scanner.sh \
  --target "$TARGET" \
  --output-dir ~/scans/${TARGET}_$(date +%Y%m%d)
```

## Performance Tuning

### Fast Scanning

```bash
# Use fast mode
./kali-port-vuln-scanner.sh --target 192.168.1.0/24 --fast

# Increase threads for online queries
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --threads 20

# Combine fast mode with limited ports
./kali-port-vuln-scanner.sh \
  --target 192.168.1.0/24 \
  --fast \
  --ports 22,80,443
```

### Slow/Stealthy Scanning

```bash
# Reduce threads for slower, more polite scanning
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --threads 1

# Scan only common ports
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --ports common
```

## Vulnerability Discovery

### Maximum Vulnerability Detection

```bash
# Full scan with all vulnerability sources
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --ports 1-65535 \
  --use-vulners-api "$VULNERS_API_KEY" \
  --threads 10 \
  --verbose
```

### Local Vulnerability Scanning Only

```bash
# Use only nmap scripts and searchsploit
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --no-online
```

### Focus on Specific Services

```bash
# Web server vulnerabilities
./kali-port-vuln-scanner.sh \
  --target web-server.example.com \
  --ports 80,443,8080,8443

# Database vulnerabilities
./kali-port-vuln-scanner.sh \
  --target db-server.example.com \
  --ports 3306,5432,1433,27017,6379

# SSH vulnerabilities
./kali-port-vuln-scanner.sh \
  --target 192.168.1.10 \
  --ports 22
```

## Real-World Scenarios

### Scenario 1: Web Application Assessment

```bash
# Comprehensive web app scan
./kali-port-vuln-scanner.sh \
  --target webapp.example.com \
  --ports 80,443,8080,8443,3000,5000,8000 \
  --use-vulners-api "$VULNERS_API_KEY" \
  --output-dir ~/assessments/webapp_$(date +%Y%m%d) \
  --format all \
  --verbose
```

### Scenario 2: Internal Network Audit

```bash
# Scan internal network
./kali-port-vuln-scanner.sh \
  --target 10.0.0.0/24 \
  --ports 1-1024 \
  --threads 15 \
  --output-dir ~/audits/internal_network_$(date +%Y%m%d) \
  --format all
```

### Scenario 3: Server Hardening Check

```bash
# Check specific server for vulnerabilities
./kali-port-vuln-scanner.sh \
  --target production-server.example.com \
  --ports 22,80,443,3306 \
  --use-vulners-api "$VULNERS_API_KEY" \
  --output-dir ~/hardening/production_$(date +%Y%m%d) \
  --verbose
```

### Scenario 4: Compliance Scanning

```bash
# PCI DSS compliance scan
./kali-port-vuln-scanner.sh \
  --target payment-gateway.example.com \
  --ports 443,8443 \
  --use-vulners-api "$VULNERS_API_KEY" \
  --output-dir ~/compliance/pci_dss_$(date +%Y%m%d) \
  --format all
```

### Scenario 5: Incident Response

```bash
# Quick assessment during incident
./kali-port-vuln-scanner.sh \
  --target compromised-host.example.com \
  --fast \
  --ports 1-65535 \
  --output-dir ~/incident_response/$(date +%Y%m%d_%H%M%S) \
  --verbose
```

### Scenario 6: Continuous Monitoring

```bash
# Regular automated scan
./kali-port-vuln-scanner.sh \
  --target critical-servers.txt \
  --ports common \
  --threads 10 \
  --output-dir /var/scans/$(date +%Y%m%d) \
  --format json
```

## Automation and Scripting

### Cron Job for Regular Scanning

```bash
# Edit crontab
crontab -e

# Add entry for daily scan at 2 AM
0 2 * * * /path/to/kali-port-vuln-scanner.sh --target /path/to/targets.txt --output-dir /var/scans/$(date +\%Y\%m\%d) --no-online 2>&1 | logger -t vuln-scanner
```

### Bash Script Wrapper

```bash
#!/bin/bash
# scan_wrapper.sh - Automated scanning with notifications

SCANNER="/path/to/kali-port-vuln-scanner.sh"
TARGETS="/path/to/targets.txt"
OUTPUT_DIR="/var/scans/$(date +%Y%m%d)"
LOG_FILE="/var/log/vuln-scanner.log"

echo "Starting scan at $(date)" >> "$LOG_FILE"

# Run scanner
if $SCANNER --target "$TARGETS" --output-dir "$OUTPUT_DIR" --format all; then
    echo "Scan completed successfully at $(date)" >> "$LOG_FILE"
    
    # Send notification (example with mail)
    echo "Vulnerability scan completed. Reports: $OUTPUT_DIR" | \
        mail -s "Scan Complete" admin@example.com
else
    echo "Scan failed at $(date)" >> "$LOG_FILE"
    
    # Send alert
    echo "Vulnerability scan FAILED. Check logs." | \
        mail -s "Scan FAILED" admin@example.com
fi
```

### Parallel Scanning of Multiple Targets

```bash
#!/bin/bash
# parallel_scan.sh - Scan multiple targets in parallel

SCANNER="/path/to/kali-port-vuln-scanner.sh"
TARGETS=("192.168.1.10" "192.168.1.20" "192.168.1.30")

for target in "${TARGETS[@]}"; do
    (
        echo "Scanning $target..."
        $SCANNER \
            --target "$target" \
            --output-dir "./scans/${target}_$(date +%Y%m%d)" \
            --format json \
            --no-online
    ) &
done

# Wait for all scans to complete
wait
echo "All scans completed!"
```

### Integration with Other Tools

```bash
#!/bin/bash
# integrated_scan.sh - Combine with other security tools

TARGET="$1"
OUTPUT_DIR="./integrated_scan_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUTPUT_DIR"

# Run vulnerability scanner
echo "[+] Running vulnerability scan..."
./kali-port-vuln-scanner.sh \
    --target "$TARGET" \
    --output-dir "$OUTPUT_DIR/vuln_scan" \
    --format all

# Extract open ports from JSON
OPEN_PORTS=$(jq -r '.services[].port' "$OUTPUT_DIR/vuln_scan/report.json" | tr '\n' ',')

# Run additional tools on discovered ports
echo "[+] Running additional enumeration..."

# Example: Run nikto on web ports
if echo "$OPEN_PORTS" | grep -q "80\|443\|8080"; then
    nikto -h "$TARGET" -output "$OUTPUT_DIR/nikto_results.txt"
fi

# Example: Run enum4linux if SMB is open
if echo "$OPEN_PORTS" | grep -q "445\|139"; then
    enum4linux "$TARGET" > "$OUTPUT_DIR/enum4linux_results.txt"
fi

echo "[+] Integrated scan complete! Results in: $OUTPUT_DIR"
```

### Diff Scanning (Compare with Previous Scan)

```bash
#!/bin/bash
# diff_scan.sh - Compare current scan with previous

TARGET="$1"
CURRENT_SCAN="/tmp/current_scan.json"
PREVIOUS_SCAN="/var/scans/latest/report.json"

# Run current scan
./kali-port-vuln-scanner.sh \
    --target "$TARGET" \
    --output-dir /tmp/current \
    --format json \
    --no-online

cp /tmp/current/report.json "$CURRENT_SCAN"

# Compare if previous scan exists
if [[ -f "$PREVIOUS_SCAN" ]]; then
    echo "=== New Services ==="
    comm -13 \
        <(jq -r '.services[].port' "$PREVIOUS_SCAN" | sort) \
        <(jq -r '.services[].port' "$CURRENT_SCAN" | sort)
    
    echo "=== Removed Services ==="
    comm -23 \
        <(jq -r '.services[].port' "$PREVIOUS_SCAN" | sort) \
        <(jq -r '.services[].port' "$CURRENT_SCAN" | sort)
    
    echo "=== New CVEs ==="
    comm -13 \
        <(jq -r '.services[].cves[].id' "$PREVIOUS_SCAN" | sort | uniq) \
        <(jq -r '.services[].cves[].id' "$CURRENT_SCAN" | sort | uniq)
else
    echo "No previous scan found for comparison"
fi
```

## Tips and Best Practices

### 1. Start Small

```bash
# Test on a single port first
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 80

# Then expand to common ports
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports common

# Finally do full scan if needed
./kali-port-vuln-scanner.sh --target 192.168.1.10 --ports 1-65535
```

### 2. Use Appropriate Timing

```bash
# During business hours (less intrusive)
./kali-port-vuln-scanner.sh --target 192.168.1.10 --threads 1

# During maintenance window (more aggressive)
./kali-port-vuln-scanner.sh --target 192.168.1.10 --fast --threads 20
```

### 3. Organize Output

```bash
# By date and target
./kali-port-vuln-scanner.sh \
    --target "$TARGET" \
    --output-dir ~/scans/$(date +%Y)/$(date +%m)/$(date +%d)/$TARGET
```

### 4. Save Commands

```bash
# Keep a log of scan commands
echo "$(date): ./kali-port-vuln-scanner.sh --target $TARGET --ports $PORTS" >> ~/scan_history.log
```

### 5. Review Results

```bash
# Quick CVE count
jq '.services[].cves | length' report.json | awk '{s+=$1} END {print s}'

# List all CVEs
jq -r '.services[].cves[].id' report.json | sort | uniq

# High severity CVEs only
jq -r '.services[].cves[] | select(.cvss >= 7.0) | .id' report.json
```

## Common Patterns

### Pattern 1: Quick Security Check

```bash
./kali-port-vuln-scanner.sh --target $TARGET --fast --no-online
```

### Pattern 2: Comprehensive Assessment

```bash
./kali-port-vuln-scanner.sh \
    --target $TARGET \
    --ports 1-65535 \
    --use-vulners-api "$API_KEY" \
    --threads 10 \
    --verbose
```

### Pattern 3: Regular Monitoring

```bash
./kali-port-vuln-scanner.sh \
    --target targets.txt \
    --ports common \
    --output-dir /var/scans/$(date +%Y%m%d) \
    --format json
```

### Pattern 4: Offline Environment

```bash
./kali-port-vuln-scanner.sh \
    --target $TARGET \
    --no-online \
    --output-dir ./offline_scan
```

---

**Remember**: Always obtain proper authorization before scanning any systems!

For more information, see [README.md](README.md) and [INSTALL.md](INSTALL.md).
