# Script to launch pgModeler on Linux
#  - Use custom IP (192.168.1.100) for DISPLAY environment variable
#  - Mounts data folder in current directory to save pgModeler projects, config and plugins

# These settings are default one and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a separate .env file.
HOST_IP=192.168.1.100
PGMODELER_IMAGE=apazga/docker-pgmodeler:1.0.3
PROJECT_ROOT=/home/toto/docker-pgmodeler

# Override environment variables with those from the .env file
source .env.linux

docker run --rm -ti -e DISPLAY=$HOST_IP:0.0 -v $PROJECT_ROOT/data/root:/root -v $PROJECT_ROOT/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins $PGMODELER_IMAGE