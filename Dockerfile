FROM docker.io/ubuntu:20.04

USER root

RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y --force-yes && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    software-properties-common lsb-core cmake wget sudo git \
    subversion locales cpio libncurses-dev nano

# Setup host for PYNQ - using file from master branch to get updates for old links
WORKDIR /tmp/work
RUN wget https://raw.githubusercontent.com/Xilinx/PYNQ/refs/heads/master/sdbuild/scripts/setup_host.sh
RUN chmod +x setup_host.sh
RUN bash -c "source /tmp/work/setup_host.sh"
RUN rm -r /tmp/work/*

WORKDIR /workspace

ENV PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:$PATH

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "source /entrypoint.sh && exec \"$@\"", "--" ]

# Extra config for petalinux
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN groupadd -g 1002 jenkins
RUN useradd -u 1002 -g 1002 -ms /bin/bash jenkins
RUN usermod -aG sudo jenkins
RUN echo '%jenkins ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown jenkins:jenkins /workspace
USER jenkins
