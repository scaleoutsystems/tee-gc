# Clone git repos
FROM alpine/git:v2.34.2 as git

# Git heads
ARG GRAMINE_HEAD=v1.1
ARG FEDN_HEAD=develop

# Gramine
WORKDIR /tmp
RUN git clone https://github.com/gramineproject/gramine.git
WORKDIR /tmp/gramine
RUN git checkout $GRAMINE_HEAD

# FEDn
WORKDIR /tmp
RUN git clone https://github.com/scaleoutsystems/fedn.git
WORKDIR /tmp/fedn
RUN git checkout $FEDN_HEAD

# Main container
FROM debian:bookworm-slim

# Build args
ARG SGX_SDK_VERSION=2.16.100.4
ARG SGX_PSW_VERSION=2.15.1
ARG CONDA_VERSION=4.9.2

# Get installers
ADD https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_sdk_${SGX_SDK_VERSION}.bin /tmp/sgx_linux_x64_sdk_${SGX_SDK_VERSION}.bin
ADD https://download.01.org/intel-sgx/sgx-linux/${SGX_PSW_VERSION}/distro/ubuntu20.04-server/sgx_debian_local_repo.tgz /tmp/sgx_debian_local_repo.tgz
ADD https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz /tmp/Python-3.8.9.tar.xz
ADD https://repo.anaconda.com/miniconda/Miniconda3-py39_${CONDA_VERSION}-Linux-x86_64.sh /tmp/Miniconda3-py39_${CONDA_VERSION}-Linux-x86_64.sh
COPY --from=git /tmp/gramine /opt/gramine
COPY --from=git /tmp/fedn/fedn /app/fedn

# Copy configs
COPY config/settings-client.yaml /app/config/settings-client.yaml
COPY config/settings-combiner.yaml /app/config/settings-combiner.yaml
COPY config/settings-reducer.yaml /app/config/settings-reducer.yaml

# Copy conda env
COPY environment.yaml /tmp/environment.yaml

# Copy SGX scripts/files
COPY bin/fedn-sgx /app/fedn-sgx
COPY fedn.manifest.template /app/fedn.manifest.template

# Gramine apt deps
SHELL ["/bin/bash", "-c"]
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    gawk \
    nasm \
    ninja-build \
    wget \
    libcurl4-openssl-dev \
    libprotobuf-c-dev \
    protobuf-c-compiler \
    build-essential \
    gnupg2 \
    linux-headers-amd64 \
    cmake \
    pkg-config \
    zlib1g-dev \
    # SGX SDK
    && chmod +x /tmp/sgx_linux_x64_sdk_${SGX_SDK_VERSION}.bin \
    && /tmp/sgx_linux_x64_sdk_${SGX_SDK_VERSION}.bin --prefix /opt/sgx-sdk \
    && rm /tmp/sgx_linux_x64_sdk_${SGX_SDK_VERSION}.bin \
    #
    # SGX PSW
    && tar xzvf /tmp/sgx_debian_local_repo.tgz \
    && rm /tmp/sgx_debian_local_repo.tgz \
    && mv sgx_debian_local_repo /opt \
    && echo 'deb [trusted=yes] file:///opt/sgx_debian_local_repo focal main' >> /etc/apt/sources.list \
    && echo 'deb [trusted=yes] http://archive.ubuntu.com/ubuntu focal main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
    ubuntu-keyring \
    libsgx-urts \
    libsgx-launch \
    libsgx-epid \
    libsgx-quote-ex \
    libsgx-dcap-ql \
    # 
    # Install conda
    && bash /tmp/Miniconda3-py39_${CONDA_VERSION}-Linux-x86_64.sh -b -p /opt/conda \
    && rm -f /tmp/Miniconda3-py39_${CONDA_VERSION}-Linux-x86_64.sh \
    && ln -s /opt/conda/bin/conda /bin/conda \
    && ln -s /opt/conda/bin/conda-env /bin/conda-env \
    # 
    # Setup default conda env
    && conda env create -f /tmp/environment.yaml \
    && rm /tmp/environment.yaml \
    #
    # Build install gramine
    && mkdir -p /usr/include/asm \
    && ln -s /usr/src/linux-headers-*/arch/x86/include/uapi/asm/sgx.h /usr/include/asm/sgx.h \
    && cd /opt/gramine \
    && conda run -n default meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled --prefix=/opt/conda/envs/default \
    && conda run -n default ninja -C build/ \
    && conda run -n default ninja -C build/ install \
    #
    # Configure FEDn dirs
    && mkdir -p /app \
    && mkdir -p /app/client \
    && mkdir -p /app/certs \
    && mkdir -p /app/client/package \
    && mkdir -p /app/certs \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "default", "/app/fedn-sgx"]