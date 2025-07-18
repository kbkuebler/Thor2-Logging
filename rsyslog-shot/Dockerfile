FROM ubuntu:24.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install rsyslog, Python, and useful packages
RUN apt-get update && apt-get install -y \
    rsyslog \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages

RUN pip3 install --break-system-packages \
    requests \
    ujson

# Copy our rsyslog config and Python script into the container
COPY rsyslog.conf /etc/rsyslog.conf
COPY enrich_sid.py /opt/enrich_sid.py

# rsyslog expects this directory
RUN mkdir -p /var/run/rsyslog

# Make Python script executable
RUN chmod +x /opt/enrich_sid.py

# Create a runtime volume mount point for SID map
VOLUME ["/data"]

# Expose high port to avoid privilege requirements
EXPOSE 5514/tcp

# Default command
CMD ["rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]
