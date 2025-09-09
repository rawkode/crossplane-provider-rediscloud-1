#!/usr/bin/env bash
set -euo pipefail

# Quick start script for testing the RedisCloud provider
echo "🚀 RedisCloud Crossplane Provider Quick Start"
echo "============================================"
echo

# Check if credentials are set
if [[ "${REDISCLOUD_API_KEY:-}" == "your-api-key-here" || -z "${REDISCLOUD_API_KEY:-}" ]]; then
    echo "❌ RedisCloud credentials not configured!"
    echo
    echo "Please update your .envrc file with real credentials:"
    echo "  export REDISCLOUD_API_KEY=\"your-actual-api-key\""
    echo "  export REDISCLOUD_SECRET_KEY=\"your-actual-secret-key\""
    echo
    echo "Get credentials from: https://app.redislabs.com/#/login"
    echo "Then run: direnv allow"
    echo
    exit 1
fi

echo "✅ Credentials configured"
echo "📦 Building provider..."

# Build the provider
make build

echo "🎯 Provider built successfully!"
echo
echo "🔧 Next steps:"
echo "1. Run the test script: ./scripts/test-provider.sh"
echo "2. Or run individual steps:"
echo "   ./scripts/test-provider.sh cluster     # Create kind cluster"
echo "   ./scripts/test-provider.sh crossplane # Install Crossplane"
echo "   ./scripts/test-provider.sh provider   # Install provider"
echo "   ./scripts/test-provider.sh config     # Configure credentials"
echo "   ./scripts/test-provider.sh test       # Test with sample resource"
echo
echo "📊 Check status anytime with:"
echo "   ./scripts/test-provider.sh status"
echo
