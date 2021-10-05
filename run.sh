# Script to launch pgModeler on Linux
#  - Use custom IP (192.168.1.100) for DISPLAY environment variable
#  - Mounts data folder in current directory to save pgModeler projects, config and plugins
docker run --rm -ti -e DISPLAY=192.168.1.100:0.0 -v /home/myname/pgmodeler/data/root:/root -v /home/myname/pgmodeler/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins merinorus/docker-pgmodeler:0.9.4-beta