# pgModeler Docker container

![Docker Pulls](https://img.shields.io/docker/pulls/apazga/docker-pgmodeler) ![GitHub Repo stars](https://img.shields.io/github/stars/apazga/docker-pgmodeler) [![release](https://github.com/apazga/docker-pgmodeler/actions/workflows/release.yml/badge.svg)](https://github.com/apazga/docker-pgmodeler/actions/workflows/release.yml)

This image compiles & run [pgModeler](https://github.com/nullptrlabs/pgmodeler) inside a Docker container.

New pgModeler releases are built and published automatically every week, for `linux/amd64` and `linux/arm64` (Apple Silicon included).

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

    ```docker run -ti -e DISPLAY=$DISPLAY -v F:\data\root:/root apazga/docker-pgmodeler```

    You can also specify your DISPLAY IP directly if you don't want to define an environment variable:

    ```docker run -ti -e DISPLAY=192.168.1.100:0.0 -v F:\data\root:/root apazga/docker-pgmodeler```

#### Windows (PowerShell script)

To ease launch of pgModeler, use the provided `run.ps1` script. It uses `host.docker.internal:0.0` as DISPLAY and saves your projects, config and plugins in the `data` folder next to the script.

To change these settings, make a copy of `.env.windows.ps1.example`, name it `.env.windows.ps1` and set your values there. Making a copy will avoid losing your settings when you update the repository.

### Linux

Make a copy of the `.env.linux.example` file and name it `.env.linux`. Feel free to modify the environment variables.

Then use the provided script `run.sh`.

### MacOS

Check first [this Medium post](https://yuryalencar.medium.com/pgmodeler-docker-1e78a1cd1350) and [this Gist](https://gist.github.com/yuryalencar/a6c65a1a0a01cbb90e98e66d13072efc) by [@yuryalencar](https://github.com/yuryalencar)

On MacOS (following instructions tested on MacOS Big Sure), if you wish to run this image, you need to install XQuartz. With brew installed, do this:

```brew install --cask xquartz```

Then open XQuartz and allow connections:

```xquartz > preferences > security > [mark to allow connections from network clients]```

Add the following line to your .zshrc or run it in your terminal:

```export DISPLAY=:0```

You can test XQuartz right now with the command `xeyes`. It should launch a little graphical app.

Then make a copy of the `.env.macos.example` file and name it `.env.macos`. Feel free to modify the environment variables.

Finally, make sure XQuartz is started and launch the script `run_macos.sh`.

**NOTE**: The simplest way to ensure that pgModeler is using XQuartz is right-clicking `XQuartz > Apps > Terminal` and run the `run_macos.sh` script.

For using it without a network connection, you can also use the script `run_macos_local.sh`

I may have forgotten some steps, if any problem please open an issue.

## Tags

- `latest`: the highest pgModeler version available, **including alpha and beta releases**.
- `X.Y.Z`, `X.Y.Z-alphaN`, `X.Y.Z-betaN`: a specific pgModeler version.

All the available tags are listed on [Docker Hub](https://hub.docker.com/r/apazga/docker-pgmodeler/tags). New images support `linux/amd64` and `linux/arm64`; some older tags are `linux/amd64` only.

The scripts use `latest` by default. To use a specific version set `PGMODELER_IMAGE` in your `.env` file, e.g. `PGMODELER_IMAGE=apazga/docker-pgmodeler:1.2.3`.

## Build image

If you want to build the image using the Dockerfile provided (it can take a while!), pass the pgModeler version to build:

```docker build --build-arg PG_VERSION=2.0.0-beta1 -t apazga/docker-pgmodeler:2.0.0-beta1 .```

pgModeler 2.x requires Qt 6.6+ and builds on Ubuntu 26.04, the default base image. For 1.x versions use Ubuntu 24.04:

```docker build --build-arg PG_VERSION=1.2.3 --build-arg BASE_IMAGE=ubuntu:24.04 -t apazga/docker-pgmodeler:1.2.3 .```

**Important:** The Dockerfile automatically detects whether you're building version 1.x or 2.x and uses the appropriate build system (qmake for 1.x, CMake for 2.x).

Full changelog: <https://github.com/nullptrlabs/pgmodeler/blob/develop/CHANGELOG.md>


## Contributors

 - [rbrdevs](https://github.com/rbrdevs): PowerShell script (2019, [#1](https://github.com/apazga/docker-pgmodeler/pull/1))
 - [Merinorus](https://github.com/Merinorus): MacOS scripts, `.env` files and PowerShell script enhancement (2021, [#3](https://github.com/apazga/docker-pgmodeler/pull/3))
 - [yuryalencar](https://github.com/yuryalencar): Medium post & Gist for MacOS users (2023)


## Acknowledgment

Thanks [rkhaotix](https://github.com/rkhaotix) for your amazing work with pgModeler, a reference (and open source) tool to PostgreSQL community.
