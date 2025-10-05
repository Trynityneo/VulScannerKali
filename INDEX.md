# Kali Port & Vulnerability Scanner - Documentation Index

Complete navigation guide for all project documentation.

## 🚀 Getting Started

**New to the project? Start here:**

1. **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
2. **[INSTALL.md](INSTALL.md)** - Detailed installation instructions
3. **[README.md](README.md)** - Main project documentation

## 📚 Core Documentation

### Essential Reading

| Document | Description | Audience |
|----------|-------------|----------|
| [README.md](README.md) | Main documentation, features, usage | Everyone |
| [QUICKSTART.md](QUICKSTART.md) | Fast setup and first scan | Beginners |
| [INSTALL.md](INSTALL.md) | Installation and dependencies | System administrators |
| [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) | Real-world scenarios and patterns | Security professionals |

### Advanced Topics

| Document | Description | Audience |
|----------|-------------|----------|
| [DOCKER.md](DOCKER.md) | Container deployment guide | DevOps engineers |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines | Developers |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Technical overview and specs | Project managers |

### Reference

| Document | Description | Audience |
|----------|-------------|----------|
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes | Everyone |
| [LICENSE](LICENSE) | MIT license and legal notices | Legal/compliance |

## 🔧 Technical Documentation

### Scripts

| File | Purpose | Lines |
|------|---------|-------|
| `kali-port-vuln-scanner.sh` | Main scanner script | 1,100+ |
| `lib/parse_nmap_xml.sh` | XML parsing helper | 150+ |
| `lib/query_vulners.py` | API query helper | 180+ |
| `lib/generate_html.sh` | HTML report generator | 600+ |
| `tests/test_local_scan.sh` | Integration tests | 400+ |

### Configuration

| File | Purpose |
|------|---------|
| `Dockerfile` | Container build configuration |
| `docker-compose.yml` | Docker Compose setup |
| `.gitignore` | Git exclusions |

## 📖 Documentation by Use Case

### I want to...

#### Install and Set Up
1. Read [QUICKSTART.md](QUICKSTART.md) for fast setup
2. Or [INSTALL.md](INSTALL.md) for detailed installation
3. Check [README.md](README.md) for requirements

#### Run My First Scan
1. Follow [QUICKSTART.md](QUICKSTART.md) - Section 3
2. See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - Basic Scans
3. Check [README.md](README.md) - Quick Start section

#### Learn Advanced Usage
1. Read [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) - All sections
2. Check [README.md](README.md) - Command-Line Options
3. Review examples in `examples/` directory

#### Deploy with Docker
1. Read [DOCKER.md](DOCKER.md) - Complete guide
2. Use `Dockerfile` and `docker-compose.yml`
3. Follow [DOCKER.md](DOCKER.md) - Examples section

#### Contribute to the Project
1. Read [CONTRIBUTING.md](CONTRIBUTING.md) - Guidelines
2. Check [CHANGELOG.md](CHANGELOG.md) - Version history
3. Review [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Architecture

#### Troubleshoot Issues
1. Check [README.md](README.md) - Troubleshooting section
2. See [INSTALL.md](INSTALL.md) - Troubleshooting
3. Review [DOCKER.md](DOCKER.md) - Troubleshooting (for containers)

#### Understand the Project
1. Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Complete overview
2. Check [README.md](README.md) - Features section
3. Review [CHANGELOG.md](CHANGELOG.md) - Development history

## 📁 Directory Structure

```
kali-port-vuln-scanner/
│
├── 📄 Core Scripts
│   ├── kali-port-vuln-scanner.sh    # Main scanner
│   └── lib/                          # Helper scripts
│       ├── parse_nmap_xml.sh
│       ├── query_vulners.py
│       └── generate_html.sh
│
├── 🧪 Testing
│   └── tests/
│       └── test_local_scan.sh        # Integration tests
│
├── 📚 Documentation
│   ├── README.md                     # Main docs
│   ├── QUICKSTART.md                 # Quick start
│   ├── INSTALL.md                    # Installation
│   ├── USAGE_EXAMPLES.md             # Examples
│   ├── DOCKER.md                     # Docker guide
│   ├── CONTRIBUTING.md               # Contribution guide
│   ├── PROJECT_SUMMARY.md            # Project overview
│   ├── CHANGELOG.md                  # Version history
│   ├── LICENSE                       # MIT license
│   └── INDEX.md                      # This file
│
├── 📦 Examples
│   └── examples/
│       ├── targets.txt               # Sample targets
│       └── report.json               # Sample output
│
├── 🐳 Docker
│   ├── Dockerfile                    # Container build
│   └── docker-compose.yml            # Compose config
│
└── ⚙️ Configuration
    └── .gitignore                    # Git exclusions
```

## 🎯 Quick Reference

### Common Commands

```bash
# Quick scan
./kali-port-vuln-scanner.sh --target TARGET --fast

# Full scan
./kali-port-vuln-scanner.sh --target TARGET --ports 1-65535

# With API
./kali-port-vuln-scanner.sh --target TARGET --use-vulners-api "KEY"

# Multiple targets
./kali-port-vuln-scanner.sh --target targets.txt

# Local only
./kali-port-vuln-scanner.sh --target TARGET --no-online
```

### Help Commands

```bash
# Show help
./kali-port-vuln-scanner.sh --help

# Run tests
cd tests && sudo ./test_local_scan.sh

# Check version
grep "SCRIPT_VERSION=" kali-port-vuln-scanner.sh
```

## 📊 Documentation Statistics

| Metric | Count |
|--------|-------|
| Total Documents | 10 |
| Total Lines (Docs) | 3,000+ |
| Total Lines (Code) | 2,500+ |
| Total Files | 19 |
| Examples | 2 |
| Tests | 12+ |

## 🔗 External Resources

### Dependencies
- [Nmap Documentation](https://nmap.org/book/man.html)
- [Vulners API](https://vulners.com/docs)
- [CVE CIRCL](https://cve.circl.lu/api/)
- [SearchSploit](https://www.exploit-db.com/searchsploit)

### Security Resources
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Controls](https://www.cisecurity.org/controls/)

## 🆘 Support

### Getting Help

1. **Documentation** - Check relevant docs above
2. **Examples** - See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
3. **Issues** - Open a GitHub issue
4. **Tests** - Run test suite for diagnostics

### Reporting Issues

1. Check [CONTRIBUTING.md](CONTRIBUTING.md) - Bug Reports
2. Include system information
3. Provide logs and error messages
4. Describe expected vs actual behavior

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## ⚠️ Legal Notice

**This tool is for authorized security testing only.**

See [LICENSE](LICENSE) and [README.md](README.md) for complete legal notices.

---

## Document Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-05 | Initial documentation index |

---

**Navigation Tip:** Use Ctrl+F (Cmd+F on Mac) to search this index for specific topics.

**Last Updated:** 2025-10-05
