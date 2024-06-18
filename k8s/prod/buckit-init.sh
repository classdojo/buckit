#!/bin/bash
set -o pipefail

CONSUL_LOCAL_IP=${CONSUL_LOCAL_IP:-"consul-api.consul"}
CONSUL_ADDR=${CONSUL_HTTP_ADDR:-"http://${CONSUL_LOCAL_IP}:8500"}

function consul_get {
  DEFAULT=${2:-"\"\""}
  VALUE=$(curl --retry 5 --retry-all-errors -sL "${CONSUL_ADDR}/v1/kv/${1}?raw=1" 2>/dev/null || echo "")
  echo "${VALUE:-${DEFAULT}}"
}

# Wait for consul to be ready         
function wait_for_consul_leader {
  RETRIES=0
  while true; do
    if [ "${RETRIES}" -gt 8 ]; then
      echo "Consul ${CONSUL_ADDR} not ready after 30 seconds, exiting" >&2
      exit 1
    fi
    LEADER=$(curl -sL "${CONSUL_ADDR}/v1/status/leader" | grep -E '".+"')
    if [ ! -z "${LEADER}" ]; then
      break
    else
      echo "Consul not ready, retrying..."
      sleep 4
      RETRIES=$((RETRIES+1))
    fi
  done
}
wait_for_consul_leader

mkdir -p /secrets

consul_get config/buckit/config.yaml > "/secrets/config.json"

buckit --config /secrets/config.json