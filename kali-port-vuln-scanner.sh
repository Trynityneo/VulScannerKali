#!/usr/bin/env bash
################################################################################
# kali-port-vuln-scanner.sh
# 
# A robust port scanning and vulnerability detection tool for Kali Linux
# 
# Author: Security Research Team
# License: MIT
# 
# LEGAL NOTICE:
# This tool is for authorized security testing only. Unauthorized scanning
# of systems you do not own or have explicit written permission to test is
# illegal and unethical. Always obtain proper authorization before use.
################################################################################

set -euo pipefail

# Script metadata
SCRIPT_VERSION="1.0.2"
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration
DEFAULT_PORTS="common"
DEFAULT_OUTPUT_DIR="./reports/$(date +%Y%m%d_%H%M%S)"
DEFAULT_FORMAT="all"
DEFAULT_THREADS=5
VERBOSE=0
FAST_MODE=0
NO_ONLINE=0
VULNERS_API_KEY=""
TARGET=""
PORTS=""
OUTPUT_DIR=""
FORMAT=""
THREADS=""

# Temporary files tracking
declare -a TEMP_FILES=()

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# Utility Functions
################################################################################

# Print colored output
print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

# Logging functions
log_info() {
    print_color "$BLUE" "[INFO] $*"
}

log_success() {
    print_color "$GREEN" "[SUCCESS] $*"
}

log_warn() {
    print_color "$YELLOW" "[WARN] $*"
}

log_error() {
    print_color "$RED" "[ERROR] $*" >&2
}

log_verbose() {
    if [[ $VERBOSE -eq 1 ]]; then
        print_color "$CYAN" "[VERBOSE] $*"
    fi
}

# Print banner
print_banner() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║        Kali Port & Vulnerability Scanner v1.0.0                   ║
║        Advanced Service Detection & CVE Discovery                 ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝

⚠️  LEGAL WARNING ⚠️
This tool performs network scanning and vulnerability assessment.
You MUST have explicit written authorization to scan target systems.
Unauthorized scanning is illegal and may result in criminal prosecution.

EOF
}

# Print usage information
print_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Required:
  --target <IP|host|file>        Target IP, hostname, CIDR, or file with targets

Optional:
  --ports <range|common>         Port range (default: common top 1000)
  --fast                         Use faster scan profile (less accurate)
  --output-dir <dir>             Output directory (default: ./reports/TIMESTAMP)
  --format <json|html|all>       Output format (default: all)
  --use-vulners-api <key>        Vulners API key for enhanced CVE lookup
  --no-online                    Skip online vulnerability queries (local only)
  --threads <n>                  Parallel threads for online queries (default: 5)
  --verbose                      Enable verbose output
  --help                         Show this help message

Examples:
  # Quick scan of single host
  $SCRIPT_NAME --target 192.168.1.10 --fast

  # Comprehensive scan with all ports
  $SCRIPT_NAME --target 10.0.0.5 --ports 1-65535

  # Scan multiple targets from file
  $SCRIPT_NAME --target targets.txt --threads 10

  # Local-only scan (no internet queries)
  $SCRIPT_NAME --target 192.168.1.0/24 --no-online --format json

  # Scan with Vulners API for better CVE data
  $SCRIPT_NAME --target example.com --use-vulners-api YOUR_API_KEY

Exit Codes:
  0 - Success
  1 - General error
  2 - Missing dependencies
  3 - Invalid arguments
  4 - Scan failed

EOF
}

# Cleanup function
cleanup() {
    local exit_code=$?
    log_verbose "Cleaning up temporary files..."
    for temp_file in "${TEMP_FILES[@]}"; do
        if [[ -f "$temp_file" ]]; then
            rm -f "$temp_file"
            log_verbose "Removed: $temp_file"
        fi
    done
    exit $exit_code
}

# Set up signal traps
trap cleanup EXIT INT TERM

################################################################################
# Dependency Checking
################################################################################

