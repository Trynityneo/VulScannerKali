# Changelog

All notable changes to the Kali Port & Vulnerability Scanner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-10-05

### Added
- **Progress Indicator** for vulnerability analysis phase
  - Real-time percentage display (0-100%)
  - Shows current service being analyzed (X of Y)
  - Displays port number, service name, product, and version
  - Color-coded output for better visibility
  - Clean completion message when analysis finishes
- Enhanced user experience with live feedback during scans

### Changed
- Vulnerability analysis now shows detailed progress instead of simple log messages
- Improved visual feedback during long-running scans
- Better indication of scan progress for multiple services

### Technical
- Added service counter and percentage calculation
- Implemented dynamic progress display using carriage return
- Optimized output formatting for real-time updates

## [1.0.1] - 2025-10-05

### Fixed
- **Critical Bug:** JSON parsing error during vulnerability analysis
  - Added validation for all JSON results before passing to jq
  - Improved error handling for invalid API responses
  - Added fallback values for malformed data
  - Enhanced service processing with validation checks

### Changed
- Improved robustness when handling API responses
- Better error suppression for cleaner output
- Enhanced logging for invalid JSON data

### Technical
- Added JSON validation in `aggregate_vulnerabilities` function
- Improved service loop with validation checks
- Added error handling for jq operations

## [1.0.0] - 2025-10-05

### Added

#### Core Features
- Initial release of Kali Port & Vulnerability Scanner
- Fast TCP port scanning with nmap integration
- Service version detection and banner grabbing
- Multi-source vulnerability discovery:
  - Local nmap NSE scripts (vulners, vuln)
  - SearchSploit integration for exploit matching
  - Online CVE databases (Vulners API, CVE CIRCL)
- Comprehensive reporting:
  - JSON output (machine-readable)
  - HTML output (human-readable with modern UI)
  - Terminal summary with color-coded output

#### CLI Features
- `--target` - Support for IP, hostname, CIDR, and file input
- `--ports` - Flexible port specification (ranges, lists, "common")
- `--fast` - Fast scan mode for quick assessments
- `--output-dir` - Custom output directory with timestamp
- `--format` - Output format selection (json, html, all)
- `--use-vulners-api` - Vulners API integration
- `--no-online` - Local-only mode (no internet queries)
- `--threads` - Configurable parallelism for online queries
- `--verbose` - Detailed logging for debugging
- `--help` - Comprehensive help documentation

#### Helper Scripts
- `lib/parse_nmap_xml.sh` - XML parsing with multiple fallbacks
- `lib/query_vulners.py` - Python helper for API queries
- `lib/generate_html.sh` - HTML report generation

#### Testing
- `tests/test_local_scan.sh` - Comprehensive integration test suite
- Automated dependency checking
- JSON schema validation
- Service field validation

#### Documentation
- Comprehensive README.md with usage examples
- INSTALL.md with detailed installation instructions
- USAGE_EXAMPLES.md with real-world scenarios
- DOCKER.md for containerized deployment
- LICENSE (MIT)

#### Docker Support
- Dockerfile for reproducible environment
- docker-compose.yml for easy deployment
- Multi-stage build optimization
- Security-hardened container configuration

#### Examples
- Sample targets file
- Example JSON output with realistic data
- Usage patterns and common workflows

### Security Features
- Legal warning banner on startup
- Input validation and sanitization
- Secure temporary file handling
- Signal trap for cleanup
- Safe error handling with proper exit codes
- No credential leakage in output

### Performance Features
- Parallel online queries with configurable threads
- Rate limiting for API politeness
- Fast scan mode for time-sensitive assessments
- Efficient XML parsing with multiple backends

### Quality Features
- Robust error handling with `set -euo pipefail`
- Extensive inline documentation
- Color-coded terminal output
- Verbose logging mode
- Dependency checking with helpful error messages

## [Unreleased]

### Planned Features
- IPv6 support enhancement
- Additional vulnerability sources (NVD direct API)
- Web UI for report viewing (Flask-based)
- Database backend for historical tracking
- Differential scanning (compare with previous scans)
- Export to additional formats (PDF, CSV, Markdown)
- Plugin system for custom vulnerability checks
- Integration with SIEM systems
- Automated remediation suggestions
- Risk scoring and prioritization
- Compliance mapping (PCI DSS, HIPAA, etc.)

### Planned Improvements
- Enhanced banner matching heuristics
- Better false positive filtering
- Improved performance for large networks
- Advanced evasion techniques (optional)
- Machine learning for vulnerability prediction
- GraphQL API for programmatic access

## Version History

### Version Numbering

- **Major version** (X.0.0): Breaking changes, major feature additions
- **Minor version** (1.X.0): New features, backward compatible
- **Patch version** (1.0.X): Bug fixes, minor improvements

### Support Policy

- **Current version (1.0.0)**: Full support, active development
- **Previous major versions**: Security fixes only
- **End of life**: Announced 6 months in advance

## Migration Guides

### Upgrading to 1.0.0

This is the initial release. No migration required.

## Known Issues

### Current Limitations

1. **Root Privileges Required**: SYN scans require sudo/root access
   - **Workaround**: Use TCP connect scans (less stealthy)
   
2. **IPv6 Support**: Limited IPv6 testing
   - **Workaround**: Use IPv4 targets or test thoroughly
   
3. **Windows Support**: Designed for Linux/Kali
   - **Workaround**: Use Docker or WSL2
   
4. **Rate Limiting**: Online APIs have rate limits
   - **Workaround**: Use `--threads 1` or `--no-online`
   
5. **False Positives**: Version-based matching may report non-applicable CVEs
   - **Workaround**: Manual verification of results

### Reported Bugs

None reported yet (initial release).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting features
- Submitting pull requests
- Code style guidelines

## Security Advisories

No security advisories at this time.

To report security vulnerabilities, please email: security@example.com

## Acknowledgments

### Dependencies
- [Nmap](https://nmap.org/) - Network scanning
- [SearchSploit](https://www.exploit-db.com/searchsploit) - Exploit database
- [Vulners](https://vulners.com/) - Vulnerability database
- [CVE CIRCL](https://cve.circl.lu/) - CVE database

### Inspiration
- Nmap NSE scripts
- OpenVAS
- Nessus
- Metasploit Framework

### Contributors
- Security Research Team (Initial development)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This changelog follows the [Keep a Changelog](https://keepachangelog.com/) format.

For detailed usage information, see [README.md](README.md).

For installation instructions, see [INSTALL.md](INSTALL.md).
