# PYNQ-enabled Alpha Data boards

This board repo containes the PYNQ 2.7.0 board files for supported Alpha-Data boards and the necessary build files to build them using [Docker](https://www.docker.com/) and [Jenkins](https://www.jenkins.io/).

## Supported boards

- [ADM-XRC-9Z1](https://alpha-data.com/product/adm-xrc-9z1/)

## Build environment

> [!NOTE] Ubuntu 18.04 or later is recommended for the build host.

Building PYNQ images requires a Linux build host with AMD Xilinx tools 2020.2 with the [Y2K22 patch](https://adaptivesupport.amd.com/s/article/76960?language=en_US), PetaLinux 2020.2, `qemu-user-static` and [Docker](https://docs.docker.com/engine/install/). The provided [Dockerfile](./Dockerfile) is configured for PYNQ image builds, including dependencies to run AMD Xilinx tools and PetaLinux mounted from the host system.

The `alphadata/pynq:v2.7.0` Docker image can be rebuilt for the current user using the following `make` command.

> [!NOTE] The current user will be set up with passwordless sudo privileges which is required for PYNQ image generation.

```bash
cd /path/to/PYNQ-AD
make docker_image
```

The following command will start the container with the `PYNQ-AD` repo mounted under `/workspace/PYNQ-AD` and the AMD Xilinx tools installed on the host, e.g. `/opt/Xilinx`, mounted under the same location. Setting a limit of 8 GB RAM with OOM kill disabled (and 8 CPU cores) is recommended to prevent `Out Of Memory Exceptions (OOME)` killing processes in the container, potentially failing the build.

> [!NOTE] The Docker image is run with the --privileged flag to allow mounting the necessary paths when building the PYNQ image.

```bash
docker run --rm --init --memory 8g --oom-kill-disable --cpus 8 --privileged --volume /path/to/PYNQ-AD:/workspace/PYNQ-AD --volume /tmp --mount type=bind,src=/opt/Xilinx,dst=/opt/Xilinx,ro,consistency=cached -it alphadata/pynq:v2.7.0 bash
```

Inside the container, source Vivado, Vitis and PetaLinx 2020.2 from the mounted location. Optionally specify license server/file location for Vivado.

```bash
source /opt/Xilinx/Vivado/2020.2/settings64.sh
source /opt/Xilinx/Vitis/2020.2/settings64.sh
source /opt/Xilinx/PetaLinux/2020.2/settings.sh
petalinux-util --webtalk off
export LM_LICENSE_FILE=<license server/file location>
```

## Image generation

> [!NOTE] Generating a PYNQ image requires ~50GB free space on the build host.

Once the build environment is correctly set up, the required PYNQ image can be generated inside the Docker container using the following `make` command, where `<board name>` corresponds to the name of a supported Alpha-Data board.

```bash
cd /workspace/PYNQ-AD
make BOARD=<board name>
```

## Building on Jenkins

The provided [Jenkinsfile](./Jenkinsfile) describes an example pipeline to build the [ADM-XRC-9Z1](https://alpha-data.com/product/adm-xrc-9z1/) PYNQ image using Jenkins and Docker. The example Jenkins build node has the `docker` label with the AMD Xilinx tools 2020.2 and PetaLinux 2020.2 installed under `/opt/Xilinx`. The build step uses Alpha-Data's internal license server and archives the final PYNQ image on completion.

## Development notes

### Dealing with `Exec format error`

During the build process if `qemu-user-static` is missing from the host system, the build will fail with an error similar to `chroot: failed to run command 'bash': Exec format error
`. This error can be resolved by installing `qemu-user-static` and running the corresponding [Docker image](https://github.com/multiarch/qemu-user-static) to register the interpreters.

```bash
sudo apt-get install qemu-user-static -y
docker run --rm --privileged multiarch/qemu-user-static --reset --persistent yes
```
