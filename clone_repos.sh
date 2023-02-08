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
git clone --branch v1.11.0 https://github.com/ethz-asl/ethz_piksi_ros.git
mv ~/actor_ws/src/ethz_piksi_ros/piksi_v2_rtk_ros/package.xml ~/actor_ws/src/ethz_piksi_ros/piksi_v2_rtk_ros/package.xml.disabled 2>/dev/null

# Apply python3 patch for piksi
#
# If there are still errors with piksi, you may need to manually update quaternion and numpy
# pip3 install quaternion
# pip3 install -U numpy
cd ~/actor_ws/src/ethz_piksi_ros
if git apply --check ~/actor_ws/src/setup/piksi_py3_patch.patch; then
	git am ~/actor_ws/src/setup/piksi_py3_patch.patch
fi

cd ~/actor_ws
rosdep install --from-paths src --ignore-src -r -y

if ! grep -Fq "~/actor_ws/devel/setup" "/home/${USER}/.bashrc"; then
    echo 'source ~/actor_ws/devel/setup.bash' >> "/home/${USER}/.bashrc"
fi

