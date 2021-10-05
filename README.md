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

    ```docker run -ti -e DISPLAY=$DISPLAY merinorus/docker-pgmodeler```

    Use it with volumes if needed (e.g. to save!):

    ```docker run -ti -e DISPLAY=$DISPLAY -v F:\data\root:/root merinorus/docker-pgmodeler:0.9.4-beta```

    You can also specify your DISPLAY IP directly if you don't want to define an environment variable:

    ```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v F:\data\root:/root apazga/docker-pgmodeler:0.9.4-beta```

#### Windows (PowerShell script)

To ease launch of pgmodeler, just use `run.ps1`

### Linux

Just run it :)

```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v /home/myname/data/root:/root merinorus/docker-pgmodeler:0.9.4-beta```

or use the provided script `run.sh`.

### MacOS

On MacOS (following instructions tested on MacOS Big Sure), if you wish to run this image, you need to install XQuartz. With brew installed, do this:

```brew install xquartz```

Then open Xquartz and allow connections:

```xquartz > preferences > security > [mark to allow connections from network clients]```

Add the following line to your .zshrc:

```export DISPLAY=:0```

You can test XQuartz right now with the command `xeyes`. It should launch a little graphical app.

Finally, make sure XQuartz is started and launch the script `run_macos.sh`.

I may have forgotten some steps, if any problem please open an issue.

## Build image

If you want to build the image using the Dockerfile provided (it can take a while!)

```docker build -t merinorus/docker-pgmodeler .```

## Tags

- 0.9.4-beta

Full changelog: <https://github.com/pgmodeler/pgmodeler/blob/v0.9.4-beta/CHANGELOG.md>

## Acknowledgment

Thanks [rkhaotix](https://github.com/rkhaotix) for your amazing work with pgModeler, a reference (and open source) tool to PostgreSQL community.
