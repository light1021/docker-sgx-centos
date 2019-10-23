FROM centos:7.4.1708

COPY ./patches /patches

RUN yum -y install vim git wget openssl-devel libcurl-devel protobuf-devel ocaml ocaml-ocamlbuild python2 && \
    wget https://cmake.org/files/v3.16/cmake-3.16.0-rc2-Linux-x86_64.sh && \
    chmod +x cmake-3.16.0-rc2-Linux-x86_64.sh && \
    ./cmake-3.16.0-rc2-Linux-x86_64.sh --prefix=/usr/local --skip-license && \
    yum -y groupinstall 'Development Tools' && \
    yum clean all && \
    cd /tmp && \
    git clone -b sgx_2.7 https://github.com/01org/linux-sgx.git && \
    cd / && \
    for patch in /patches/*; do patch --prefix=/patches/ -p0 --force "--input=$patch" || exit 1; done && \
    rm -rf /patches && \
    cd /tmp/linux-sgx && \
    ./download_prebuilt.sh && \
    make && \
    make sdk_install_pkg && \
    mkdir -p /opt/intel && \
    /tmp/linux-sgx/linux/installer/bin/sgx_linux_x64_sdk_*.bin --prefix=/opt/intel && \
    make psw_install_pkg && \
    /tmp/linux-sgx/linux/installer/bin/sgx_linux_x64_psw_*.bin && \
    rm -rf /tmp/linux-sgx

COPY ./etc /etc

COPY /opt/intel/sgxssl /opt/intel/

CMD [/usr/bin/bash]
