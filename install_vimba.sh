#!/bin/bash

set -e

if compgen -G "/opt/Vimba*" > /dev/null; then
	echo "Vimba already exists in /opt/! Exiting..."
	exit 0
fi

wget "https://downloads.alliedvision.com/Vimba_v5.0_Linux.tgz" -O "/tmp/Vimba_v5.0_Linux.tgz"

sudo mkdir -p /opt/
sudo tar xf "/tmp/Vimba_v5.0_Linux.tgz" -C /opt/
rm /tmp/Vimba*

sudo /opt/Vimba*/VimbaUSBTL/Install.sh
sudo /opt/Vimba*/VimbaGigETL/Install.sh

echo "Installation scripts have been executed..."
echo "Please log out/in, or reboot before they take effect."
