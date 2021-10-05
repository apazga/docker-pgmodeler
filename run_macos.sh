# Script to launch pgModeler on macOS
#  - Use host IP for DISPLAY environment variable
#  - Mounts data folder in current directory to save pgModeler projects, config and plugins

# These settings are default one and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a separate .env file.
HOST_IP=$(ifconfig en0 | grep "inet " | cut -d ' ' -f 2)
PGMODELER_IMAGE=merinorus/docker-pgmodeler:0.9.4-beta
PROJECT_ROOT=/Users/toto/docker-pgmodeler

# Set environment variables from the .env file
. .env

# Add local machine to authorized host by XQuartz
xhost +

echo HOST_IP: $HOST_IP
docker run --rm --name="merinorus-pgmodeler" -e DISPLAY=$HOST_IP:0 -v $PROJECT_ROOT/data/root:/root -v $PROJECT_ROOT/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins $PGMODELER_IMAGE