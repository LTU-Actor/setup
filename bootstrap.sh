#!/bin/bash

if [ "$(id -u)" == "0" ] && [ -z "$SUDO_USER" ]; then
  echo "Don't run as root."
  exit -1
fi

# ensure root permissions
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
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

apt build-dep -y python python3

sudo -u $SUDO_USER bash << EOF

  if [ ! -e "${HOME}/.local/bin/cquery" ]; then
    mkdir -p "${HOME}/.local/src/"
    mkdir -p "${HOME}/.local/bin/"

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
    make neovim nerd-font-ubuntu-mono git
  fi

  if ! grep -Fq ".local/bin" "${HOME}/.bashrc"; then
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${HOME}/.bashrc"
  fi
EOF
