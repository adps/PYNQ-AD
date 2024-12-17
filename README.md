# PYNQ-enabled Alpha Data boards

This board repo containes the PYNQ 2.7.0 board files for supported Alpha Data boards and the necessary files for building them in a Dockerised environment.

## Supported boards

| Board | SD card image |
| ----- | ------------- |
| [ADM-XRC-9Z1](https://alpha-data.com/product/adm-xrc-9z1/) | [v2.7.0](https://support.alpha-data.com/pub/pynq/v2.7.0/images/archive/admxrc9z1-2.7.0-v1.0.0.zip) |

## Clone this repo

> [!NOTE]
> This project depends on the [PYNQ](https://github.com/Xilinx/PYNQ) repository.

```bash
git clone --recurse-submodules https://github.com/adps/PYNQ-AD.git
```

For the rest of the documentation, `/path/to/PYNQ-AD` will refer to the root of the cloned repository.

## Build environment

> [!NOTE]
> Ubuntu 18.04 or later is recommended for the build host.

Building PYNQ images requires a Linux build host with Vitis/Vivado 2020.2 with the [Y2K22 patch](https://adaptivesupport.amd.com/s/article/76960?language=en_US), PetaLinux 2020.2, `qemu-user-static` and [Docker](https://docs.docker.com/engine/install/). The provided [Dockerfile](./Dockerfile) is configured for PYNQ image builds, including dependencies to run Vitis, Vivado and PetaLinux mounted from the host system.

The `alphadata/pynq:v2.7.0` Docker image can be rebuilt for the current user using the following `make` command.

> [!NOTE]
> The current user will be set up with `passwordless sudo` privileges which is required for PYNQ image generation.

```bash
cd /path/to/PYNQ-AD
make docker_image
```

The following command will start the container with the `PYNQ-AD` repo mounted under `/workspace/PYNQ-AD` and Vitis/Vivado/Petalinux installed on the host, e.g. under `/opt/Xilinx`, mounted under the same location. Setting a limit of 8 GB RAM with OOM kill disabled (and 4 CPU cores) is recommended to prevent `Out Of Memory Exceptions (OOME)` killing processes in the container, potentially failing the build.

> [!NOTE]
> The Docker image is run with the `--privileged` flag to allow mounting the necessary paths when building the PYNQ image.
> The 8GB RAM, OOM kill disable and 4 CPU cores are rough guidelines. Adjust allocated resources as needed and available on the build machine. Vivado may try to use more CPU cores than allocated to the container. E.g. on Linux, Vivado uses half of the available CPUs up to the default 8 cores limit (experimental result).

```bash
cd /path/to/PYNQ-AD
docker run --rm --init --memory 8g --oom-kill-disable --cpus 4 --privileged --volume .:/workspace/PYNQ-AD --volume /tmp --mount type=bind,src=/opt/Xilinx,dst=/opt/Xilinx,ro,consistency=cached -it alphadata/pynq:v2.7.0 bash
```

Inside the container, source Vivado, Vitis and PetaLinux 2020.2 from the mounted location. Optionally, specify license server/file location for Vivado.

```bash
source /opt/Xilinx/Vivado/2020.2/settings64.sh
source /opt/Xilinx/Vitis/2020.2/settings64.sh
source /opt/Xilinx/PetaLinux/2020.2/settings.sh
petalinux-util --webtalk off
export LM_LICENSE_FILE=<license server/file location>
```

## Image generation

> [!NOTE]
> Generating a PYNQ image requires ~50GB free space on the build host.

Once the build environment is correctly set up, the required PYNQ image can be generated inside the Docker container using the following `make` command. The `BOARD` variable should match the name of the folder in the [boards](./boards/) directory.

```bash
cd /workspace/PYNQ-AD
make BOARD=<board>
```

## Development notes

### Dealing with `Exec format error`

During the build process if `qemu-user-static` is missing from the host system, the build will fail with an error similar to `chroot: failed to run command 'bash': Exec format error
`. This error can be resolved by installing `qemu-user-static` and running the corresponding [Docker image](https://github.com/multiarch/qemu-user-static) to register the interpreters.

```bash
sudo apt-get install qemu-user-static -y
docker run --rm --privileged multiarch/qemu-user-static --reset --persistent yes
```

### First boot

- After the first boot of a new image, [accessing files on the board using Samba](https://pynq.readthedocs.io/en/v2.7.0/getting_started/pynq_sdcard_getting_started.html?highlight=samba#accessing-files-on-the-board) or [connecting to Jupyter Lab](https://pynq.readthedocs.io/en/v2.7.0/getting_started/pynq_sdcard_getting_started.html?highlight=samba#connecting-to-jupyter-notebook) may time out. Simply reboot the board and subsequent accesses should work.

- When accessing the `/home/xilinx` directory through Samba, there may be a permission issue. Run the following in a Jupyter Lab terminal to resolve this:

    ```bash
    sudo chown xilinx:xilinx /home/xilinx/
    ```
