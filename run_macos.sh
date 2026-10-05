#!/usr/bin/env bash
# Script to launch pgModeler on macOS
#  - Uses the host IP for the DISPLAY environment variable
#  - Mounts the data folder next to this script to keep pgModeler projects, config and plugins

# These settings are the default ones and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a .env.macos file (see .env.macos.example).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOST_IP=$(ifconfig en0 | grep "inet " | cut -d ' ' -f 2)
PGMODELER_IMAGE=apazga/docker-pgmodeler:latest
PROJECT_ROOT="$SCRIPT_DIR"

# Override environment variables with those from the .env file
if [ -f "$SCRIPT_DIR/.env.macos" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/.env.macos"
fi

# Add local machine to authorized host by XQuartz
xhost +

echo "HOST_IP: $HOST_IP"
docker run --rm \
  -e DISPLAY="$HOST_IP:0" \
  -v "$PROJECT_ROOT/data/root:/root" \
  -v "$PROJECT_ROOT/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins" \
  "$PGMODELER_IMAGE"
