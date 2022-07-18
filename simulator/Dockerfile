FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-devel AS BASE
# FROM nvidia/cuda:11.7.0-devel-ubuntu20.04

ADD sources.list /etc/apt/

RUN apt-get update 

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get install -q -y --no-install-recommends tzdata 

WORKDIR /opt

FROM BASE AS SIM-BUILD
ADD habitat-sim/ /opt/habitat-sim/
WORKDIR /opt/habitat-sim/
RUN pip3 install -r requirements.txt \
     -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN apt-get install -y --no-install-recommends \
     -o Acquire::http::proxy=http://10.0.0.14:50000 \
     cmake git libjpeg-dev libglm-dev libgl1-mesa-glx libegl1-mesa-dev mesa-utils xorg-dev freeglut3-dev
RUN python3 setup.py install --with-cuda --bullet

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


FROM ROS-BUILD
ADD ros_x_habitat /opt/workspace/src/ros_x_habitat
WORKDIR /opt/workspace/
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; catkin_make'
WORKDIR /opt/workspace/src/ros_x_habitat/


ENV PYTHONPATH=/opt/ros/noetic/lib/python3/dist-packages:/opt/workspace/devel/lib/python3/dist-packages:/opt/workspace/src/ros_x_habitat
ENV ROS_PACKAGE_PATH=/opt/ros/noetic/share/
# RUN . /opt/ros/$ROS_DISTRO/setup.sh
# RUN echo source "/opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
# RUN echo PYTHONPATH=\$PYTHONPATH:/opt/workspace/devel/lib/python3/dist-packages >> /root/.bashrc

RUN apt-get install -y vim

# CMD /bin/bash -c '. /opt/ros/noetic/setup.bash; python3 -m src.scripts.roam_with_joy --hab-env-config-path ./configs/roam_configs/pointnav_rgbd_roam_mp3d_test_scenes.yaml'
CMD /bin/bash -c '. /opt/ros/noetic/setup.bash; python -m src.nodes.habitat_env_node --node-name sim_env --task-config ./configs/roam_configs/pointnav_rgbd_roam_mp3d_test_scenes.yaml --enable-physics-sim --use-continuous-agent --round 0'

# RUN python3 -m src.scripts.roam_with_joy --hab-env-config-path ./configs/roam_configs/pointnav_rgbd_roam_mp3d_test_scenes.yaml
# -v data/ /opt/workspace/src/ros_x_habitat/data/
