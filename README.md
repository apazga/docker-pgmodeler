# pgModeler Docker container

This image compiles & run pgModeler inside a Docker container.

## Usage

### Windows

1. Install X11 Manager for Windows, like `vcxsrv` (easiest way is using **winget** or **chocolatey**)

    ```winget install vcxsrv```

    or

    ```choco install vcxsrv```

    And configure it running `XLaunch` for multiple windows, start no client, check "disable access control" and **IMPORTANT**: SAVE the config to Desktop or `%APPDATA%/Xming`

2. Set environment variable (replacing your IP address, using 192.168.1.100 as a sample)

    ```Set-Variable -name DISPLAY -value 192.168.1.100:0.0```

3. Run docker container

    ```docker run -ti -e DISPLAY=$DISPLAY apazga/docker-pgmodeler```

    Use it with volumes if needed (e.g. to save!):

    ```docker run -ti -e DISPLAY=$DISPLAY -v F:\data:/data apazga/docker-pgmodeler:0.9.3```

    You can also specify your DISPLAY IP directly if you don't want to define an environment variable:

    ```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v F:\data:/data apazga/docker-pgmodeler:0.9.3```

#### PowerShell script

To ease launch of pgmodeler, just use `run.ps1`

### Linux

Just run it :)

```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v /home/myname/data:/data apazga/docker-pgmodeler:0.9.3```

or use the provided script `run.sh`.

## Build image

If you want to build the image using the Dockerfile provided (it can take a while!)

```docker build -t apazga/docker-pgmodeler .```

## Tags

- 0.9.1
- 0.9.2-alpha
- 0.9.2-alpha1
- 0.9.2-beta
- 0.9.2
- 0.9.3-beta1
- 0.9.3

Full changelog: <https://github.com/pgmodeler/pgmodeler/blob/v0.9.3/CHANGELOG.md>

## Acknowledgment

Thanks [rkhaotix](https://github.com/rkhaotix) for your amazing work with pgModeler, a reference (and open source) tool to PostgreSQL community.
