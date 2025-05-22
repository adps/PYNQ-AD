# Docker build environment setup scripts

- [setup_host.sh](./setup_host.sh): PYNQ host setup script taken from [GitHub](https://github.com/Xilinx/PYNQ/blob/v3.0.1/sdbuild/scripts/setup_host.sh).
- [installLibs.sh](./installLibs.sh): AMD Xilinx Vitis 2020.2 library install script taken from local install.
- [plnx-env-setup.sh](./plnx-env-setup.sh): PetaLinux build environment setup script taken from [AMD Adaptive SoC & FPGA Support](https://adaptivesupport.amd.com/s/article/73296). Modified for script-based usage (replaced `apt` with `apt-get` for Ubuntu).
