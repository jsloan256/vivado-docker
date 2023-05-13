# Description
This Docker image runs Ubuntu 18.04 and includes
1. Xilinx Vivado 2022.1

# Required Files
The following files must be downloaded and placed in this folder before building the docker image
1. [Xilinx_Unified_2022.1_0420_0327.tar.gz](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2022.1_0420_0327.tar.gz)

# Build the Docker Image
```console
docker build -t vivado:2022.1 .
```

Building the image creates a runt image (an image with no REPOSITORY name). Delete it manually after building the docker image. The following is an example from a recent build (note that the IMAGE ID will vary):
```console
$ docker image ls
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
vivado       2022.1    71a5e0e7725f   12 hours ago   117GB
<none>       <none>    e1319f8d663b   12 hours ago   196GB
ubuntu       18.04     3941d3b032a8   2 months ago   63.1MB
$ docker image rm e1319f8d663b

```

# Run the Docker Image
## In Linux
```console
docker run -ti -e "TERM=xterm-256color" --network=host -e DISPLAY=$DISPLAY -v $HOME/dev/:/home/vivado/dev/ -v $HOME/.Xilinx:/home/vivado/.Xilinx -e XILINXD_LICENSE_FILE=$XILINXD_LICENSE_FILE -v $HOME/.ssh:/home/vivado/.ssh:ro --name vivado2022.1 vivado:2022.1
```
## In Windows (via Docker Desktop / WSL2)
Must have an x-server (eg. vcXsrv) running at port 0.0
```
docker run -ti -e DISPLAY=host.docker.internal:0.0 --network=host -v c:\dev:/home/vivado/dev/ --name vivado2022.1 vivado:2022.1
```

# Connect to an existing Docker Image
```console
docker exec -e "TERM=xterm-256color" -ti vivado /bin/bash
```

# Export (save) Docker Image to file
```console
docker save vivado:2022.1 | gzip > vivado_2022.1.tar.gz
```

# Import (load) Docker Image from file
```console
docker load -i vivado_2022.1.tar.gz
```

# Validation Tests
Before releasing a new docker image, validate that the following works
1. pip installs packages when container is started
2. `python3` opens python 3.6.9 (ubuntu-installed python)
3. `xterm` opens a GUI terminal
4. `vitis` opens the Xilinx Vitis GUI
5. [HLSCrashCourse](https://github.com/jsloan256/HLSCrashCourse) can build built in Vivado and Linux. Follow the project's [README.md](https://github.com/jsloan256/HLSCrashCourse/blob/main/README.md).
6. [uvm-dpi](https://github.tsc.com/john-sloan/uvm-dpi) example runs (`run.sh` in base folder) without error.
