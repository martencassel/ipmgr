#!/usr/bin/env bash
set -e

IFACE="${IFACE:-docker0}"
POOL="${POOL:-172.21.22.160-172.21.22.170}"
CLUSTER_NAME="${CLUSTER_NAME:-ipmgr-demo}"

echo "==================================="
echo "Setting up kind with ipmgr"
echo "==================================="
echo ""

# Check if ipmgr is available
if ! command -v ipmgr &> /dev/null; then
    echo "❌ Error: ipmgr not found in PATH"
    echo "   Please install ipmgr first or run from the parent directory"
    exit 1
fi

# Check if kind is available
if ! command -v kind &> /dev/null; then
    echo "❌ Error: kind not found in PATH"
    echo "   Install kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running"
    exit 1
fi

echo "✓ Prerequisites check passed"
echo ""

# Allocate IP for kind cluster
echo "📍 Allocating IP from pool $POOL on interface $IFACE..."
../ipmgr alloc --pool "$POOL" --iface "$IFACE"

# Get the allocated IP
KIND_IP=$(../ipmgr list --iface "$IFACE" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -1)

if [ -z "$KIND_IP" ]; then
    echo "❌ Error: Failed to allocate IP"
    exit 1
fi

echo "✓ Allocated IP: $KIND_IP"
echo ""

# Export to .env file
echo "KIND_IP=$KIND_IP" > kind.env
echo "CLUSTER_NAME=$CLUSTER_NAME" >> kind.env

echo "📝 Created kind.env with:"
cat kind.env
echo ""

# Create kind config with substituted IP
echo "📝 Generating kind configuration..."
export KIND_IP
envsubst < kind-config.yml > kind-config-generated.yml

echo "✓ Generated kind-config-generated.yml"
echo ""

# Create kind cluster
echo "🚀 Creating kind cluster '$CLUSTER_NAME'..."
kind create cluster --name "$CLUSTER_NAME" --config kind-config-generated.yml

echo ""
echo "✓ Kind cluster created successfully!"
echo ""

# Export kubeconfig
echo "📝 Exporting kubeconfig..."
kind export kubeconfig --name "$CLUSTER_NAME"

echo ""
echo "⏳ Waiting for cluster to be ready..."
if kubectl wait --for=condition=Ready nodes --all --timeout=180s 2>/dev/null; then
    echo "✓ Cluster is ready!"
else
    echo "⚠️  Cluster not ready yet. You may need to wait a bit longer."
    echo "   Check status with: kubectl get nodes"
    echo "   Check pods with: kubectl get pods -A"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Cluster Information:"
echo "===================="
echo "Cluster Name: $CLUSTER_NAME"
echo "API Server IP: $KIND_IP:5443"
echo "HTTP Port: $KIND_IP:8080"
echo ""
echo "To use this cluster:"
echo "  source kind.env"
echo "  kubectl cluster-info"
echo "  curl https://$KIND_IP:5443 -k"
echo ""
