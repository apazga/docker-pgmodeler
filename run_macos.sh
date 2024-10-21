# Script to launch pgModeler on macOS
#  - Use host IP for DISPLAY environment variable
#  - Mounts data folder in current directory to save pgModeler projects, config and plugins

# These settings are default one and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a separate .env file.
HOST_IP=$(ifconfig en0 | grep "inet " | cut -d ' ' -f 2)
PGMODELER_IMAGE=apazga/docker-pgmodeler:1.2.0-alpha
PROJECT_ROOT=/Users/abelpaz/Documents/_repos/docker-pgmodeler

# Override environment variables with those from the .env file
. .env.macos

# Add local machine to authorized host by XQuartz
xhost +

echo HOST_IP: $HOST_IP
docker run --rm -e DISPLAY=$HOST_IP:0 -v $PROJECT_ROOT/data/root:/root -v $PROJECT_ROOT/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins $PGMODELER_IMAGE
