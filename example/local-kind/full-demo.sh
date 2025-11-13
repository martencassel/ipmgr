#!/usr/bin/env bash
set -e

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  ipmgr + kind + Docker Compose Full Demo     ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

IFACE="${IFACE:-docker0}"
POOL="${POOL:-172.21.22.160-172.21.22.170}"

# Step 1: Allocate IPs for nginx containers
echo "📍 Step 1: Allocating IPs for Nginx containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for i in {1..3}; do
    ../ipmgr alloc --pool "$POOL" --iface "$IFACE"
done

echo ""
echo "📝 Generating .env file for Docker Compose..."
../ipmgr render-env --iface "$IFACE" --prefix DEMO > .env

cat .env
echo ""

# Step 2: Start nginx containers
echo "🐳 Step 2: Starting Nginx containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker-compose up -d

echo ""
sleep 2

# Step 3: Setup kind cluster
echo "🚀 Step 3: Setting up kind cluster"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./setup-kind.sh

echo ""
sleep 2

# Step 4: Show all allocations
echo "📊 Step 4: Current IP Allocations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
../ipmgr list-all

echo ""

# Step 5: Test connectivity
echo "🔍 Step 5: Testing Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./test-connectivity.sh

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  ✅ Demo Complete!                            ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "You now have:"
echo "  • 3 Nginx containers on dedicated IPs"
echo "  • 1 kind Kubernetes cluster on a dedicated IP"
echo "  • All IPs managed by ipmgr"
echo ""
echo "To clean up everything, run:"
echo "  ./cleanup-all.sh"
echo ""
