FROM docker.io/ubuntu:20.04

USER root

RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y --force-yes && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    software-properties-common lsb-core cmake wget sudo git \
    subversion locales cpio nano \
    libxtst6 libx11-6 libtinfo-dev libxrender-dev libfreetype6 libxi6 \
    libncurses5  xterm \
    libncurses5-dev libncursesw5-dev \
    lib32ncurses6 autoconf libtool\
    texinfo gcc-multilib

# Setup host for PYNQ - using file from master branch to get updates for old links
WORKDIR /tmp/work
RUN wget https://raw.githubusercontent.com/Xilinx/PYNQ/refs/heads/master/sdbuild/scripts/setup_host.sh
RUN chmod +x setup_host.sh
RUN bash -c "source /tmp/work/setup_host.sh"
RUN rm -r /tmp/work/*

ENV PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:$PATH

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Extra config for petalinux
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN groupadd -g 1001 jenkins
RUN useradd -u 1001 -g 1001 -ms /bin/bash jenkins
RUN usermod -aG sudo jenkins
RUN echo '%jenkins ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown jenkins:jenkins /workspace
USER jenkins
WORKDIR /workspace
