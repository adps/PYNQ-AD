# PYNQ-enabled Alpha Data boards

This board repo contains the source files to build the PYNQ 2.7.0 images for the supported boards.

## Supported boards

- [ADM-XRC-9Z1](./boards/ADM-XRC-9Z1/)

## Build environment requirements

- Linux - Original build done on `Ubuntu 18.04.6`
- AMD Xilinx tools 2020.2 (Vivado, Vitis)
- PetaLinux 2020.2
- Y2k22 patch for AMD Xilinx tools
- git
- Internet access to download git repos from GitHub and prebuilt source files
- 10GB+ on the partition with `/tmp` for image generation

## Image generation

```bash
make BOARD=<board name>
```
