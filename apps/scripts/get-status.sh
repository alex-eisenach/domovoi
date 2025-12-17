#!/usr/bin/env bash
set -euo pipefail

echo "=== Helm Releases ==="
helm list --all-namespaces

echo -e "\n=== LoadBalancer Services (MetalLB VIPs) ==="
kubectl get svc --all-namespaces | grep LoadBalancer || true

echo -e "\n=== Running Pods ==="
kubectl get pods --all-namespaces -o wide
