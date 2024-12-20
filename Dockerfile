FROM mcr.microsoft.com/devcontainers/base:bionic

USER root

RUN dpkg --add-architecture i386
RUN apt update && apt-get install -y software-properties-common cmake

# Setup host for PYNQ - using file from master branch to get updates for old links
WORKDIR /tmp/work
RUN wget https://raw.githubusercontent.com/Xilinx/PYNQ/refs/heads/master/sdbuild/scripts/setup_host.sh
RUN chmod +x setup_host.sh
RUN bash -c "source /tmp/work/setup_host.sh"
RUN rm -r /tmp/work/*

WORKDIR /workspace

# Install OpenCV 3.4.2
RUN mkdir -p opencv/install
RUN git clone https://github.com/opencv/opencv.git --depth 1 --branch 3.4.2 opencv/source
RUN git clone https://github.com/opencv/opencv_contrib.git --depth 1 --branch 3.4.2 opencv/source_contrib
RUN mkdir -p opencv/source/build
RUN export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LIBRARY_PATH && cd opencv/source/build && \
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/workspace/opencv/install\
        -D WITH_V4L=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/workspace/opencv/source_contrib/modules \
        -D BUILD_TESTS=OFF \
        -D BUILD_ZLIB=ON \
        -D BUILD_JPEG=ON \
        -D WITH_JPEG=ON \
        -D WITH_PNG=ON \
        -D BUILD_EXAMPLES=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D WITH_OPENEXR=OFF \
        -D BUILD_OPENEXR=OFF \
        ..
RUN cd opencv/source/build && make all -j8 && make install
ENV LD_LIBRARY_PATH=/workspace/opencv/install/lib:$LD_LIBRARY_PATH

ENV PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:$PATH

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT source /entrypoint.sh

RUN useradd -ms /bin/bash jenkins
RUN chown jenkins:jenkins /workspace
USER jenkins
