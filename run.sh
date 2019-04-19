# Script to launch pgModeler
#  - Use custom IP (192.168.1.100) for DISPLAY environment variable
#  - Mounts F:\data folder as /data
docker run -ti -e DISPLAY=192.168.1.100:0.0 -v /home/myuser:/data apazga/pgmodeler:0.9.1