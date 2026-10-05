#!/usr/bin/env bash
# Script to launch pgModeler on macOS without a network connection
#  - Uses host.docker.internal for DISPLAY
#  - Mounts the data folder next to this script to keep pgModeler projects, config and plugins

# These settings are the default ones and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a .env.macos file (see .env.macos.example).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOCAL_DISPLAY=host.docker.internal:0
PGMODELER_IMAGE=apazga/docker-pgmodeler:latest
PROJECT_ROOT="$SCRIPT_DIR"

# Override environment variables with those from the .env file
if [ -f "$SCRIPT_DIR/.env.macos" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/.env.macos"
fi

# Add local machine to authorized host by XQuartz (allow 127.0.0.1)
xhost + 127.0.0.1

echo "DISPLAY: $LOCAL_DISPLAY"
docker run --rm \
  -e DISPLAY="$LOCAL_DISPLAY" \
  -v "$PROJECT_ROOT/data/root:/root" \
  -v "$PROJECT_ROOT/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins" \
  "$PGMODELER_IMAGE"
