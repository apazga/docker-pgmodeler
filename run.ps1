<# 
    Script to launch pgModeler
    - Use custom IP (192.168.1.100) for DISPLAY environment variable or try to find it automatically
    - Mounts data folder (current directory) as /data
#>

# Use custom IP
# Set-Variable -name DISPLAY -value 192.168.1.100:0.0

# Try to get your LAN IP automatically
Set-Variable -name IPADDR -value ((Get-NetIPAddress).IPAddress -like "192*").Trim()
Set-Variable -name DISPLAY -value 'host.docker.internal:0.0'

docker run --rm --name="merinorus-pgmodeler" -ti -e DISPLAY=$DISPLAY -v $PSScriptRoot/data/root:/root -v  $PSScriptRoot/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins merinorus/docker-pgmodeler:0.9.4-beta
