FROM docker.io/ubuntu:18.04

USER root

RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y --force-yes && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    software-properties-common lsb-core cmake wget sudo git \
    subversion locales cpio nano \
    libxtst6 libx11-6 libtinfo-dev libxrender-dev libfreetype6 libxi6 \
    libncurses5  xterm \
    libncurses5-dev libncursesw5-dev \
    autoconf libtool \
    texinfo gcc-multilib

# Setup host for PYNQ - using file from master branch to get updates for old links
WORKDIR /tmp/work
RUN wget https://raw.githubusercontent.com/Xilinx/PYNQ/refs/heads/master/sdbuild/scripts/setup_host.sh
RUN chmod +x setup_host.sh
RUN bash -c "source /tmp/work/setup_host.sh"
RUN rm -r /tmp/work/*

RUN apt update && apt upgrade -y --force-yes && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    diffstat perl tftpd-hpa python3 libx11-6:i386 libacl1 gnupg zstd \
    iputils-ping mesa-common-dev xz-utils libxcb-xkb-dev \
    libxext6:i386 cython bash liberror-perl sysvinit-utils libgtk2.0-0:i386 \
    google-perftools python3-jinja2 libfontconfig1:i386 pylint3 \
    python3-pexpect libegl1-mesa g++ python3-subunit libxcb-xinerama0-dev \
    zip expect ncurses-dev xtrans-dev util-linux gcc debianutils screen file \
    libxcb-xtest0-dev haveged mtd-utils libxcb-randr0-dev liblz4-tool iproute2 \
    openssl libsm6:i386 xinetd libxcb-shape0-dev python3-git openssh-server \
    putty pax libxrender1:i386 parted

ENV PATH /opt/qemu/bin:/opt/crosstool-ng/bin:$PATH

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

WORKDIR /workspace

# Preload libudev for Vivado when running in Docker
ENV LD_PRELOAD /lib/x86_64-linux-gnu/libudev.so.1:$LD_PRELOAD

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
