#!/usr/bin/env bash
set -euo pipefail

echo "Upgrading Pi-Hole services..."

# Pi-hole
helm upgrade --install pihole mojo2600/pihole \
  --namespace pihole \
  -f pihole/pihole-values.yaml \
  --create-namespace \
  --wait --timeout 5m

echo "All services upgraded successfully"
