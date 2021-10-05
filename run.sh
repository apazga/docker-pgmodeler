# Script to launch pgModeler
#  - Use custom IP (192.168.1.100) for DISPLAY environment variable
#  - Mounts ./data folder as /data
docker run -ti -e DISPLAY=192.168.1.100:0.0 -v ./data/root:/root -v ./data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins merinorus/docker-pgmodeler:0.9.4-beta