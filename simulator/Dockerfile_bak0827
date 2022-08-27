# FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-devel AS BASE
# FROM nvidia/cuda:11.7.0-devel-ubuntu20.04 as BASE
FROM ubuntu:focal AS BASE
SHELL ["/bin/bash", "-c"]

RUN apt-get update \
     -o Acquire::http::proxy=http://10.0.0.14:50000

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get install -q -y --no-install-recommends \
     tzdata ca-certificates \
     -o Acquire::http::proxy=http://10.0.0.14:50000

ADD sources.list /etc/apt/
RUN apt-get update \
     -o Acquire::http::proxy=http://10.0.0.14:50000

RUN apt-get install -y --no-install-recommends \
     linux-headers-$(uname -r) wget gnupg2
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g') && \
     wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin -P /tmp && \
     mv /tmp/cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
     apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/3bf863cc.pub && \
     echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | tee /etc/apt/sources.list.d/cuda.list
RUN apt-get update \
     -o Acquire::http::proxy=http://10.0.0.14:50000
RUN apt-get install -y --no-install-recommends \
     -o Acquire::http::proxy=http://10.0.0.14:50000 \
     cuda cuda-drivers

WORKDIR /opt

FROM BASE AS PYTHON-BUILD
ADD Miniconda3-py37_4.12.0-Linux-x86_64.sh .
RUN ./Miniconda3-py37_4.12.0-Linux-x86_64.sh -b -p /opt/conda -f
RUN /opt/conda/bin/conda init
ENV PATH=/opt/conda/bin:/opt/conda/condabin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD torch-1.12.0+cu116-cp37-cp37m-linux_x86_64.whl .
RUN pip3 install torch-1.12.0+cu116-cp37-cp37m-linux_x86_64.whl

FROM PYTHON-BUILD AS SIM-BUILD
ADD habitat-sim/ /opt/habitat-sim/
WORKDIR /opt/habitat-sim/
RUN pip3 install -r requirements.txt \
     -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install \
     -i https://pypi.tuna.tsinghua.edu.cn/simple \
     numpy==1.21.6
RUN apt-get install -y --no-install-recommends \
     -o Acquire::http::proxy=http://10.0.0.14:50000 \
     cmake git libjpeg-dev libglm-dev libgl1-mesa-glx libegl1-mesa-dev mesa-utils xorg-dev freeglut3-dev
RUN python3 setup.py install --with-cuda --bullet --headless

FROM SIM-BUILD AS LAB-BUILD
ADD habitat-lab/ /opt/habitat-lab/
WORKDIR /opt/habitat-lab/
RUN pip3 install -r requirements.txt \
     -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install protobuf==3.19.1 webdataset==0.1.40 moviepy lmdb tensorboard==2.8.0 ifcfg \
     -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN python3 setup.py develop --all

FROM LAB-BUILD AS ROS-BUILD
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO noetic

RUN apt-get update \
    -o Acquire::http::proxy=http://10.0.0.14:50000 

RUN apt-get install -y --no-install-recommends \
     -o Acquire::http::proxy=http://10.0.0.14:50000 \
     ros-noetic-ros-core=1.5.0-1* \
     ros-noetic-ros-base=1.5.0-1* \
     ros-noetic-depthimage-to-laserscan \
     ros-noetic-laser-scan-matcher \
     ros-noetic-rtabmap-ros \
     ros-noetic-joy \
     ros-noetic-image-view \
     libcanberra-gtk-module libcanberra-gtk3-module 

# install bootstrap tools
RUN pip3 install rosdep rosinstall empy defusedxml netifaces pandas seaborn \
     -i https://pypi.tuna.tsinghua.edu.cn/simple

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

ADD ROS/entrypoint.sh /opt/
