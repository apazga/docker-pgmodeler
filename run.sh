#!/usr/bin/env bash
# Script to launch pgModeler on Linux
#  - Uses HOST_IP for the DISPLAY environment variable
#  - Mounts the data folder next to this script to keep pgModeler projects, config and plugins

# These settings are the default ones and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a .env.linux file (see .env.linux.example).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOST_IP=192.168.1.100
PGMODELER_IMAGE=apazga/docker-pgmodeler:latest
PROJECT_ROOT="$SCRIPT_DIR"

# Override environment variables with those from the .env file
if [ -f "$SCRIPT_DIR/.env.linux" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/.env.linux"
fi

docker run --rm -ti \
  -e DISPLAY="$HOST_IP:0.0" \
  -v "$PROJECT_ROOT/data/root:/root" \
  -v "$PROJECT_ROOT/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins" \
  "$PGMODELER_IMAGE"
