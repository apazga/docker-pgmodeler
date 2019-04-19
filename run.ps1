<# 
    Script to launch pgModeler
    - Use custom IP (192.168.1.100) for DISPLAY environment variable
    - Mounts F:\data folder as /data
#>
Set-Variable -name DISPLAY -value 192.168.1.100:0.0
docker run -ti -e DISPLAY=$DISPLAY -v F:\data:/data apazga/pgmodeler:0.9.2-alpha