FROM docker.io/ubuntu:18.04

USER root

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get upgrade -y

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# Install packages necessary to run the bulid and the setup scripts
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    git wget zip software-properties-common lsb-core wget sudo \
    tzdata parted

# Run setup scripts
WORKDIR /tmp/work
COPY scripts/*.sh ./
RUN chmod +x *.sh

# PYNQ
RUN ./setup_host.sh
ENV PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:$PATH

# AMD Xilinx 2020.2 tools
RUN ./installLibs.sh
# Preload libudev for Vivado -> needed when running in Docker
ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1

# PetaLinux
RUN ./plnx-env-setup.sh
# Generate locale data -> needed for PetaLinux
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN rm -rf /tmp/work

# Set terminal type -> needed for tput to work correctly when building on Jenkins
ENV TERM=xterm

# Set up passwordless sudo user with own group using build arguments
WORKDIR /workspace
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
RUN groupadd -g ${GROUP_ID} ${USER_NAME}
RUN useradd -u ${USER_ID} -g ${GROUP_ID} -ms /bin/bash ${USER_NAME}
RUN usermod -aG sudo ${USER_NAME}
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown ${USER_NAME}:${USER_NAME} /workspace
USER ${USER_NAME}
