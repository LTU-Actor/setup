#!/bin/bash

set -e

if compgen -G "/opt/Vimba*" > /dev/null; then
	echo "Vimba already exists in /opt/! Skipping..."
else
	wget "https://downloads.alliedvision.com/Vimba_v5.0_Linux.tgz" -O "/tmp/Vimba_v5.0_Linux.tgz"

	sudo mkdir -p /opt/
	sudo tar xf "/tmp/Vimba_v5.0_Linux.tgz" -C /opt/
	rm /tmp/Vimba*

	sudo /opt/Vimba*/VimbaUSBTL/Install.sh
	sudo /opt/Vimba*/VimbaGigETL/Install.sh

	echo "Installation scripts have been executed..."
	echo "Please log out/in, or reboot before they take effect."
fi

if [[ -e ~/actor_ws/src/avt_vimba_camera ]]; then
	echo "ROS node source already cloned, skipping!"
	echo "remove ~/actor_ws/src/avt_vimba_camera to reinstall"
else	
	mkdir -p ~/actor_ws/src
	cd ~/actor_ws/src

	git clone https://github.com/astuff/avt_vimba_camera.git

	# must replace the library files with the recent versions to prevent segfaults on 20.04
	cp -f /opt/Vimba_5_0/VimbaCPP/DynamicLib/x86_64bit/libVimbaC.so avt_vimba_camera/lib/64bit/libVimbaC.so
	cp -f /opt/Vimba_5_0/VimbaCPP/DynamicLib/x86_64bit/libVimbaCPP.so avt_vimba_camera/lib/64bit/libVimbaCPP.so
fi