check_dependencies() {
    log_info "Checking dependencies..."
    local missing_deps=()
    local optional_missing=()

    # Required dependencies
    local required_deps=("nmap" "curl" "jq")
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        else
            log_verbose "Found: $dep"
        fi
    done

    # Check for XML parsing tools
    if ! command -v xmlstarlet &> /dev/null && ! command -v xmllint &> /dev/null; then
        missing_deps+=("xmlstarlet or xmllint")
    else
        log_verbose "Found XML parser"
    fi

    # Optional dependencies
    if ! command -v searchsploit &> /dev/null; then
        optional_missing+=("searchsploit (exploitdb)")
    else
        log_verbose "Found: searchsploit"
    fi

    if ! command -v masscan &> /dev/null; then
        optional_missing+=("masscan (optional fast scanner)")
    else
        log_verbose "Found: masscan"
    fi

    if ! command -v python3 &> /dev/null; then
        optional_missing+=("python3 (for advanced API queries)")
    else
        log_verbose "Found: python3"
    fi

    # Report missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo "Install on Kali Linux with:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install -y nmap curl jq xmlstarlet exploitdb"
        echo ""
        return 2
    fi

    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        log_warn "Optional dependencies not found (functionality may be limited):"
        for dep in "${optional_missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
    fi

    # Check for nmap NSE scripts
    local nse_dir="/usr/share/nmap/scripts"
    if [[ -d "$nse_dir" ]]; then
        if [[ -f "$nse_dir/vulners.nse" ]]; then
            log_verbose "Found vulners.nse script"
        else
            log_warn "vulners.nse not found. Install with: sudo nmap --script-updatedb"
        fi
    fi

    log_success "Dependency check passed"
    return 0
}

################################################################################
# Argument Parsing
################################################################################

parse_arguments() {
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target)
                TARGET="$2"
                shift 2
                ;;
            --ports)
                PORTS="$2"
                shift 2
                ;;
            --fast)
                FAST_MODE=1
                shift
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --format)
                FORMAT="$2"
                shift 2
                ;;
            --use-vulners-api)
                VULNERS_API_KEY="$2"
                shift 2
                ;;
            --no-online)
                NO_ONLINE=1
                shift
                ;;
            --threads)
                THREADS="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            --help)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 3
                ;;
        esac
    done

    # Set defaults
    [[ -z "$PORTS" ]] && PORTS="$DEFAULT_PORTS"
    [[ -z "$OUTPUT_DIR" ]] && OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    [[ -z "$FORMAT" ]] && FORMAT="$DEFAULT_FORMAT"
    [[ -z "$THREADS" ]] && THREADS="$DEFAULT_THREADS"

    # Validate required arguments
    if [[ -z "$TARGET" ]]; then
        log_error "Missing required argument: --target"
        print_usage
        exit 3
    fi

    # Validate format
    if [[ ! "$FORMAT" =~ ^(json|html|all)$ ]]; then
        log_error "Invalid format: $FORMAT (must be json, html, or all)"
        exit 3
    fi

    # Validate threads
    if ! [[ "$THREADS" =~ ^[0-9]+$ ]] || [[ "$THREADS" -lt 1 ]]; then
        log_error "Invalid threads value: $THREADS (must be positive integer)"
        exit 3
    fi

    log_verbose "Configuration:"
    log_verbose "  Target: $TARGET"
    log_verbose "  Ports: $PORTS"
    log_verbose "  Fast mode: $FAST_MODE"
    log_verbose "  Output dir: $OUTPUT_DIR"
    log_verbose "  Format: $FORMAT"
    log_verbose "  Threads: $THREADS"
    log_verbose "  No online: $NO_ONLINE"
    log_verbose "  Vulners API: $([ -n "$VULNERS_API_KEY" ] && echo "enabled" || echo "disabled")"
}

################################################################################
# Target Validation and Expansion
################################################################################

validate_target() {
    local target="$1"
    
    # Check if target is a file
    if [[ -f "$target" ]]; then
        if [[ ! -r "$target" ]]; then
            log_error "Target file not readable: $target"
            return 1
        fi
        log_info "Target file detected: $target"
        return 0
    fi
    
    # Validate IP, hostname, or CIDR
    # Simple validation - nmap will do the heavy lifting
    if [[ -z "$target" ]]; then
        log_error "Empty target"
        return 1
    fi
    
    log_info "Target: $target"
    return 0
}

################################################################################
# Port Scanning Functions
################################################################################

