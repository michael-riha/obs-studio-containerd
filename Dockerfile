# from -> https://obsproject.com/forum/attachments/dockerfile-obs-txt.104215/ 
# original post -> https://obsproject.com/forum/threads/docker-dev-image.175843/


#Dockerfile for building OBS-studio with two stages. 
#If disk space isn't a problem, you could remove
# the second stage if you you wish
FROM ubuntu:24.04 AS builder


# FROM original post!
# Setup arguments and environment variables
# ARG PACKAGES=" \
#     ninja-build, \
#     pkg-config, \
#     clang-format, \
#     build-essential, \
#     ccache, \
#     git, \
#     wget, \
#     curl, \
#     zsh, \
#     libpulse-dev, \
#     libavcodec-dev, \
#     libavdevice-dev, \
#     libavfilter-dev, \
#     libavformat-dev, \
#     libv4l2rds0, \
#     libv4l-dev, \
#     libavutil-dev, \
#     libswresample-dev, \
#     libswscale-dev, \
#     qt6-base-dev, \
#     qt6-base-private-dev, \
#     libqt6svg6-dev, \
#     qt6-wayland, \
#     qt6-image-formats-plugins, \
#     libx264-dev, \
#     libcurl4-openssl-dev, \
#     libmbedtls-dev, \
#     libgl1-mesa-dev, \
#     libjansson-dev, \
#     libluajit-5.1-dev, \
#     python3-dev, \
#     libx11-dev, \
#     libxcb-randr0-dev, \
#     libxcb-shm0-dev, \
#     libxcb-xinerama0-dev, \
#     libxcb-composite0-dev, \
#     libxcomposite-dev, \
#     libxinerama-dev, \
#     libvlccore-dev, \
#     libvlccore9, \
#     libvlc5, \
#     libvlc-dev, \
#     libxcb1-dev, \
#     libx11-xcb-dev, \
#     libclalsadrv-dev, \
#     libghc-alsa-core-dev, \
#     libalsaplayer-dev, \
#     libxcb-xfixes0-dev, \
#     swig, \
#     libcmocka-dev, \
#     libxss-dev, \
#     libglvnd-dev, \
#     libgles2-mesa-dev, \
#     libwayland-dev, \
#     librist-dev, \
#     libsrt-openssl-dev, \
#     libvpl-dev, \
#     libva-drm2, \
#     libxkbcommon-x11-dev, \
#     libxkbcommon-dev, \
#     libpci-dev, \
#     libva-dev, \
#     libvala-0.56-dev, \
#     libffmpeg-nvenc-dev, \
#     libpipewire-0.3-dev, \
#     libqrcodegencpp-dev, \
#     uthash-dev, \
#     nlohmann-json3-dev, \
#     libwebsocketpp-dev, \
#     libasio-dev, \
#     libspeexdsp-dev, \
#     libdrm-dev" \

# added by Michael Riha https://github.com/obsproject/obs-studio/wiki/build-instructions-for-linux
# Build system dependencies
ARG BUILD_PACKAGES="\
    cmake \
    extra-cmake-modules \
    ninja-build \
    pkg-config \ 
    clang \
    clang-format \
    build-essential \ 
    curl \
    ccache \
    git \
    zsh"

# OBS dependencies (core):
ARG OBS_CORE_PACKAGES="\
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libx264-dev \
    libcurl4-openssl-dev \
    libmbedtls-dev \
    libgl1-mesa-dev \
    libjansson-dev \
    libluajit-5.1-dev \
    python3-dev \
    libx11-dev \
    libxcb-randr0-dev \
    libxcb-shm0-dev \
    libxcb-xinerama0-dev \
    libxcb-composite0-dev \
    libxcomposite-dev \
    libxinerama-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-xfixes0-dev \
    swig \
    libcmocka-dev \
    libxss-dev \
    libglvnd-dev \
    libgles2-mesa-dev \
    libwayland-dev \
    librist-dev \
    libsrt-openssl-dev \
    libpci-dev \
    libpipewire-0.3-dev \
    libqrcodegencpp-dev \
    uthash-dev"

ARG OBS_QT6_UI="\   
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-svg-dev \
    qt6-wayland \
    qt6-image-formats-plugins"

ARG OBS_PLUGIN_DEPENDANCIES="\ 
    libasound2-dev \
    libfdk-aac-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    libjack-jackd2-dev \
    libpulse-dev \
    libsndio-dev \
    libspeexdsp-dev \
    libudev-dev \
    libv4l-dev \
    libva-dev \
    libvlc-dev \
    libvpl-dev \
    libdrm-dev \
    nlohmann-json3-dev \
    libwebsocketpp-dev \
    libasio-dev"

