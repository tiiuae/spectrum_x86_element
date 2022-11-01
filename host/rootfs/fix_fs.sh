sudo losetup -o 41943040 /dev/loop30 build/live.img
sudo e2fsck /dev/loop30
sudo losetup -d /dev/loop30
