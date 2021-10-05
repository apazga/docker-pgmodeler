<# 
    Script to launch pgModeler
    - Mounts data folder in current directory to save pgModeler projects, config and plugins
#>



Set-Variable -name DISPLAY -value 'host.docker.internal:0.0'

docker run --rm --name="merinorus-pgmodeler" -ti -e DISPLAY=$DISPLAY -v $PSScriptRoot/data/root:/root -v  $PSScriptRoot/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins merinorus/docker-pgmodeler:0.9.4-beta
