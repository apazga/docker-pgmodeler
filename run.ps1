<# 
    Script to launch pgModeler
    - Mounts data folder in current directory to save pgModeler projects, config and plugins
#>


# These settings are default one and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a separate .env file.
Set-Variable -name DISPLAY -value 'host.docker.internal:0.0'
Set-Variable -name PGMODELER_IMAGE -value 'apazga/docker-pgmodeler:1.0.0-alpha'
Set-Variable -name PROJECT_ROOT -value $PSScriptRoot


docker run --rm -ti -e DISPLAY=$DISPLAY -v $PROJECT_ROOT/data/root:/root -v  $PROJECT_ROOT/data/usr/local/lib/docker-pgmodeler/plugins:/usr/local/lib/docker-pgmodeler/plugins $PGMODELER_IMAGE
