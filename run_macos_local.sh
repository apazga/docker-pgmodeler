#!/bin/bash
# Script to launch pgModeler on macOS
#  - Use host.docker.internal for DISPLAY
#  - Mounts data folder in current directory to save pgModeler projects, config, and plugins

# These settings are default and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a separate .env file.
PGMODELER_IMAGE=apazga/docker-pgmodeler:1.2.0-alpha1
PROJECT_ROOT=/Users/abelpaz/Documents/_repos/docker-pgmodeler

# Override environment variables with those from the .env file
. .env.macos

# Add local machine to authorized host by XQuartz (allow 127.0.0.1)
xhost + 127.0.0.1

# Use host.docker.internal for DISPLAY
DISPLAY=host.docker.internal:0

echo "DISPLAY: $DISPLAY"
docker run --rm \
  -e DISPLAY=$DISPLAY \
  -v $PROJECT_ROOT/data/root:/root \
  -v $PROJECT_ROOT/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins \
  $PGMODELER_IMAGE