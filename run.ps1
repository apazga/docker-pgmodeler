<#
    Script to launch pgModeler on Windows
    - Mounts the data folder next to this script to save pgModeler projects, config and plugins
#>


# These settings are the default ones and should not be modified here, because a "git pull" would override your changes.
# Instead, define your variables in a .env.windows.ps1 file (see .env.windows.ps1.example).
$DISPLAY = 'host.docker.internal:0.0'
$PGMODELER_IMAGE = 'apazga/docker-pgmodeler:latest'
$PROJECT_ROOT = $PSScriptRoot

# Override the variables with those from the .env.windows.ps1 file
$EnvFile = Join-Path $PSScriptRoot '.env.windows.ps1'
if (Test-Path $EnvFile) { . $EnvFile }

$DockerArgs = @(
    'run', '--rm', '-ti',
    '-e', "DISPLAY=$DISPLAY",
    '-v', "$PROJECT_ROOT/data/root:/root",
    '-v', "$PROJECT_ROOT/data/usr/local/lib/pgmodeler/plugins:/usr/local/lib/pgmodeler/plugins",
    $PGMODELER_IMAGE
)
docker @DockerArgs