# Merge all packages into one variable
ARG PACKAGES="${BUILD_PACKAGES} \
            ${OBS_CORE_PACKAGES} \
            ${OBS_QT6_UI} \
            ${OBS_PLUGIN_DEPENDANCIES}"

# Create necessary directories
RUN mkdir -p /tmp /home/obs-studio /usr/local/cmake-3.29.3-linux-x86_64


# Install curl to download nanolayer
RUN apt-get update && apt-get install -y curl wget


# Download and extract nanolayer
RUN curl -L "https://github.com/devcontainers-contrib/nanolayer/releases/download/v0.5.6/nanolayer-x86_64-unknown-linux-gnu.tgz" -o /tmp/nanolayer.tgz \
    && tar -xzf /tmp/nanolayer.tgz -C /usr/bin \
    && rm /tmp/nanolayer.tgz


# Install base dependencies using nanolayer
# Nanolayer is a tool that helps you keep your Dockerfile layers small.
#It does so by automatically deleting any installation leftovers
#(such as apt-get update lists, ppas, etc) after the installation is done.
# https://github.com/devcontainers-contrib/nanolayer

# RUN  nanolayer install apt-get ${PACKAGES}
RUN  apt-get update && apt-get install -y ${PACKAGES}

# libs missed in the official docs  https://github.com/obsproject/obs-studio/issues/10873
RUN  apt-get update && apt-get install -y libffmpeg-nvenc-dev

#libs for cef 
RUN  apt-get update && apt-get install -y libnss3

# # Download and install CMake
# RUN wget -O /opt/cmake.sh https://github.com/Kitware/CMake/releases/download/v3.29.3/cmake-3.29.3-linux-x86_64.sh \
#     && chmod +x /opt/cmake.sh \
#     && /opt/cmake.sh --skip-license --prefix=/usr/local --include-subdir


# # Link CMake binaries
# RUN ln -s /usr/local/cmake-3.29.3-linux-x86_64/bin/* /usr/local/bin/


# Clone OBS Studio
RUN git clone --recursive https://github.com/obsproject/obs-studio.git /home/obs-studio


# Download and extract CEF
RUN wget -O /tmp/cef.tar.xz https://cdn-fastly.obsproject.com/downloads/cef_binary_5060_linux_x86_64_v3.tar.xz \
    && tar -xvf /tmp/cef.tar.xz -C /home \
    && rm /tmp/cef.tar.xz

# potential preset https://github.com/obsproject/obs-studio/blob/0b7c1f7081941e2605f1c8bb7ce0907a3901a884/CMakePresets.json#L59-L79
# CMake Vars - https://github.com/obsproject/obs-studio/wiki/building-obs-studio#cmake
RUN cd /home/obs-studio && \
        cmake --preset ubuntu -B docker-build \
        -DENABLE_BROWSER=ON \
        -DENABLE_BROWSER_PANELS=ON \
        -DCEF_ROOT_DIR="/home/cef_binary_5060_linux_x86_64" \
        -DENABLE_WAYLAND=OFF \
        -DQT_VERSION=6
        # -DENABLE_PIPEWIRE=OFF \
        # -DENABLE_AJA=0 \
        # -DENABLE_WEBRTC=0 \
        # 
# RUN cd /home/obs-studio && \
#         cmake -S . -B docker-build -G Ninja \
#         -DCEF_ROOT_DIR="/home/cef_binary_5060_linux_x86_64" \
#         -DENABLE_PIPEWIRE=OFF \
#         -DENABLE_AJA=0 \
#         -DENABLE_WEBRTC=0 \
#         -DQT_VERSION=6
        # -DENABLE_NATIVE_NVENC=OFF;
#     fi



RUN cd /home/obs-studio && \
        cmake --build ./docker-build && cmake --install ./docker-build

RUN ldconfig

ENTRYPOINT [ "obs" ]

# FROM ubuntu:24.04 AS dev_env


# COPY --from=builder /home/obs-studio /home/obs-studio
# COPY --from=builder  /usr/local/cmake-3.29.3-linux-x86_64 /usr/local/cmake-3.29.3-linux-x86_64
# COPY --from=builder  /home/cef_binary_5060_linux_x86_64 /home/cef_binary_5060_linux_x86_64
# COPY --from=builder /usr/bin/nanolayer /usr/bin/nanolayer
# RUN ln -s /usr/local/cmake-3.29.3-linux-x86_64/bin/* /usr/local/bin/