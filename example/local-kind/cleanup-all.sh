#!/usr/bin/env bash
set -e

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  Complete Cleanup - kind + Docker Compose    ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Cleanup kind
echo "🗑️  Cleaning up kind cluster..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./cleanup-kind.sh

echo ""

# Cleanup docker compose
echo "🗑️  Cleaning up Docker Compose..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./cleanup.sh

echo ""
echo "📊 Final IP allocations:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
../ipmgr list-all

echo ""
echo "✅ Complete cleanup finished!"
echo ""
