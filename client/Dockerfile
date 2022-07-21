FROM ros:noetic-ros-base
SHELL ["/bin/bash", "-c"]

ADD sources.list /etc/apt/sources.list
ADD ros.sources.list /etc/apt/sources.list.d/ros1-latest.list
RUN apt-get update    
RUN apt-get install -y --no-install-recommends stow ninja-build git
RUN git config --global http.proxy "http://10.0.0.14:50000"
RUN git config --global https.proxy "http://10.0.0.14:50000"

RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u

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
     cuda-drivers

ADD cartographer /opt/workspace/src/cartographer
ADD cartographer_ros /opt/workspace/src/cartographer_ros
ADD abseil-cpp /opt/workspace/abseil-cpp
WORKDIR /opt/workspace
RUN src/cartographer/scripts/install_abseil.sh
RUN rosdep update && rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y
RUN source /opt/ros/noetic/setup.bash && catkin_make_isolated --install --use-ninja

ADD sim2real_ep /opt/ep_ws/src/sim2real_ep
WORKDIR /opt/ep_ws
RUN source /opt/workspace/devel_isolated/setup.bash && rosdep update && rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y
RUN source /opt/workspace/devel_isolated/setup.bash && catkin_make install --use-ninja