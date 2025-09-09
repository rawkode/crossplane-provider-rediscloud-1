#!/bin/bash
# Setup script to configure podman as a drop-in replacement for docker

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[INFO]${NC} Setting up podman environment..."

# Start podman socket if not running
if ! systemctl --user is-active --quiet podman.socket; then
    echo -e "${BLUE}[INFO]${NC} Starting podman socket..."
    systemctl --user start podman.socket
fi

# Export environment variables
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
export KIND_EXPERIMENTAL_PROVIDER=podman

# Create docker alias if it doesn't exist
if ! command -v docker &> /dev/null; then
    echo -e "${BLUE}[INFO]${NC} Creating docker alias to podman..."
    alias docker=podman
fi

echo -e "${GREEN}[SUCCESS]${NC} Podman environment configured!"
echo
echo "Environment variables set:"
echo "  DOCKER_HOST=$DOCKER_HOST"
echo "  KIND_EXPERIMENTAL_PROVIDER=$KIND_EXPERIMENTAL_PROVIDER"
echo
echo "To make these settings permanent, add them to your .envrc file"