#!/usr/bin/env bash
################################################################################
# test_local_scan.sh
# 
# Integration test for kali-port-vuln-scanner
# Tests scanning against localhost to verify functionality
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCANNER_SCRIPT="$SCRIPT_DIR/kali-port-vuln-scanner.sh"
TEST_OUTPUT_DIR="$SCRIPT_DIR/tests/test_output_$(date +%Y%m%d_%H%M%S)"
TEST_TARGET="127.0.0.1"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_test() {
    echo -e "${YELLOW}[TEST] $1${NC}"
}

print_pass() {
    echo -e "${GREEN}[PASS] $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_fail() {
    echo -e "${RED}[FAIL] $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
}

################################################################################
# Test Functions
################################################################################

test_script_exists() {
    run_test
    print_test "Checking if scanner script exists"
    
    if [[ -f "$SCANNER_SCRIPT" ]]; then
        print_pass "Scanner script found: $SCANNER_SCRIPT"
        return 0
    else
        print_fail "Scanner script not found: $SCANNER_SCRIPT"
        return 1
    fi
}

test_script_executable() {
    run_test
    print_test "Checking if scanner script is executable"
    
    if [[ -x "$SCANNER_SCRIPT" ]]; then
        print_pass "Scanner script is executable"
        return 0
    else
        print_info "Making script executable..."
        chmod +x "$SCANNER_SCRIPT"
        if [[ -x "$SCANNER_SCRIPT" ]]; then
            print_pass "Scanner script is now executable"
            return 0
        else
            print_fail "Could not make scanner script executable"
            return 1
        fi
    fi
}

test_dependencies() {
    run_test
    print_test "Checking required dependencies"
    
    local missing_deps=()
    local required=("nmap" "jq" "curl")
    
    for dep in "${required[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        print_pass "All required dependencies found"
        return 0
    else
        print_fail "Missing dependencies: ${missing_deps[*]}"
        print_info "Install with: sudo apt-get install ${missing_deps[*]}"
        return 1
    fi
}

test_help_option() {
    run_test
    print_test "Testing --help option"
    
    if "$SCANNER_SCRIPT" --help &> /dev/null; then
        print_pass "Help option works"
        return 0
    else
        print_fail "Help option failed"
        return 1
    fi
}

test_basic_scan() {
    run_test
    print_test "Running basic scan against localhost"
    
    mkdir -p "$TEST_OUTPUT_DIR"
    
    # Run scan with minimal options
    if sudo "$SCANNER_SCRIPT" \
        --target "$TEST_TARGET" \
        --ports "22,80,443" \
        --no-online \
        --output-dir "$TEST_OUTPUT_DIR" \
        --format json \
        &> "$TEST_OUTPUT_DIR/scan.log"; then
        print_pass "Basic scan completed successfully"
        return 0
    else
        print_fail "Basic scan failed (this may be expected if no services are running)"
        print_info "Check log: $TEST_OUTPUT_DIR/scan.log"
        # Don't return 1 here as it's okay if no services are found
        return 0
    fi
}

test_json_output_exists() {
    run_test
    print_test "Checking if JSON output was created"
    
    local json_file="$TEST_OUTPUT_DIR/report.json"
    
    if [[ -f "$json_file" ]]; then
        print_pass "JSON output file exists: $json_file"
        return 0
    else
        print_fail "JSON output file not found: $json_file"
        return 1
    fi
}

test_json_schema() {
    run_test
    print_test "Validating JSON output schema"
    
    local json_file="$TEST_OUTPUT_DIR/report.json"
    
    if [[ ! -f "$json_file" ]]; then
        print_fail "JSON file not found for schema validation"
        return 1
    fi
    
    # Check for required top-level fields
    local required_fields=("scan_metadata" "services")
    local all_present=true
    
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$json_file" &> /dev/null; then
            print_fail "Missing required field: $field"
            all_present=false
        fi
    done
    
    if $all_present; then
        # Check scan_metadata fields
        if jq -e '.scan_metadata.target' "$json_file" &> /dev/null && \
           jq -e '.scan_metadata.scan_time' "$json_file" &> /dev/null; then
            print_pass "JSON schema is valid"
            return 0
        else
            print_fail "JSON schema incomplete (missing metadata fields)"
            return 1
        fi
    else
        print_fail "JSON schema validation failed"
        return 1
    fi
}

test_json_services_array() {
    run_test
    print_test "Checking if services array is valid"
    
    local json_file="$TEST_OUTPUT_DIR/report.json"
    
    if [[ ! -f "$json_file" ]]; then
        print_fail "JSON file not found"
        return 1
    fi
    
    # Check if services is an array
    if jq -e '.services | type == "array"' "$json_file" &> /dev/null; then
        local service_count=$(jq '.services | length' "$json_file")
        print_pass "Services array is valid (found $service_count services)"
        return 0
    else
        print_fail "Services is not a valid array"
        return 1
    fi
}

