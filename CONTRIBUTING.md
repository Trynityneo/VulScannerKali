# Contributing to Kali Port & Vulnerability Scanner

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Our Standards

- Be respectful and professional
- Accept constructive criticism gracefully
- Focus on what is best for the project
- Show empathy towards other contributors

### Unacceptable Behavior

- Harassment or discrimination of any kind
- Trolling or insulting comments
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. A GitHub account
2. Git installed locally
3. Kali Linux or similar environment for testing
4. Basic knowledge of Bash scripting
5. Understanding of security testing principles

### Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/kali-port-vuln-scanner.git
cd kali-port-vuln-scanner

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/kali-port-vuln-scanner.git
```

## How to Contribute

### Types of Contributions

We welcome:

1. **Bug fixes** - Fix issues in existing code
2. **New features** - Add new functionality
3. **Documentation** - Improve or add documentation
4. **Tests** - Add or improve test coverage
5. **Performance improvements** - Optimize existing code
6. **Security enhancements** - Improve security posture

### Contribution Workflow

1. **Check existing issues** - Avoid duplicate work
2. **Create an issue** - Discuss major changes first
3. **Fork and branch** - Create a feature branch
4. **Make changes** - Implement your contribution
5. **Test thoroughly** - Ensure everything works
6. **Submit PR** - Create a pull request
7. **Address feedback** - Respond to review comments

## Development Setup

### Install Dependencies

```bash
# On Kali Linux
sudo apt-get update
sudo apt-get install -y nmap curl jq xmlstarlet exploitdb

# Install development tools
sudo apt-get install -y shellcheck shfmt
```

### Set Up Development Environment

```bash
# Create development branch
git checkout -b feature/your-feature-name

# Make scripts executable
chmod +x kali-port-vuln-scanner.sh
chmod +x lib/*.sh
chmod +x tests/*.sh
```

### Run Tests

```bash
# Run integration tests
cd tests
sudo ./test_local_scan.sh

# Run shellcheck (linting)
shellcheck kali-port-vuln-scanner.sh
shellcheck lib/*.sh
```

## Coding Standards

### Bash Style Guide

#### General Principles

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

#### Naming Conventions

```bash
# Variables: lowercase with underscores
local_variable="value"
GLOBAL_CONSTANT="VALUE"

# Functions: lowercase with underscores
function_name() {
    # function body
}

# Private functions: prefix with underscore
_private_function() {
    # function body
}
```

#### Code Formatting

```bash
# Use 4 spaces for indentation (no tabs)
if [[ condition ]]; then
    echo "indented with 4 spaces"
fi

# Use [[ ]] for conditionals (not [ ])
if [[ -f "$file" ]]; then
    echo "file exists"
fi

# Quote variables to prevent word splitting
echo "$variable"
echo "${array[@]}"

# Use $() for command substitution (not backticks)
result=$(command)

# Use functions for reusable code
parse_output() {
    local input="$1"
    # parsing logic
}
```

#### Error Handling

```bash
# Check command success
if ! command; then
    log_error "Command failed"
    return 1
fi

# Use trap for cleanup
trap cleanup EXIT INT TERM

cleanup() {
    # cleanup code
}
```

#### Documentation

```bash
# Add function documentation
################################################################################
# Function: parse_nmap_output
# Description: Parses nmap XML output and extracts service information
# Arguments:
#   $1 - Path to nmap XML file
#   $2 - Output JSON file path
# Returns:
#   0 on success, 1 on failure
# Example:
#   parse_nmap_output "/tmp/scan.xml" "/tmp/output.json"
################################################################################
parse_nmap_output() {
    local xml_file="$1"
    local json_file="$2"
    # implementation
}
```

### Python Style Guide

For Python helper scripts:

- Follow PEP 8
- Use type hints
- Add docstrings
- Use meaningful variable names

```python
def query_api(product: str, version: str) -> List[Dict[str, Any]]:
    """
    Query vulnerability API for product information.
    
    Args:
        product: Software product name
        version: Software version
        
    Returns:
        List of vulnerability dictionaries
    """
    # implementation
```

## Testing Guidelines

### Test Requirements

All contributions must include tests:

1. **Unit tests** - Test individual functions
2. **Integration tests** - Test complete workflows
3. **Manual testing** - Verify on real targets

### Writing Tests

```bash
# Test function template
test_feature_name() {
    run_test
    print_test "Testing feature X"
    
    # Setup
    local test_data="test"
    
    # Execute
    local result=$(function_to_test "$test_data")
    
    # Assert
    if [[ "$result" == "expected" ]]; then
        print_pass "Feature X works correctly"
        return 0
    else
        print_fail "Feature X failed"
        return 1
    fi
}
```

### Running Tests

```bash
# Run all tests
cd tests
sudo ./test_local_scan.sh

# Run specific test
sudo ./test_local_scan.sh test_json_schema

# Run with verbose output
sudo ./test_local_scan.sh --verbose
```

## Submitting Changes

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No sensitive data in commits

### Commit Messages

Follow conventional commits format:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:

```
feat(scanner): add IPv6 support

Implement IPv6 address scanning with nmap -6 flag.
Includes tests and documentation updates.

Closes #123
```

```
fix(parser): handle empty XML elements

Fix crash when nmap XML contains empty service elements.
Add defensive checks and error handling.

Fixes #456
```

### Pull Request Process

1. **Update documentation** - README, CHANGELOG, etc.
2. **Add tests** - Ensure new code is tested
3. **Run tests** - All tests must pass
4. **Create PR** - Use the PR template
5. **Describe changes** - Explain what and why
6. **Link issues** - Reference related issues
7. **Request review** - Tag maintainers
8. **Address feedback** - Respond to comments
9. **Squash commits** - Clean up commit history (if requested)

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Security enhancement

## Testing
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No breaking changes (or documented)

## Related Issues
Closes #XXX
```

## Reporting Bugs

### Before Reporting

1. **Check existing issues** - Avoid duplicates
2. **Test latest version** - Bug may be fixed
3. **Gather information** - Logs, versions, etc.

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Run command: `./kali-port-vuln-scanner.sh --target X`
2. Observe error: ...
3. Expected behavior: ...

## Environment
- OS: Kali Linux 2024.1
- Bash version: 5.1.16
- Nmap version: 7.94
- Scanner version: 1.0.0

## Logs
```
paste relevant logs here
```

## Additional Context
Screenshots, error messages, etc.
```

## Suggesting Features

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed?
Who would benefit?

## Proposed Implementation
How could this be implemented?

## Alternatives Considered
What other approaches were considered?

## Additional Context
Mockups, examples, references
```

## Code Review Process

### For Contributors

- Be responsive to feedback
- Ask questions if unclear
- Make requested changes promptly
- Be patient and professional

### For Reviewers

- Be constructive and respectful
- Explain reasoning for changes
- Approve when ready
- Provide clear feedback

## Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Credited in release notes
- Added to contributors list

## Questions?

- Open an issue for questions
- Join discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Kali Port & Vulnerability Scanner!**

Your contributions help make security testing more accessible and effective.
