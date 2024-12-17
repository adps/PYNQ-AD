#!/bin/bash

# Install pynq_mlvap

set -e
set -x

. /etc/environment
for f in /etc/profile.d/*.sh; do source $f; done

cd /root
wget https://support.alpha-data.com/pub/pynq/v2.7.0/examples/admxrc9z1/archive/pynq-mlvap-v1.0.0.zip
unzip pynq-mlvap-v1.0.0.zip -d pynq-mlvap
pip install --no-build-isolation pynq-mlvap/
mkdir -p $PYNQ_JUPYTER_NOTEBOOKS/pynq_mlvap
cp -r /usr/local/share/pynq-venv/lib/python3.8/site-packages/pynq_mlvap/notebooks/* $PYNQ_JUPYTER_NOTEBOOKS/pynq_mlvap
rm -rf /root/pynq-mlvap*
