#!/bin/bash
set -x 

find_loop() {
    LODEV=`losetup -j pbp-bar.img -n -ONAME`
    eval "$1='$LODEV'"
}

dd if=/dev/zero of=pbp-bar.img bs=1M count=256

LODEV=
find_loop LODEV
[ ! -z "$LODEV" ] && sudo losetup -d $LODEV
sudo losetup -P -f pbp-bar.img
find_loop LODEV

if [ -z "$LODEV" ]; then
    echo "Can't find loopback device"
    exit 1
fi

sudo fdisk $LODEV <<EOF
n
p



w
EOF

sudo mkfs.ext4 ${LODEV}p1

MOUNTDIR=$(mktemp -d)

[ -z "$MOUNTDIR" ] && exit
sudo mount ${LODEV}p1 $MOUNTDIR || exit
sudo cp -r bootfs/* $MOUNTDIR/
sudo umount $MOUNTDIR
sudo losetup -d $LODEV
