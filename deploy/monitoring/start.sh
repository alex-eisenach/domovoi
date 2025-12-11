#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Launching edge monitoring stack..."
docker compose up -d
echo "All services running!"
echo "→ Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
echo "→ Grafana:    http://$(hostname -I | awk '{print $1}'):3000"
echo "→ cAdvisor:   http://$(hostname -I | awk '{print $1}'):8080"
