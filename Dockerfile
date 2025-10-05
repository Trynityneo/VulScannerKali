# Dockerfile for Kali Port & Vulnerability Scanner
# Provides a reproducible environment for running the scanner

FROM kalilinux/kali-rolling:latest

LABEL maintainer="Security Research Team"
LABEL description="Kali Port & Vulnerability Scanner - Containerized"
LABEL version="1.0.0"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        nmap \
        curl \
        jq \
        xmlstarlet \
        exploitdb \
        masscan \
        python3 \
        python3-pip \
        git \
        wget \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir requests

# Update nmap scripts and install vulners
RUN nmap --script-updatedb && \
    cd /usr/share/nmap/scripts/ && \
    wget -q https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse && \
    nmap --script-updatedb

# Update searchsploit database
RUN searchsploit -u || true

# Create working directory
WORKDIR /scanner

# Copy scanner files
COPY kali-port-vuln-scanner.sh /scanner/
COPY lib/ /scanner/lib/
COPY examples/ /scanner/examples/

# Make scripts executable
RUN chmod +x /scanner/kali-port-vuln-scanner.sh && \
    chmod +x /scanner/lib/*.sh && \
    chmod +x /scanner/lib/*.py

# Create output directory
RUN mkdir -p /scanner/reports

# Set up volume for reports
VOLUME ["/scanner/reports"]

# Set environment variables
ENV PATH="/scanner:${PATH}"
ENV SCANNER_HOME="/scanner"

# Add entrypoint script
RUN echo '#!/bin/bash\n\
if [ "$#" -eq 0 ]; then\n\
    echo "Kali Port & Vulnerability Scanner - Docker Container"\n\
    echo ""\n\
    echo "Usage:"\n\
    echo "  docker run -v \$(pwd)/reports:/scanner/reports vuln-scanner --target <target> [options]"\n\
    echo ""\n\
    echo "Examples:"\n\
    echo "  docker run -v \$(pwd)/reports:/scanner/reports vuln-scanner --target 192.168.1.10"\n\
    echo "  docker run -v \$(pwd)/reports:/scanner/reports vuln-scanner --target example.com --fast"\n\
    echo ""\n\
    echo "For full help:"\n\
    echo "  docker run vuln-scanner --help"\n\
    exit 0\n\
fi\n\
\n\
exec /scanner/kali-port-vuln-scanner.sh "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Default command shows help
CMD ["--help"]

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD nmap --version || exit 1

# Metadata
LABEL org.opencontainers.image.source="https://github.com/yourusername/kali-port-vuln-scanner"
LABEL org.opencontainers.image.documentation="https://github.com/yourusername/kali-port-vuln-scanner/blob/main/README.md"
LABEL org.opencontainers.image.licenses="MIT"
