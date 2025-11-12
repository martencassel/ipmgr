#!/usr/bin/env bash
set -e

# Stop and remove containers
docker-compose down

# Release IPs from iface eth0 using ipmgr
if [ -f .env ]; then
  source .env
  for ip in "$DEMO_IP1" "$DEMO_IP2" "$DEMO_IP3"; do
    if [ -n "$ip" ]; then
      echo "Releasing $ip from eth0..."
      ipmgr release "$ip" --iface eth0
    fi
  done
fi

echo "Cleanup complete."
