#!/bin/bash

# Install pynq_composable

set -e
set -x

. /etc/environment
for f in /etc/profile.d/*.sh; do source $f; done

cd /root
git clone --single-branch --branch v1.0.2 https://github.com/Xilinx/PYNQ_Composable_Pipeline
pip install PYNQ_Composable_Pipeline/ --no-build-isolation
rm -rf /root/PYNQ_Composable_Pipeline
