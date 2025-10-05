# Docker Deployment Guide

This guide explains how to build and run the Kali Port & Vulnerability Scanner in a Docker container for reproducible and isolated execution.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Building the Image](#building-the-image)
- [Running the Scanner](#running-the-scanner)
- [Docker Compose](#docker-compose)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)

## Prerequisites

### Required Software

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 1.29 or later (optional)

### Installation

#### Linux

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
```

#### Windows

Download and install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)

#### macOS

Download and install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)

## Building the Image

### Basic Build

```bash
# Navigate to project directory
cd kali-port-vuln-scanner

# Build the Docker image
docker build -t vuln-scanner:latest .

# Verify the image
docker images | grep vuln-scanner
```

### Build with Custom Tag

```bash
docker build -t vuln-scanner:v1.0.0 .
```

### Build with No Cache

```bash
docker build --no-cache -t vuln-scanner:latest .
```

## Running the Scanner

### Basic Usage

```bash
# Show help
docker run --rm vuln-scanner:latest --help

# Scan a target (with reports in current directory)
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10
```

### Common Scan Examples

#### Quick Scan

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10 \
  --fast
```

#### Full Port Scan

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10 \
  --ports 1-65535
```

#### Scan with Vulners API

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  -e VULNERS_API_KEY="your_api_key" \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10 \
  --use-vulners-api "$VULNERS_API_KEY"
```

#### Scan Multiple Targets from File

```bash
# Create targets file
cat > targets.txt << EOF
192.168.1.10
192.168.1.20
example.com
EOF

# Run scan
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  -v $(pwd)/targets.txt:/scanner/targets.txt:ro \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target /scanner/targets.txt
```

#### Local-Only Scan (No Internet)

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10 \
  --no-online
```

### Windows PowerShell Examples

```powershell
# Basic scan
docker run --rm `
  -v ${PWD}/reports:/scanner/reports `
  --network host `
  --cap-add=NET_RAW `
  --cap-add=NET_ADMIN `
  vuln-scanner:latest `
  --target 192.168.1.10

# Fast scan
docker run --rm `
  -v ${PWD}/reports:/scanner/reports `
  --network host `
  --cap-add=NET_RAW `
  --cap-add=NET_ADMIN `
  vuln-scanner:latest `
  --target 192.168.1.10 --fast
```

## Docker Compose

Docker Compose simplifies running the scanner with predefined configurations.

### Basic Usage

```bash
# Build the image
docker-compose build

# Run a scan
docker-compose run --rm vuln-scanner --target 192.168.1.10

# Run with custom options
docker-compose run --rm vuln-scanner \
  --target 192.168.1.10 \
  --fast \
  --ports 80,443
```

### Using Environment Variables

```bash
# Create .env file
cat > .env << EOF
VULNERS_API_KEY=your_api_key_here
EOF

# Run scan (API key automatically loaded)
docker-compose run --rm vuln-scanner \
  --target 192.168.1.10 \
  --use-vulners-api "$VULNERS_API_KEY"
```

### Scan Multiple Targets

```bash
# Targets file already mounted in docker-compose.yml
docker-compose run --rm vuln-scanner --target /scanner/targets.txt
```

## Configuration

### Volume Mounts

The container uses volumes to persist data:

```bash
# Reports directory (required)
-v $(pwd)/reports:/scanner/reports

# Custom targets file (optional)
-v $(pwd)/targets.txt:/scanner/targets.txt:ro

# Custom configuration (optional)
-v $(pwd)/config:/scanner/config:ro
```

### Network Modes

#### Host Network (Recommended for Scanning)

```bash
--network host
```

Provides direct access to host network interfaces. Required for most scanning scenarios.

#### Bridge Network (Limited)

```bash
--network bridge
```

Isolated network. Limited scanning capabilities.

#### Custom Network

```bash
# Create network
docker network create scanner-net

# Run with custom network
docker run --rm \
  --network scanner-net \
  vuln-scanner:latest \
  --target 192.168.1.10
```

### Capabilities

Required capabilities for raw socket access:

```bash
--cap-add=NET_RAW      # Raw socket access
--cap-add=NET_ADMIN    # Network administration
```

### Resource Limits

```bash
# Limit CPU and memory
docker run --rm \
  --cpus="2.0" \
  --memory="2g" \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10
```

## Troubleshooting

### Issue: "Permission denied" errors

**Solution**: Ensure capabilities are added:
```bash
--cap-add=NET_RAW --cap-add=NET_ADMIN
```

### Issue: Cannot reach target network

**Solution**: Use host network mode:
```bash
--network host
```

### Issue: Reports not saved

**Solution**: Check volume mount:
```bash
# Ensure reports directory exists
mkdir -p reports

# Use absolute path
docker run --rm \
  -v /absolute/path/to/reports:/scanner/reports \
  ...
```

### Issue: "nmap: command not found"

**Solution**: Rebuild the image:
```bash
docker build --no-cache -t vuln-scanner:latest .
```

### Issue: Slow performance

**Solutions**:
- Increase resource limits
- Use `--fast` flag
- Reduce port range
- Use host network mode

### Issue: Cannot access online APIs

**Solution**: Check container internet access:
```bash
# Test connectivity
docker run --rm vuln-scanner:latest curl -I https://vulners.com
```

## Security Considerations

### Principle of Least Privilege

The container requires elevated capabilities for scanning. Use with caution:

```bash
# Only add required capabilities
--cap-add=NET_RAW --cap-add=NET_ADMIN

# Drop all other capabilities
--cap-drop=ALL --cap-add=NET_RAW --cap-add=NET_ADMIN
```

### Network Isolation

For scanning external targets, consider network isolation:

```bash
# Create isolated network
docker network create --driver bridge scanner-net

# Run with isolated network
docker run --rm \
  --network scanner-net \
  vuln-scanner:latest \
  --target external-target.com
```

### Read-Only Root Filesystem

```bash
docker run --rm \
  --read-only \
  --tmpfs /tmp \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10
```

### Security Options

```bash
docker run --rm \
  --security-opt=no-new-privileges:true \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10
```

## Advanced Usage

### Interactive Shell

```bash
# Start interactive shell in container
docker run -it --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  --entrypoint /bin/bash \
  vuln-scanner:latest

# Inside container, run scanner manually
./kali-port-vuln-scanner.sh --target 192.168.1.10
```

### Custom Entrypoint

```bash
# Run custom script
docker run --rm \
  -v $(pwd)/custom-script.sh:/custom-script.sh \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  --entrypoint /custom-script.sh \
  vuln-scanner:latest
```

### Automated Scanning with Cron

```bash
# Create cron job to run containerized scan
cat > /etc/cron.d/vuln-scanner << 'EOF'
0 2 * * * root docker run --rm -v /var/scans:/scanner/reports --network host --cap-add=NET_RAW --cap-add=NET_ADMIN vuln-scanner:latest --target /scanner/targets.txt --no-online
EOF
```

## Maintenance

### Update the Image

```bash
# Rebuild with latest base image
docker build --pull --no-cache -t vuln-scanner:latest .

# Update nmap scripts
docker run --rm -it \
  --entrypoint /bin/bash \
  vuln-scanner:latest \
  -c "nmap --script-updatedb && searchsploit -u"
```

### Clean Up

```bash
# Remove old images
docker image prune -a

# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune
```

## Best Practices

1. **Always use volume mounts** for reports to persist data
2. **Use host network mode** for comprehensive scanning
3. **Set resource limits** to prevent resource exhaustion
4. **Keep the image updated** with latest security patches
5. **Use environment variables** for sensitive data (API keys)
6. **Run with minimal privileges** when possible
7. **Test in isolated environment** before production use

## Example Workflows

### Workflow 1: Quick Security Check

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  vuln-scanner:latest \
  --target 192.168.1.10 \
  --fast \
  --no-online
```

### Workflow 2: Comprehensive Assessment

```bash
docker run --rm \
  -v $(pwd)/reports:/scanner/reports \
  -e VULNERS_API_KEY="$VULNERS_API_KEY" \
  --network host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  --cpus="4.0" \
  --memory="4g" \
  vuln-scanner:latest \
  --target 192.168.1.0/24 \
  --ports 1-65535 \
  --use-vulners-api "$VULNERS_API_KEY" \
  --threads 20 \
  --verbose
```

### Workflow 3: Continuous Monitoring

```bash
# Using Docker Compose
docker-compose run --rm vuln-scanner \
  --target /scanner/targets.txt \
  --output-dir /scanner/reports/$(date +%Y%m%d) \
  --format json
```

---

**Remember**: Always obtain proper authorization before scanning any systems!

For more information, see [README.md](README.md) and [INSTALL.md](INSTALL.md).
