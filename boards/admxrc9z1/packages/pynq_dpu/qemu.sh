#!/bin/bash

# Install pynq_dpu

set -e
set -x

. /etc/environment
for f in /etc/profile.d/*.sh; do source $f; done

pip install pynq-dpu --no-build-isolation
PYNQ_DPU_INSTALL_ROOT=/usr/local/share/pynq-venv/lib/python3.8/site-packages/pynq_dpu

# Download and copy dpu files for ADM-XRC-9Z1
cd /root
wget https://support.alpha-data.com/pub/pynq/v2.7.0/examples/admxrc9z1/archive/pynq-dpu-v1.0.0.zip
unzip pynq-dpu-v1.0.0.zip
cp pynq-dpu/dpu.bit $PYNQ_DPU_INSTALL_ROOT/dpu.bit
cp pynq-dpu/dpu.hwh $PYNQ_DPU_INSTALL_ROOT/dpu.hwh
cp pynq-dpu/dpu.xclbin $PYNQ_DPU_INSTALL_ROOT/dpu.xclbin
cp pynq-dpu/dpu.xclbin /usr/lib/dpu.xclbin
rm -rf /root/pynq-dpu*