# Perform initial fast port discovery
run_initial_scan() {
    local target="$1"
    local output_xml="$2"
    
    log_info "Starting initial port discovery scan..."
    
    local nmap_opts="-Pn -sS --open"
    
    if [[ "$PORTS" == "common" ]]; then
        nmap_opts="$nmap_opts --top-ports 1000"
    else
        nmap_opts="$nmap_opts -p $PORTS"
    fi
    
    if [[ $FAST_MODE -eq 1 ]]; then
        nmap_opts="$nmap_opts -T4 --min-rate 1000"
        log_verbose "Fast mode enabled"
    else
        nmap_opts="$nmap_opts -T3"
    fi
    
    log_verbose "Running: nmap $nmap_opts -oX $output_xml $target"
    
    if ! sudo nmap $nmap_opts -oX "$output_xml" "$target" 2>&1 | tee -a "$OUTPUT_DIR/scan.log"; then
        log_error "Initial port scan failed"
        return 4
    fi
    
    log_success "Initial scan completed"
    return 0
}

# Extract open ports from nmap XML
extract_open_ports() {
    local xml_file="$1"
    
    if [[ ! -f "$xml_file" ]]; then
        log_error "XML file not found: $xml_file"
        return 1
    fi
    
    log_verbose "Extracting open ports from XML..."
    
    # Try xmlstarlet first
    if command -v xmlstarlet &> /dev/null; then
        xmlstarlet sel -t -m "//port[state/@state='open']" -v "@portid" -o "," "$xml_file" 2>/dev/null | sed 's/,$//'
    # Fallback to xmllint
    elif command -v xmllint &> /dev/null; then
        xmllint --xpath "//port[state/@state='open']/@portid" "$xml_file" 2>/dev/null | grep -oP 'portid="\K[^"]+' | tr '\n' ',' | sed 's/,$//'
    else
        # Last resort: grep parsing
        grep -oP '<port protocol="tcp" portid="\K[0-9]+' "$xml_file" | tr '\n' ',' | sed 's/,$//'
    fi
}

# Run detailed service version detection
run_service_detection() {
    local target="$1"
    local ports="$2"
    local output_xml="$3"
    
    if [[ -z "$ports" ]]; then
        log_warn "No open ports found, skipping service detection"
        return 0
    fi
    
    log_info "Running service version detection on ports: $ports"
    
    local nmap_opts="-Pn -sV -sC --version-all -p $ports"
    
    log_verbose "Running: nmap $nmap_opts -oX $output_xml $target"
    
    if ! sudo nmap $nmap_opts -oX "$output_xml" "$target" 2>&1 | tee -a "$OUTPUT_DIR/scan.log"; then
        log_error "Service detection scan failed"
        return 4
    fi
    
    log_success "Service detection completed"
    return 0
}

################################################################################
# XML Parsing Functions
################################################################################

# Parse nmap XML and extract service information
parse_nmap_xml() {
    local xml_file="$1"
    local json_output="$2"
    
    log_info "Parsing nmap XML output..."
    
    # Call helper script for XML parsing
    if [[ -f "$SCRIPT_DIR/lib/parse_nmap_xml.sh" ]]; then
        bash "$SCRIPT_DIR/lib/parse_nmap_xml.sh" "$xml_file" "$json_output"
    else
        # Inline parsing if helper not available
        parse_nmap_xml_inline "$xml_file" "$json_output"
    fi
}

# Inline XML parsing (fallback)
parse_nmap_xml_inline() {
    local xml_file="$1"
    local json_output="$2"
    
    log_verbose "Using inline XML parser"
    
    # Extract basic service info using xmlstarlet or xmllint
    if command -v xmlstarlet &> /dev/null; then
        xmlstarlet sel -t \
            -m "//host" \
            -o '{"target":"' -v "address/@addr" -o '",' \
            -o '"services":[' \
            -m "ports/port[state/@state='open']" \
            -o '{' \
            -o '"port":' -v "@portid" -o ',' \
            -o '"protocol":"' -v "@protocol" -o '",' \
            -o '"state":"' -v "state/@state" -o '",' \
            -o '"service":"' -v "service/@name" -o '",' \
            -o '"product":"' -v "service/@product" -o '",' \
            -o '"version":"' -v "service/@version" -o '",' \
            -o '"extrainfo":"' -v "service/@extrainfo" -o '"' \
            -o '},' \
            -b \
            -o ']}' \
            "$xml_file" | sed 's/,]/]/' > "$json_output"
    else
        # Create minimal JSON structure
        echo '{"target":"unknown","services":[]}' > "$json_output"
    fi
}