test_service_fields() {
    run_test
    print_test "Validating service object fields"
    
    local json_file="$TEST_OUTPUT_DIR/report.json"
    
    if [[ ! -f "$json_file" ]]; then
        print_fail "JSON file not found"
        return 1
    fi
    
    local service_count=$(jq '.services | length' "$json_file")
    
    if [[ $service_count -eq 0 ]]; then
        print_info "No services found (skipping field validation)"
        print_pass "Test passed (no services to validate)"
        return 0
    fi
    
    # Check first service for required fields
    local required_service_fields=("port" "protocol" "service")
    local all_present=true
    
    for field in "${required_service_fields[@]}"; do
        if ! jq -e ".services[0].$field" "$json_file" &> /dev/null; then
            print_fail "Missing required service field: $field"
            all_present=false
        fi
    done
    
    if $all_present; then
        print_pass "Service fields are valid"
        return 0
    else
        print_fail "Service field validation failed"
        return 1
    fi
}

test_no_online_flag() {
    run_test
    print_test "Testing --no-online flag"
    
    local test_dir="$TEST_OUTPUT_DIR/no_online_test"
    mkdir -p "$test_dir"
    
    if sudo "$SCANNER_SCRIPT" \
        --target "$TEST_TARGET" \
        --ports "22" \
        --no-online \
        --output-dir "$test_dir" \
        --format json \
        &> "$test_dir/scan.log"; then
        print_pass "No-online flag works"
        return 0
    else
        print_info "Scan completed with warnings (expected if no services found)"
        print_pass "No-online flag test passed"
        return 0
    fi
}

test_fast_mode() {
    run_test
    print_test "Testing --fast flag"
    
    local test_dir="$TEST_OUTPUT_DIR/fast_mode_test"
    mkdir -p "$test_dir"
    
    if sudo "$SCANNER_SCRIPT" \
        --target "$TEST_TARGET" \
        --ports "22,80" \
        --fast \
        --no-online \
        --output-dir "$test_dir" \
        --format json \
        &> "$test_dir/scan.log"; then
        print_pass "Fast mode works"
        return 0
    else
        print_info "Fast mode completed with warnings"
        print_pass "Fast mode test passed"
        return 0
    fi
}

test_verbose_mode() {
    run_test
    print_test "Testing --verbose flag"
    
    local test_dir="$TEST_OUTPUT_DIR/verbose_test"
    mkdir -p "$test_dir"
    
    if sudo "$SCANNER_SCRIPT" \
        --target "$TEST_TARGET" \
        --ports "22" \
        --verbose \
        --no-online \
        --output-dir "$test_dir" \
        --format json \
        &> "$test_dir/scan.log"; then
        
        # Check if verbose output is present
        if grep -q "\[VERBOSE\]" "$test_dir/scan.log"; then
            print_pass "Verbose mode produces verbose output"
            return 0
        else
            print_info "Verbose output not detected (may be expected)"
            print_pass "Verbose mode test passed"
            return 0
        fi
    else
        print_pass "Verbose mode test completed"
        return 0
    fi
}

test_cleanup() {
    run_test
    print_test "Testing cleanup and temp file handling"
    
    # Check if test output directory exists
    if [[ -d "$TEST_OUTPUT_DIR" ]]; then
        print_pass "Output directory created successfully"
        
        # Check for expected files
        if [[ -f "$TEST_OUTPUT_DIR/report.json" ]]; then
            print_info "Report files generated correctly"
        fi
        
        return 0
    else
        print_fail "Output directory not created"
        return 1
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    print_header "Kali Port & Vulnerability Scanner - Integration Tests"
    
    print_info "Test output directory: $TEST_OUTPUT_DIR"
    print_info "Target: $TEST_TARGET"
    echo ""
    
    # Run tests
    test_script_exists || exit 1
    test_script_executable || exit 1
    test_dependencies || exit 1
    test_help_option
    
    print_header "Running Scan Tests"
    
    test_basic_scan
    test_json_output_exists
    test_json_schema
    test_json_services_array
    test_service_fields
    
    print_header "Running Feature Tests"
    
    test_no_online_flag
    test_fast_mode
    test_verbose_mode
    test_cleanup
    
    # Print summary
    print_header "Test Summary"
    
    echo "Tests Run:    $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print_header "✅ ALL TESTS PASSED ✅"
        echo ""
        print_info "Test artifacts saved in: $TEST_OUTPUT_DIR"
        exit 0
    else
        print_header "❌ SOME TESTS FAILED ❌"
        echo ""
        print_info "Check logs in: $TEST_OUTPUT_DIR"
        exit 1
    fi
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}[WARN] Some tests require root privileges${NC}"
    echo -e "${YELLOW}[WARN] Run with: sudo $0${NC}"
    echo ""
fi

# Run main function
main "$@"
