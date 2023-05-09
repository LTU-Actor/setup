#!/usr/bin/env bash

mkdir -p ~/actor_ws/src
cd ~/actor_ws/src

# ACtor Code
git clone --recursive https://github.com/LTU-Actor/Core.git
git clone https://github.com/LTU-Actor/setup.git
git clone https://github.com/LTU-Actor/Route-Blob.git
git clone https://github.com/LTU-Actor/Route-Spline.git
git clone https://github.com/LTU-Actor/RPi-eStop-Loop.git
git clone https://github.com/LTU-Actor/Route-Obstacle.git
git clone https://github.com/LTU-Actor/Route-StopSign.git
git clone https://github.com/LTU-Actor/RPi-GPIO.git
git clone https://github.com/LTU-Actor/eStop.git
git clone https://github.com/LTU-Actor/InputProcess-CamAdjust.git
git clone https://github.com/LTU-Actor/Route-Pothole.git
git clone https://github.com/LTU-Actor/Route-Waypoint.git
git clone https://github.com/LTU-Actor/Vehicle-GEM.git

if [[ "$1" == "actor2" ]];then
git clone https://github.com/LTU-Actor/actor2_support.git
fi

# External Deps
# Piksi reconfig
wstool init
wstool set --git ethz_piksi_ros https://github.com/ethz-asl/ethz_piksi_ros.git
wstool update

source /opt/ros/noetic/setup.bash
./ethz_piksi_ros/piksi_multi_cpp/install/prepare-jenkins-slave.sh

wstool merge ethz_piksi_ros/piksi_multi_cpp/install/dependencies_https.rosinstall
wstool update -j8

cd ~/actor_ws
rosdep install --from-paths src --ignore-src -r -y

if ! grep -Fq "~/actor_ws/devel/setup" "/home/${USER}/.bashrc"; then
    echo 'source ~/actor_ws/devel/setup.bash' >> "/home/${USER}/.bashrc"
fi

