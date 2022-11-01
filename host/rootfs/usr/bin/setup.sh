#!/bin/sh

rmmod evbug
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/run/user/0
export WESTON_CONFIG_FILE=/etc/xdg/weston/weston.ini

echo "12345678901264758695847364857456" > /etc/machine-id
mkdir -p /home
adduser ivan -D -h /home/ivan
chown ivan:ivan /home/ivan
chown -R ivan /run/user/0
chown ivan /dev/pts/0
mkdir /tmp && chmod 0777 /tmp
chmod 666 /dev/null
chmod 666 /dev/urandom
chmod 666 /dev/tty
chmod 666 /dev/dri/card0
chmod 666 /dev/dri/renderD128
chmod -R 777  /dev/video*
chmod -R 777 /dev/snd
chmod 777 /dev/snd/*
chmod -R 777 /dev/snd

echo "audio:x:29:root,ivan" >> /etc/group

modprobe e1000

# /nix/store/npknxl8a5lnc451pj3c2sqbpl5qdri5a-electron-19.0.7/bin/electron --enable-features=UseOzonePlatform --ozone-platform=wayland

# chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
echo "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland"  > /home/ivan/chromium.sh
chmod 0777 /home/ivan/chromium.sh

echo "NIXOS_OZONE_WL=1 /nix/store/xs78zrfqcpy3izj19cg5iszy31lqza0d-element-desktop-1.11.5/bin/element-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland" > /home/ivan/element.sh
chmod 0777 /home/ivan/element.sh
udhcpc
