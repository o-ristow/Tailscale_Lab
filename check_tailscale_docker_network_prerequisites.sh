#!/usr/bin/env bash
# Author: Oliver Ristow
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
mkdir -p reports
report="reports/tailscale-docker-network-prerequisites-$(date +%Y%m%d-%H%M%S).txt"

check_prerequisites() {
    local failed=0

    printf '=== Captured ===\n'
    date -Is

    printf '\n=== Docker ===\n'
    if ! command -v docker >/dev/null 2>&1; then
        printf 'FAIL: Docker is not installed.\n'
        printf 'Action: Install Docker Engine and the Compose plugin.\n'
        failed=1
    else
        docker --version

        if docker info >/dev/null 2>&1; then
            printf 'PASS: Docker daemon is accessible.\n'
        else
            printf 'FAIL: Cannot access the Docker daemon.\n'
            printf 'Action: Run "docker info" to see whether the daemon is stopped or access is denied.\n'
            failed=1
        fi

        printf '\n=== Docker Compose ===\n'
        if docker compose version; then
            printf 'PASS: Docker Compose is available.\n'
        else
            printf 'FAIL: Docker Compose is unavailable.\n'
            printf 'Action: Install the Docker Compose plugin.\n'
            failed=1
        fi
    fi

    printf '\n=== IPv4 forwarding ===\n'
    if [[ "$(sysctl -n net.ipv4.ip_forward 2>/dev/null)" == "1" ]]; then
        printf 'PASS: IPv4 forwarding is enabled.\n'
    else
        printf 'FAIL: IPv4 forwarding is disabled or could not be read.\n'
        printf 'Action: Enable net.ipv4.ip_forward=1 persistently on the host, then rerun this check.\n'
        failed=1
    fi

    printf '\n=== TUN device ===\n'
    if test -c /dev/net/tun; then
        printf 'PASS: TUN device is available.\n'
    else
        printf 'FAIL: /dev/net/tun is missing.\n'
        printf 'Action: Run "sudo modprobe tun", then rerun this check.\n'
        failed=1
    fi

    printf '\n=== Result ===\n'
    if (( failed )); then
        printf 'FAIL: Prerequisites are not met. Resolve the failures above before deployment.\n'
    else
        printf 'PASS: All checked prerequisites are met.\n'
    fi

    return "$failed"
}

check_prerequisites 2>&1 | tee "$report"