################################################################################
# Vulnerability Detection Functions
################################################################################

# Run nmap vulnerability scripts on specific port
run_nmap_vuln_scripts() {
    local target="$1"
    local port="$2"
    local output_xml="$3"
    
    log_verbose "Running nmap vulnerability scripts on port $port..."
    
    # Check if vulners script exists
    local scripts="vuln"
    if [[ -f "/usr/share/nmap/scripts/vulners.nse" ]]; then
        scripts="vulners,vuln"
    fi
    
    local nmap_opts="-Pn -sV --script $scripts -p $port"
    
    if sudo nmap $nmap_opts -oX "$output_xml" "$target" &> /dev/null; then
        log_verbose "Vulnerability scripts completed for port $port"
        return 0
    else
        log_verbose "Vulnerability scripts failed for port $port"
        return 1
    fi
}

# Query searchsploit for exploits
query_searchsploit() {
    local product="$1"
    local version="$2"
    
    if ! command -v searchsploit &> /dev/null; then
        log_verbose "searchsploit not available"
        echo "[]"
        return 0
    fi
    
    local query="$product"
    if [[ -n "$version" ]]; then
        query="$product $version"
    fi
    
    log_verbose "Searching exploitdb for: $query"
    
    # Run searchsploit with JSON output
    local result
    result=$(searchsploit "$query" --json 2>/dev/null || echo '{"RESULTS_EXPLOIT":[]}')
    
    # Extract and format results
    echo "$result" | jq -c '.RESULTS_EXPLOIT // []' 2>/dev/null || echo "[]"
}

