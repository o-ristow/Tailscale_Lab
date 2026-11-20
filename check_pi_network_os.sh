#!/usr/bin/env bash
# Author: Oliver Ristow
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
mkdir -p reports
report="reports/pi-network-os-$(date +%Y%m%d-%H%M%S).txt"

{
    printf '=== Captured ===\n'
    date -Is
    printf '\n=== OS ===\n'
    cat /etc/os-release
    printf '\n=== Architecture ===\n'
    uname -m
    printf '\n=== IPv4 addresses ===\n'
    ip -br -4 addr
    printf '\n=== IPv4 routes ===\n'
    ip -4 route
} | tee "$report"
