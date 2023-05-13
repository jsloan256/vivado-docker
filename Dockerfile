ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION} AS needs-squashing

ARG VIVADO_FILE="Xilinx_Unified_2022.1_0420_0327.tar.gz"
ARG TEMP_PATH=/temp_files/

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -q sudo \
       libgtk2.0-0 dpkg-dev python3-pip libxtst6 default-jre libxrender-dev libxtst-dev \
       twm wget pv vim language-pack-en-base git tig gcc-multilib gzip unzip expect gawk \
       xterm autoconf libtool texinfo libncurses5-dev iproute2 net-tools libssl-dev flex bison \
       libselinux1 screen pax python3-pexpect python3-git python3-jinja2 zlib1g-dev rsync libswt-gtk-4-jni \
       curl gtkterm ocl-icd-libopencl1 opencl-headers g++-multilib zip udev bc libidn11-dev iputils-ping gnome-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 &&  apt-get update &&  \
       DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
       zlib1g:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pyfdt

RUN adduser --disabled-password --gecos '' vivado && \
  usermod -aG sudo vivado && \
  echo "vivado ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN locale-gen en_US.UTF-8 && update-locale

RUN echo "dash dash/sh boolean false" | debconf-set-selections

# Update the library path to include Vivado installed tools
RUN echo "/opt/Xilinx/Vivado/2022.1/tps/lnx64/python-3.8.3/lib" >> /etc/ld.so.conf \
    && echo "/opt/Xilinx/Vivado/2022.1/tps/lnx64/git-1.9.5/lib" >> /etc/ld.so.conf

USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8

RUN sudo adduser vivado dialout

# Install Vivado
WORKDIR /home/vivado/vivado_install_files
COPY install_config.txt ${VIVADO_FILE} ./
RUN sudo chown -R vivado:vivado /home/vivado/vivado_install_files/install_config.txt \
    && sudo chown -R vivado:vivado /home/vivado/vivado_install_files/${VIVADO_FILE} \
    && sudo chown -R vivado:vivado /home/vivado/vivado_install_files \
    && sudo chown -R vivado:vivado /opt \
    && cd /home/vivado/vivado_install_files \
    && cat ${VIVADO_FILE} | tar zx --strip-components=1 \
    && sudo -u vivado -i /home/vivado/vivado_install_files/xsetup --agree XilinxEULA,3rdPartyEULA --batch Install --config /home/vivado/vivado_install_files/install_config.txt \
    && cd ~ \
    && rm -rf /home/vivado/vivado_install_files
 
RUN cd /opt/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers \
    && sudo ./install_drivers

# Set console to bash
RUN sudo ln -sf /bin/bash /bin/sh

# Update the library path to include Vivado installed tools
RUN sudo ldconfig

# Add Vivado tools to the path and installed needed python packages into the Vivado-installed python3 instance
RUN echo "" >> /home/vivado/.bashrc \
    && echo "export PATH=$HOME/bin:$PATH" >> /home/vivado/.bashrc \
    && echo "export VITIS_SKIP_PRELAUNCH_CHECK=true" >> /home/vivado/.bashrc \
    && echo "export PATH=/opt/Xilinx/Vivado/2022.1/tps/lnx64/python-3.8.3/bin:$PATH" >> /home/vivado/.bashrc \
    && echo "pip3.8 install --upgrade pip" >> /home/vivado/.bashrc \
    && echo "pip3.8 install Pillow matplotlib bokeh plotly numpy" >> /home/vivado/.bashrc \
    && echo "source /opt/Xilinx/Vivado/2022.1/settings64.sh" >> /home/vivado/.bashrc \
    && echo "cd ~" >> /home/vivado/.bashrc

FROM scratch
COPY --from=needs-squashing / /
USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8
CMD ["/bin/bash"]
