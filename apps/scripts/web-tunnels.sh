#!/usr/bin/env bash
# local port-forwards via tmux
# use: ./web-tunnels.sh [start|stop|attach]

set -euo pipefail

SESSION="domovoi-tunnels"
PIHOLE_NS="pihole"
PROM_NS="monitoring"
ARGO_NS="argocd"

# Format: "local-port svc-name:target-port window-name namespace"
# verify ports with `kubectl get svc -n monitoring`
FORWARDS=(
  "8080 pihole-web:80 pihole-web $PIHOLE_NS"
  "9090 kube-prometheus-kube-prome-prometheus:9090 prometheus $PROM_NS"
  "3000 kube-prometheus-grafana:80 grafana $PROM_NS"   
  "8443 argocd-server:443 argocd-ui $ARGO_NS"
)

start_tunnels() {
  tmux new-session -d -s "$SESSION" -n "init"

  for ((i = 0; i < ${#FORWARDS[@]}; i++)); do
    IFS=' ' read -r LOCAL_PORT SERVICE_PORT WINDOW_NAME NS <<< "${FORWARDS[i]}"

    CMD="kubectl -n $NS port-forward svc/${SERVICE_PORT%:*} $LOCAL_PORT:${SERVICE_PORT#*:} --address 0.0.0.0"

    if [[ $i -eq 0 ]]; then
      tmux rename-window -t "$SESSION:0" "$WINDOW_NAME"
      tmux send-keys -t "$SESSION:0" "$CMD" C-m
    else
      tmux new-window -t "$SESSION" -n "$WINDOW_NAME"
      tmux send-keys -t "$SESSION:$i" "$CMD" C-m
    fi
  done

  echo "Tunnels started in tmux session '$SESSION'"
  echo "   - Pi-hole Web:    http://<pi-ip-or-localhost>:8080/admin"
  echo "   - Prometheus:     http://<pi-ip-or-localhost>:9090"
  echo "   - Grafana:        http://<pi-ip-or-localhost>:3000"
  echo "   - ArgoCD UI:      http://<pi-ip-or-localhost>:8443"
  echo ""
  echo "   Attach: tmux attach -t $SESSION"
  echo "   Stop:   ./local-tunnel.sh stop"
}

stop_tunnels() {
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux kill-session -t "$SESSION"
    echo "Session '$SESSION' terminated"
  else
    echo "No active session '$SESSION'"
  fi
}

case "${1:-start}" in
  start)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      echo "Session '$SESSION' already running. Attach with: tmux attach -t $SESSION"
    else
      start_tunnels
    fi
    ;;
  stop)  stop_tunnels ;;
  attach) tmux attach -t "$SESSION" || echo "No session—start first" ;;
  *)     echo "Usage: $0 [start|stop|attach]" ;;
esac
