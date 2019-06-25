<# 
    Script to launch pgModeler
    - Use custom IP (192.168.1.100) for DISPLAY environment variable
    - Mounts data folder (current directory) as /data
#>
Set-Variable -name DISPLAY -value 192.168.1.100:0.0
docker run -ti -e DISPLAY=$DISPLAY -v $PSScriptRoot/data:/data apazga/docker-pgmodeler:0.9.2-beta