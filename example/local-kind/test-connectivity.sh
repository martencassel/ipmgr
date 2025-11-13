#!/usr/bin/env bash
set -e

echo "==================================="
echo "Testing Connectivity"
echo "==================================="
echo ""

# Load environment
if [ ! -f kind.env ]; then
    echo "❌ Error: kind.env not found. Run setup-kind.sh first."
    exit 1
fi

source kind.env
source .env 2>/dev/null || true

if [ -z "$KIND_IP" ]; then
    echo "❌ Error: KIND_IP not set in kind.env"
    exit 1
fi

echo "Testing connectivity to Kubernetes API..."
echo "------------------------------------------"

# Test Kubernetes API
echo "Testing: https://$KIND_IP:5443"
if curl -s -k "https://$KIND_IP:5443" | grep -qE "(Unauthorized|Forbidden)"; then
    echo "✓ Kubernetes API is accessible at $KIND_IP:5443"
else
    echo "❌ Failed to connect to Kubernetes API"
    exit 1
fi

echo ""

# Check if nginx containers are running
if [ -n "$DEMO_IP1" ] || [ -n "$DEMO_IP2" ] || [ -n "$DEMO_IP3" ]; then
    echo "Testing connectivity to Nginx containers..."
    echo "------------------------------------------"

    for i in 1 2 3; do
        var_name="DEMO_IP$i"
        ip="${!var_name}"
        if [ -n "$ip" ]; then
            echo -n "Testing: http://$ip... "
            if curl -s --max-time 3 "http://$ip" > /dev/null 2>&1; then
                echo "✓ OK"
            else
                echo "❌ Failed"
            fi
        fi
    done
    echo ""
fi

# Test from inside nginx container to Kubernetes API
if docker ps --format '{{.Names}}' | grep -q "nginx1"; then
    echo "Testing connectivity from Nginx container to Kubernetes API..."
    echo "------------------------------------------------------------"

    # Get the nginx container name
    NGINX_CONTAINER=$(docker ps --format '{{.Names}}' | grep "nginx1" | head -1)

    if [ -n "$NGINX_CONTAINER" ]; then
        echo "Container: $NGINX_CONTAINER"
        echo "Testing: curl from nginx1 to https://$KIND_IP:5443"

        if docker exec "$NGINX_CONTAINER" sh -c "apt-get update -qq && apt-get install -y -qq curl > /dev/null 2>&1 && curl -s -k https://$KIND_IP:5443" | grep -qE "(Unauthorized|Forbidden)"; then
            echo "✓ Nginx container can reach Kubernetes API at $KIND_IP:5443"
        else
            echo "❌ Nginx container cannot reach Kubernetes API"
        fi
    fi
    echo ""
fi

# Test from kind container to nginx
echo "Testing connectivity from kind to Nginx containers..."
echo "----------------------------------------------------"

kind export kubeconfig --name "$CLUSTER_NAME" >/dev/null 2>&1
export KUBECONFIG="$(kind get kubeconfig-path --name="$CLUSTER_NAME")"
kubectl cluster-info
if [ -z "$KIND_IP" ]; then
    echo "❌ Error: KIND_IP not set in kind.env"
    exit 1
fi
echo ""

KIND_CONTAINER="${CLUSTER_NAME:-ipmgr-demo}-control-plane"

if docker ps --format '{{.Names}}' | grep -q "$KIND_CONTAINER"; then
    for i in 1 2 3; do
        var_name="DEMO_IP$i"
        ip="${!var_name}"
        if [ -n "$ip" ]; then
            echo "Testing: curl from kind to http://$ip"
            if docker exec "$KIND_CONTAINER" curl -s --max-time 3 "http://$ip" > /dev/null 2>&1; then
                echo "✓ Kind container can reach nginx at $ip"
            else
                echo "❌ Kind container cannot reach nginx at $ip"
            fi
        fi
    done
else
    echo "⚠️  Kind container not found (looking for: $KIND_CONTAINER)"
fi

echo ""
echo "==================================="
echo "✅ Connectivity tests complete!"
echo "==================================="
echo ""
echo "Summary:"
echo "--------"
echo "Kubernetes API: $KIND_IP:5443"
../ipmgr list --iface docker0 2>/dev/null || echo "No allocations on docker0"
echo ""
