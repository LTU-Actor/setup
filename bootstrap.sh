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

INSTALL_BSPWM=""

if [ "$SUDO_USER" == "mitch" ]; then
  INSTALL_BSPWM="1"
fi

if [ "$SUDO_USER" == "nick" ]; then
  INSTALL_BSPWM="1"
fi

# enable all deb-src in sources.list
sed -i '/^#\sdeb-src /s/^#//' "/etc/apt/sources.list"

apt update
apt upgrade -y

if ! command -v nvim; then
  add-apt-repository ppa:neovim-ppa/stable
  apt update
  apt install -y neovim
fi

apt install -y curl

if ! command -v npm; then
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
fi

if ! command -v openvpn; then
  wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
  echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list
  apt update
  apt install -y openvpn
fi

if ! command -v fish; then
  add-apt-repository ppa:fish-shell/release-2
  apt update
  apt install -y fish
fi

apt install -y \
  vim \
  git \
  nodejs \
  build-essential \
  cmake \
  xfce4 \
  htop \
  openssh-server \
  clang \
  python \
  python3 \
  libclang-6.0-dev \
  clang-6.0 \
  libreadline6-dev \
  libsqlite3-dev \
  liblzma-dev \
  libbz2-dev \
  tk8.5-dev \
  blt-dev \
  libgdbm-dev \
  libssl-dev \
  libncurses5-dev \
  pkg-config

apt build-dep -y python python3

if [ ! -e /opt/ros/kinetic/bin/catkin_make ]; then
  echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
  apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
  apt update
  apt install ros-kinetic-desktop-full
fi

if [ "x$INSTALL_BSPWM" != "x" ]; then
  apt install -y xcb \
    libxcb-util0-dev \
    libxcb-ewmh-dev \
    libxcb-randr0-dev \
    libxcb-icccm4-dev \
    libxcb-keysyms1-dev \
    libxcb-xinerama0-dev \
    libasound2-dev \
    libxcb-xtest0-dev \
    rofi \
    libcairo2-dev \
    libxcb1-dev \
    libxcb-ewmh-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-randr0-dev \
    libxcb-util0-dev \
    libxcb-xkb-dev \
    python-xcbgen \
    xcb-proto \
    libasound2-dev \
    libmpdclient-dev \
    libcurl4-openssl-dev \
    libpulse-dev \
    compton \
    feh \
    thunar \
    xfce4-terminal \
    tilda
fi

sudo -u $SUDO_USER bash << EOF

  set -e

  mkdir -p "${HOME}/.local/src/"
  mkdir -p "${HOME}/.local/bin/"

  if [ ! -e "${HOME}/.local/bin/cquery" ]; then

    if [ ! -d "${HOME}/.local/src/cquery" ]; then
      git clone --recursive https://github.com/cquery-project/cquery.git "${HOME}/.local/src/cquery"
    fi

    rm -rf "${HOME}/.local/src/cquery/build"
    mkdir "${HOME}/.local/src/cquery/build"
    cd "${HOME}/.local/src/cquery/build"

    CC=clang-6.0
    CXX=clang++-6.0
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DSYSTEM_CLANG=ON -DCMAKE_PREFIX_PATH='/usr/lib/llvm-6.0/'
    cmake --build .
    cd ~/.local/bin

    ln -s ../src/cquery/build/cquery .
  fi

  if [ ! -d "${HOME}/dotfiles" ]; then
    git clone https://gitlab.com/pleune/dotfiles.git "${HOME}/dotfiles"
    cd "${HOME}/dotfiles"
    make neovim fonts git
    if [ "x$INSTALL_BSPWM" != "x" ]; then
      make bspwm feh_random_bg
    fi
  fi

  if ! grep -Fq ".local/bin" "${HOME}/.bashrc"; then
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${HOME}/.bashrc"
  fi

  if ! grep -Fq "/opt/ros" "${HOME}/.bashrc"; then
    echo 'source /opt/ros/kinetic/setup.bash' >> "${HOME}/.bashrc"
  fi

  if [ "x$INSTALL_BSPWM" != "x" ]; then
    if [ ! -e "${HOME}/.local/src/bspwm" ]; then
      git clone https://github.com/baskerville/bspwm.git "${HOME}/.local/src/bspwm"
      cd "${HOME}/.local/src/bspwm"
      make
    fi

    if [ ! -e "${HOME}/.local/src/sxhkd" ]; then
      git clone https://github.com/baskerville/sxhkd.git "${HOME}/.local/src/sxhkd"
      cd "${HOME}/.local/src/sxhkd"
      make
    fi

    if [ ! -e "${HOME}/.local/src/polybar" ]; then
      git clone --recursive https://github.com/jaagr/polybar.git "${HOME}/.local/src/polybar"
      cd "${HOME}/.local/src/polybar"
      mkdir build
      cd build
      cmake ..
      make
    fi
  fi

EOF


if [ "x$INSTALL_BSPWM" != "x" ]; then
  cd "${HOME}/.local/src/bspwm"
  make install
  cp contrib/freedesktop/bspwm.desktop /usr/share/xsessions/
  cd "${HOME}/.local/src/sxhkd"
  make install
  cd "${HOME}/.local/src/polybar/build"
  echo POLYLYLYLYLYLYL
  make install
fi
