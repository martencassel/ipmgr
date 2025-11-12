#!/usr/bin/env bash
set -e

CLUSTER_NAME="${CLUSTER_NAME:-ipmgr-demo}"

echo "==================================="
echo "Cleaning up kind cluster and IPs"
echo "==================================="
echo ""

# Load environment if exists
if [ -f kind.env ]; then
    source kind.env
fi

# Delete kind cluster
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "🗑️  Deleting kind cluster '$CLUSTER_NAME'..."
    kind delete cluster --name "$CLUSTER_NAME"
    echo "✓ Cluster deleted"
else
    echo "ℹ️  No kind cluster named '$CLUSTER_NAME' found"
fi

echo ""

# Release the kind IP
if [ -f kind.env ] && [ -n "$KIND_IP" ]; then
    echo "📍 Releasing IP $KIND_IP from docker0..."
    ../ipmgr release "$KIND_IP" --iface docker0 2>/dev/null || echo "⚠️  IP already released or not found"
    echo "✓ IP released"
fi

# Clean up generated files
echo ""
echo "🧹 Cleaning up generated files..."
rm -f kind.env kind-config-generated.yml
echo "✓ Files removed"

echo ""
echo "✅ Cleanup complete!"
echo ""
