#!/usr/bin/env bash
################################################################################
# setup.sh
# 
# Automated setup script for Kali Port & Vulnerability Scanner
# Installs dependencies and configures the environment
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[i] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Banner
print_banner() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║     Kali Port & Vulnerability Scanner - Setup Script             ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. This is OK for system-wide installation."
        return 0
    else
        print_info "Not running as root. Will use sudo for system commands."
        return 1
    fi
}

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        print_info "Detected OS: $OS $VERSION"
        return 0
    else
        print_error "Cannot detect OS"
        return 1
    fi
}

# Install dependencies for Debian/Ubuntu/Kali
install_debian_deps() {
    print_header "Installing Dependencies (Debian/Ubuntu/Kali)"
    
    print_info "Updating package lists..."
    sudo apt-get update
    
    print_info "Installing required packages..."
    sudo apt-get install -y \
        nmap \
        curl \
        jq \
        xmlstarlet \
        exploitdb \
        git \
        python3 \
        python3-pip
    
    print_info "Installing optional packages..."
    sudo apt-get install -y masscan || print_warning "masscan not available"
    
    print_info "Installing Python dependencies..."
    pip3 install --user requests
    
    print_success "Dependencies installed"
}

# Install dependencies for Fedora/RHEL/CentOS
install_fedora_deps() {
    print_header "Installing Dependencies (Fedora/RHEL/CentOS)"
    
    print_info "Installing required packages..."
    sudo dnf install -y \
        nmap \
        curl \
        jq \
        xmlstarlet \
        python3 \
        python3-pip \
        git
    
    print_info "Installing Python dependencies..."
    pip3 install --user requests
    
    print_success "Dependencies installed"
}

# Install dependencies for Arch
install_arch_deps() {
    print_header "Installing Dependencies (Arch Linux)"
    
    print_info "Installing required packages..."
    sudo pacman -S --noconfirm \
        nmap \
        curl \
        jq \
        xmlstarlet \
        python \
        python-pip \
        git
    
    print_info "Installing Python dependencies..."
    pip install --user requests
    
    print_success "Dependencies installed"
}

# Update nmap scripts
update_nmap_scripts() {
    print_header "Updating Nmap Scripts"
    
    print_info "Updating nmap script database..."
    sudo nmap --script-updatedb
    
    print_info "Installing vulners NSE script..."
    local nse_dir="/usr/share/nmap/scripts"
    if [[ -d "$nse_dir" ]]; then
        cd "$nse_dir"
        if [[ ! -f "vulners.nse" ]]; then
            sudo wget -q https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
            sudo nmap --script-updatedb
            print_success "Vulners script installed"
        else
            print_info "Vulners script already installed"
        fi
    else
        print_warning "Nmap scripts directory not found"
    fi
}

# Update searchsploit
update_searchsploit() {
    print_header "Updating SearchSploit Database"
    
    if command -v searchsploit &> /dev/null; then
        print_info "Updating searchsploit database..."
        searchsploit -u || print_warning "Failed to update searchsploit"
        print_success "SearchSploit updated"
    else
        print_warning "SearchSploit not installed"
    fi
}

# Set permissions
set_permissions() {
    print_header "Setting Permissions"
    
    print_info "Making scripts executable..."
    chmod +x "$SCRIPT_DIR/kali-port-vuln-scanner.sh"
    chmod +x "$SCRIPT_DIR/lib/"*.sh
    chmod +x "$SCRIPT_DIR/lib/"*.py
    chmod +x "$SCRIPT_DIR/tests/"*.sh
    
    print_success "Permissions set"
}

# Create directories
create_directories() {
    print_header "Creating Directories"
    
    print_info "Creating reports directory..."
    mkdir -p "$SCRIPT_DIR/reports"
    
    print_success "Directories created"
}

# Run tests
run_tests() {
    print_header "Running Tests"
    
    print_info "Running integration tests..."
    cd "$SCRIPT_DIR/tests"
    if sudo ./test_local_scan.sh; then
        print_success "All tests passed"
        return 0
    else
        print_warning "Some tests failed (this may be expected)"
        return 1
    fi
}

# Create alias
create_alias() {
    print_header "Creating Alias (Optional)"
    
    local shell_rc=""
    if [[ -n "${BASH_VERSION:-}" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        shell_rc="$HOME/.zshrc"
    fi
    
    if [[ -n "$shell_rc" ]]; then
        local alias_line="alias vuln-scan='$SCRIPT_DIR/kali-port-vuln-scanner.sh'"
        
        if ! grep -q "vuln-scan" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# Kali Port & Vulnerability Scanner" >> "$shell_rc"
            echo "$alias_line" >> "$shell_rc"
            print_success "Alias added to $shell_rc"
            print_info "Run 'source $shell_rc' or restart your shell to use 'vuln-scan' command"
        else
            print_info "Alias already exists in $shell_rc"
        fi
    fi
}

# Print summary
print_summary() {
    print_header "Setup Complete!"
    
    echo ""
    print_success "Installation successful!"
    echo ""
    print_info "Quick Start:"
    echo "  1. Run: ./kali-port-vuln-scanner.sh --help"
    echo "  2. Test: sudo ./kali-port-vuln-scanner.sh --target 127.0.0.1 --fast"
    echo "  3. Read: cat README.md"
    echo ""
    print_info "Documentation:"
    echo "  - Quick Start: QUICKSTART.md"
    echo "  - Full Guide:  README.md"
    echo "  - Examples:    USAGE_EXAMPLES.md"
    echo "  - Index:       INDEX.md"
    echo ""
    print_warning "IMPORTANT: Always get written permission before scanning!"
    echo ""
}

# Main setup function
main() {
    print_banner
    
    # Check root
    check_root
    
    # Detect OS
    if ! detect_os; then
        print_error "OS detection failed. Manual installation required."
        exit 1
    fi
    
    # Install dependencies based on OS
    case "$OS" in
        kali|debian|ubuntu)
            install_debian_deps
            ;;
        fedora|rhel|centos)
            install_fedora_deps
            ;;
        arch)
            install_arch_deps
            ;;
        *)
            print_warning "Unsupported OS: $OS"
            print_info "Please install dependencies manually:"
            echo "  - nmap"
            echo "  - curl"
            echo "  - jq"
            echo "  - xmlstarlet"
            echo "  - exploitdb (searchsploit)"
            echo "  - python3 with requests"
            ;;
    esac
    
    # Update tools
    update_nmap_scripts
    update_searchsploit
    
    # Setup project
    set_permissions
    create_directories
    
    # Optional: Create alias
    read -p "Create shell alias 'vuln-scan'? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_alias
    fi
    
    # Optional: Run tests
    echo ""
    read -p "Run integration tests? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests || true
    fi
    
    # Summary
    print_summary
}

# Run main function
main "$@"
