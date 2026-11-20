#!/usr/bin/env bash
# Author: Oliver Ristow
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
mkdir -p reports
report="reports/tailscale-docker-network-prerequisites-$(date +%Y%m%d-%H%M%S).txt"

{
    printf '=== Captured ===\n'
    date -Is

    printf '\n=== Docker ===\n'
    docker --version || true

    printf '\n=== Docker Compose ===\n'
    docker compose version || true

    printf '\n=== IPv4 forwarding ===\n'
    sysctl net.ipv4.ip_forward

    printf '\n=== TUN device ===\n'
    if test -c /dev/net/tun; then
        printf 'TUN device available\n'
    else
        printf 'TUN device missing\n'
    fi



} 2>&1 | tee "$report"
