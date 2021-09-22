#!/bin/bash

set -e

if [ "$(id -u)" == "0" ] && [ -z "$SUDO_USER" ]; then
  echo "Don't run as root."
  exit -1
fi

# ensure root permissions
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

apt update
apt upgrade -y

apt install -y \
  curl \
  fish \
  vim \
  neovim \
  git \
  nodejs \
  build-essential \
  cmake \
  htop \
  openssh-server \
  clang \
  python \
  python3 \
  silversearcher-ag \
  nodejs \
  npm

if [ ! -e /opt/ros/noetic/ ]; then
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    apt update

    apt install ros-noetic-desktop-full

    source /opt/ros/noetic/setup.bash

    sudo apt install -y python3-rosdep

    rosdep init

    rosdep update

fi

# post ros install
sudo apt install -y \
    python3-rosdep \
    python3-catkin-tools \
    ros-noetic-dbw-polaris \
    ros-noetic-dataspeed-ulc \
    ros-noetic-avt-vimba-camera

echo "$SUDO_USER"
sudo -u $SUDO_USER bash << EOF
    set -e

    if ! grep -Fq "/opt/ros" "/home/${SUDO_USER}/.bashrc"; then
        echo 'adding line to bashrc'
        echo 'source /opt/ros/noetic/setup.bash' >> "/home/${SUDO_USER}/.bashrc"
        echo 'added'
    fi
EOF

sudo apt install -y python-is-python3

echo "Setup complete. Please close this terminal and open a new one."