# Query Vulners API
query_vulners_api() {
    local product="$1"
    local version="$2"
    local api_key="$3"
    
    if [[ -z "$api_key" ]]; then
        echo "[]"
        return 0
    fi
    
    log_verbose "Querying Vulners API for: $product $version"
    
    local query="${product} ${version}"
    local url="https://vulners.com/api/v3/search/lucene/"
    
    local response
    response=$(curl -s -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"$query\",\"apiKey\":\"$api_key\"}" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -c '.data.search // []' 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

# Query CVE CIRCL API
query_cve_circl() {
    local product="$1"
    
    log_verbose "Querying CVE CIRCL for: $product"
    
    local url="https://cve.circl.lu/api/search/${product}"
    
    local response
    response=$(curl -s -L "$url" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -c '.' 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

# Aggregate vulnerability data for a service
aggregate_vulnerabilities() {
    local service_json="$1"
    local target="$2"
    local output_dir="$3"
    
    local port=$(echo "$service_json" | jq -r '.port')
    local service=$(echo "$service_json" | jq -r '.service // "unknown"')
    local product=$(echo "$service_json" | jq -r '.product // ""')
    local version=$(echo "$service_json" | jq -r '.version // ""')
    
    # Progress is now shown in main loop
    log_verbose "Analyzing vulnerabilities for port $port ($service)..."
    
    # Initialize results
    local nmap_vuln_results="[]"
    local searchsploit_results="[]"
    local cve_results="[]"
    
    # Run nmap vulnerability scripts
    local vuln_xml="$output_dir/vuln_${port}.xml"
    if run_nmap_vuln_scripts "$target" "$port" "$vuln_xml"; then
        TEMP_FILES+=("$vuln_xml")
        # Parse vulnerability script output
        if [[ -f "$vuln_xml" ]]; then
            nmap_vuln_results=$(extract_nmap_vulns "$vuln_xml")
        fi
    fi
    
    # Query searchsploit
    if [[ -n "$product" ]]; then
        searchsploit_results=$(query_searchsploit "$product" "$version")
    fi
    
    # Query online sources (if enabled)
    if [[ $NO_ONLINE -eq 0 ]] && [[ -n "$product" ]]; then
        if [[ -n "$VULNERS_API_KEY" ]]; then
            cve_results=$(query_vulners_api "$product" "$version" "$VULNERS_API_KEY")
        else
            cve_results=$(query_cve_circl "$product")
        fi
        
        # Rate limiting
        sleep 0.5
    fi
    
    # Validate JSON results (ensure they're valid JSON arrays)
    nmap_vuln_results=$(echo "$nmap_vuln_results" | jq -c '.' 2>/dev/null || echo '[]')
    searchsploit_results=$(echo "$searchsploit_results" | jq -c '.' 2>/dev/null || echo '[]')
    cve_results=$(echo "$cve_results" | jq -c '.' 2>/dev/null || echo '[]')
    
    # Combine results
    echo "$service_json" | jq -c \
        --argjson nmap_vulns "$nmap_vuln_results" \
        --argjson exploits "$searchsploit_results" \
        --argjson cves "$cve_results" \
        '. + {
            "nmap_vuln_scripts": $nmap_vulns,
            "searchsploit_matches": $exploits,
            "cves": $cves
        }' 2>/dev/null || echo "$service_json"
}

# Extract vulnerability information from nmap XML
extract_nmap_vulns() {
    local xml_file="$1"
    
    if [[ ! -f "$xml_file" ]]; then
        echo "[]"
        return
    fi
    
    # Try to extract script output
    if command -v xmlstarlet &> /dev/null; then
        xmlstarlet sel -t -m "//script" \
            -o '{"id":"' -v "@id" -o '",' \
            -o '"output":"' -v "@output" -o '"},' \
            "$xml_file" 2>/dev/null | sed 's/,$//' | jq -s '.' 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

################################################################################
# Report Generation Functions
################################################################################

# Generate JSON report
generate_json_report() {
    local services_json="$1"
    local output_file="$2"
    local target="$3"
    
    log_info "Generating JSON report..."
    
    local scan_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq -n \
        --arg target "$target" \
        --arg scan_time "$scan_time" \
        --arg version "$SCRIPT_VERSION" \
        --argjson services "$services_json" \
        '{
            "scan_metadata": {
                "target": $target,
                "scan_time": $scan_time,
                "scanner_version": $version
            },
            "services": $services
        }' > "$output_file"
    
    log_success "JSON report saved: $output_file"
}

# Generate HTML report
generate_html_report() {
    local json_file="$1"
    local output_file="$2"
    
    log_info "Generating HTML report..."
    
    if [[ -f "$SCRIPT_DIR/lib/generate_html.sh" ]]; then
        bash "$SCRIPT_DIR/lib/generate_html.sh" "$json_file" "$output_file"
    else
        generate_html_report_inline "$json_file" "$output_file"
    fi
    
    log_success "HTML report saved: $output_file"
}

# Inline HTML generation (fallback)
generate_html_report_inline() {
    local json_file="$1"
    local output_file="$2"
    
    local target=$(jq -r '.scan_metadata.target' "$json_file")
    local scan_time=$(jq -r '.scan_metadata.scan_time' "$json_file")
    local services=$(jq -r '.services' "$json_file")
    
    cat > "$output_file" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vulnerability Scan Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
        }
        .metadata {
            background: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .service {
            border: 1px solid #ddd;
            margin: 20px 0;
            padding: 20px;
            border-radius: 5px;
            background: #fafafa;
        }
        .service-header {
            font-size: 1.2em;
            font-weight: bold;
            color: #2980b9;
            margin-bottom: 10px;
        }
        .vulnerability {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 10px;
            margin: 10px 0;
        }
        .cve-high {
            border-left-color: #dc3545;
            background: #f8d7da;
        }
        .cve-medium {
            border-left-color: #fd7e14;
            background: #fff3cd;
        }
        .cve-low {
            border-left-color: #28a745;
            background: #d4edda;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #3498db;
            color: white;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Port & Vulnerability Scan Report</h1>
        <div class="metadata">
            <p><strong>Target:</strong> <span id="target"></span></p>
            <p><strong>Scan Time:</strong> <span id="scan-time"></span></p>
        </div>
        <div id="services-container"></div>
        <div class="footer">
            <p>Generated by Kali Port & Vulnerability Scanner v1.0.0</p>
            <p>⚠️ This report contains sensitive security information. Handle with care.</p>
        </div>
    </div>
    <script>
        // Load and display JSON data
        const jsonData = JSONDATA;
        document.getElementById('target').textContent = jsonData.scan_metadata.target;
        document.getElementById('scan-time').textContent = jsonData.scan_metadata.scan_time;
        
        const container = document.getElementById('services-container');
        jsonData.services.forEach(service => {
            const serviceDiv = document.createElement('div');
            serviceDiv.className = 'service';
            
            let html = `
                <div class="service-header">
                    Port ${service.port}/${service.protocol} - ${service.service}
                </div>
                <p><strong>Product:</strong> ${service.product || 'Unknown'} ${service.version || ''}</p>
            `;
            
            if (service.cves && service.cves.length > 0) {
                html += '<h3>CVEs Found:</h3>';
                service.cves.forEach(cve => {
                    const severity = cve.cvss > 7 ? 'high' : cve.cvss > 4 ? 'medium' : 'low';
                    html += `
                        <div class="vulnerability cve-${severity}">
                            <strong>${cve.id || 'Unknown CVE'}</strong><br>
                            ${cve.summary || 'No description available'}
                        </div>
                    `;
                });
            }
            
            if (service.searchsploit_matches && service.searchsploit_matches.length > 0) {
                html += `<p><strong>Exploits Found:</strong> ${service.searchsploit_matches.length}</p>`;
            }
            
            serviceDiv.innerHTML = html;
            container.appendChild(serviceDiv);
        });
    </script>
</body>
</html>
HTMLEOF
    
    # Inject JSON data
    local json_data=$(cat "$json_file" | jq -c '.')
    sed -i "s|JSONDATA|${json_data}|g" "$output_file"
}

# Print terminal summary
print_terminal_summary() {
    local json_file="$1"
    
    echo ""
    print_color "$MAGENTA" "═══════════════════════════════════════════════════════════"
    print_color "$MAGENTA" "                    SCAN SUMMARY                           "
    print_color "$MAGENTA" "═══════════════════════════════════════════════════════════"
    echo ""
    
    local target=$(jq -r '.scan_metadata.target' "$json_file")
    local scan_time=$(jq -r '.scan_metadata.scan_time' "$json_file")
    local service_count=$(jq '.services | length' "$json_file")
    
    echo "Target:       $target"
    echo "Scan Time:    $scan_time"
    echo "Services:     $service_count"
    echo ""
    
    print_color "$CYAN" "Services Discovered:"
    echo ""
    
    jq -r '.services[] | "  Port \(.port)/\(.protocol) - \(.service) [\(.product // "unknown") \(.version // "")]"' "$json_file"
    
    echo ""
    print_color "$YELLOW" "Vulnerability Summary:"
    echo ""
    
    local total_cves=0
    local total_exploits=0
    
    while IFS= read -r line; do
        local port=$(echo "$line" | jq -r '.port')
        local service=$(echo "$line" | jq -r '.service')
        local cve_count=$(echo "$line" | jq '.cves | length')
        local exploit_count=$(echo "$line" | jq '.searchsploit_matches | length')
        
        total_cves=$((total_cves + cve_count))
        total_exploits=$((total_exploits + exploit_count))
        
        if [[ $cve_count -gt 0 ]] || [[ $exploit_count -gt 0 ]]; then
            echo "  Port $port ($service):"
            [[ $cve_count -gt 0 ]] && echo "    - CVEs: $cve_count"
            [[ $exploit_count -gt 0 ]] && echo "    - Exploits: $exploit_count"
        fi
    done < <(jq -c '.services[]' "$json_file")
    
    echo ""
    print_color "$GREEN" "Total CVEs Found: $total_cves"
    print_color "$GREEN" "Total Exploits Found: $total_exploits"
    echo ""
    print_color "$MAGENTA" "═══════════════════════════════════════════════════════════"
    echo ""
}

################################################################################
# Main Execution Flow
################################################################################

main() {
    print_banner
    
    # Parse arguments
    parse_arguments "$@"
    
    # Check dependencies
    check_dependencies || exit 2
    
    # Validate target
    validate_target "$TARGET" || exit 3
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    log_success "Output directory: $OUTPUT_DIR"
    
    # Determine actual target (file or direct)
    local scan_target="$TARGET"
    if [[ -f "$TARGET" ]]; then
        scan_target=$(cat "$TARGET" | tr '\n' ' ')
    fi
    
    # Step 1: Initial port scan
    local initial_xml="$OUTPUT_DIR/initial_scan.xml"
    TEMP_FILES+=("$initial_xml")
    run_initial_scan "$scan_target" "$initial_xml" || exit 4
    
    # Step 2: Extract open ports
    local open_ports
    open_ports=$(extract_open_ports "$initial_xml")
    
    if [[ -z "$open_ports" ]]; then
        log_warn "No open ports found on target"
        echo '{"scan_metadata":{"target":"'"$TARGET"'","scan_time":"'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"},"services":[]}' > "$OUTPUT_DIR/report.json"
        log_success "Scan completed (no open ports)"
        exit 0
    fi
    
    log_success "Open ports: $open_ports"
    
    # Step 3: Service version detection
    local service_xml="$OUTPUT_DIR/service_scan.xml"
    TEMP_FILES+=("$service_xml")
    run_service_detection "$scan_target" "$open_ports" "$service_xml" || exit 4
    
    # Step 4: Parse service information
    local services_json="$OUTPUT_DIR/services.json"
    parse_nmap_xml "$service_xml" "$services_json"
    
    # Step 5: Vulnerability analysis
    log_info "Starting vulnerability analysis..."
    local enriched_services="[]"
    
    # Count total services for progress tracking
    local total_services=$(jq '.services | length' "$services_json" 2>/dev/null || echo "0")
    local current_service=0
    
    if [[ $total_services -eq 0 ]]; then
        log_warn "No services found to analyze"
    else
        echo ""
    fi
    
    while IFS= read -r service; do
        if [[ -n "$service" ]] && [[ "$service" != "[]" ]]; then
            current_service=$((current_service + 1))
            local port=$(echo "$service" | jq -r '.port // "unknown"')
            local service_name=$(echo "$service" | jq -r '.service // "unknown"')
            local product=$(echo "$service" | jq -r '.product // ""')
            local version=$(echo "$service" | jq -r '.version // ""')
            
            # Calculate percentage
            local percentage=$((current_service * 100 / total_services))
            
            # Print progress with service info
            printf "\r${BLUE}[%3d%%]${NC} Analyzing service %d/%d: Port ${GREEN}%s${NC} (${CYAN}%s${NC} %s %s)" \
                "$percentage" "$current_service" "$total_services" "$port" "$service_name" "$product" "$version"
            
            local enriched
            enriched=$(aggregate_vulnerabilities "$service" "$scan_target" "$OUTPUT_DIR" 2>/dev/null)
            if [[ -n "$enriched" ]]; then
                # Validate enriched JSON before adding
                if echo "$enriched" | jq -e '.' >/dev/null 2>&1; then
                    enriched_services=$(echo "$enriched_services" | jq --argjson new "$enriched" '. + [$new]' 2>/dev/null || echo "$enriched_services")
                else
                    log_verbose "Skipping invalid service JSON"
                fi
            fi
        fi
    done < <(jq -c '.services[]' "$services_json" 2>/dev/null || echo '')
    
    # Clear progress line and show completion
    if [[ $total_services -gt 0 ]]; then
        printf "\r${GREEN}[100%%]${NC} Vulnerability analysis completed for %d services" "$total_services"
        echo ""
        echo ""
    fi
    
    # Step 6: Generate reports
    local json_report="$OUTPUT_DIR/report.json"
    generate_json_report "$enriched_services" "$json_report" "$TARGET"
    
    if [[ "$FORMAT" == "html" ]] || [[ "$FORMAT" == "all" ]]; then
        local html_report="$OUTPUT_DIR/report.html"
        generate_html_report "$json_report" "$html_report"
    fi
    
    # Step 7: Print summary
    print_terminal_summary "$json_report"
    
    log_success "Scan completed successfully!"
    log_info "Reports saved in: $OUTPUT_DIR"
    
    echo ""
    print_color "$RED" "⚠️  REMINDER: Ensure you have authorization to scan these systems."
    print_color "$RED" "    Unauthorized scanning is illegal and unethical."
    echo ""
}

# Run main function
main "$@"
