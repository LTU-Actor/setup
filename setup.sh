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
  python3

if [ ! -e /opt/ros/noetic/ ]; then
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    apt update

    apt install ros-noetic-desktop-full

    source /opt/ros/noetic/setup.bash

    sudo apt install python3-rosdep

    rosdep init

    rosdep update
fi


sudo -u $SUDO_USER bash << EOF

  if ! grep -Fq "/opt/ros" "${HOME}/.bashrc"; then
    echo 'source /opt/ros/noetic/setup.bash' >> "${HOME}/.bashrc"
  fi

EOF

apt install ros-noetic-dbw-polaris

echo "Setup complete. Please close this terminal and open a new one."
