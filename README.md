# pgModeler Docker container

![Docker Pulls](https://img.shields.io/docker/pulls/apazga/docker-pgmodeler) ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/apazga/docker-pgmodeler)

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

    ```docker run -ti -e DISPLAY=$DISPLAY -v F:\data\root:/root apazga/docker-pgmodeler:1.2.0-alpha1```

    You can also specify your DISPLAY IP directly if you don't want to define an environment variable:

    ```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v F:\data\root:/root apazga/docker-pgmodeler:1.2.0-alpha1```

#### Windows (PowerShell script)

To ease launch of pgmodeler, make a copy of the `run.ps1.example` and name it `run.ps1`. Feel free to modify the environment variables inside the file. Making a copy will avoid losing your settings when you will update the repository.

### Linux


Make a copy of the `.env.linux.example` file and name it `.env.linux`. Feel free to modify the environment variables.


Then use the provided script `run.sh`.

### MacOS

Check first [this Medium post](https://yuryalencar.medium.com/pgmodeler-docker-1e78a1cd1350) and [this Gist](https://gist.github.com/yuryalencar/a6c65a1a0a01cbb90e98e66d13072efc) by [@yuryalencar](https://github.com/yuryalencar)

On MacOS (following instructions tested on MacOS Big Sure), if you wish to run this image, you need to install XQuartz. With brew installed, do this:

```brew install xquartz```

Then open XQuartz and allow connections:

```xquartz > preferences > security > [mark to allow connections from network clients]```

Add the following line to your .zshrc or run it in your terminal:

```export DISPLAY=:0```

You can test XQuartz right now with the command `xeyes`. It should launch a little graphical app.

Then make a copy of the `.env.macos.example` file and name it `.env.macos`. Feel free to modify the environment variables.

Finally, make sure XQuartz is started and launch the script `run_macos.sh`.

**NOTE**: The simplest way to ensure that pgModeler is using XQuartz is right-clicking `XQuartz > Apps > Terminal` and run the `run_macos.sh` script.

I may have forgotten some steps, if any problem please open an issue.

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
- 0.9.4-alpha
- 0.9.4-beta
- 0.9.4-beta1
- 0.9.4
- 1.0.0-alpha
- 1.0.0-alpha1
- 1.0.0-beta
- 1.0.0-beta1
- 1.0.0
- 1.0.1
- 1.0.2
- 1.0.3
- 1.0.4
- 1.1.0-alpha
- 1.0.5
- 1.0.6
- 1.0.7
- 1.1.0
- 1.1.1
- 1.1.2
- 1.1.3
- 1.1.4
- 1.2.0-alpha
- 1.2.0-alpha1

Full changelog: <https://github.com/pgmodeler/pgmodeler/blob/v1.2.0-alpha1/CHANGELOG.md>


## Contributors

 - [rbrdevs](https://github.com/rbrdevs) (PowerShell script enhancement)
 - [Merinorus](https://github.com/Merinorus) (MacOS script & PowerShell script enhancement)
 - [yuryalencar](https://github.com/yuryalencar) (Medium post & Gist for MacOS users)
 
 
## Acknowledgment

Thanks [rkhaotix](https://github.com/rkhaotix) for your amazing work with pgModeler, a reference (and open source) tool to PostgreSQL community.
