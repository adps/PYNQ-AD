#!/bin/bash
source /workspace/xilinx/Vitis/2020.2/settings64.sh &>/dev/null
source /workspace/xilinx/Vivado/2020.2/settings64.sh &>/dev/null
source /workspace/xilinx/petalinux/settings.sh &>/dev/null
petalinux-util --webtalk off &>/dev/null
source /workspace/xilinx/XRT/build/Release/opt/xilinx/xrt/setup.sh &>/dev/null
export LM_LICENSE_FILE=2100@apollo &>/dev/null
/bin/bash
