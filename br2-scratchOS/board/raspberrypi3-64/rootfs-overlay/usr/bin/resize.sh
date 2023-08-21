mount /dev/mmcblk0p1 /boot -o remount,ro
sync

INFO=`fdisk -l /dev/mmcblk0`
END1=$((`echo $INFO | sed -nE 's|^.+/dev/mmcblk0p1 [0-9]+ +([0-9]+).*$|\1|p'` + 1))
SECTORS=$((`echo $INFO | sed -nE 's|^.*Disk /dev/mmcblk0.+ ([0-9]+) sectors.*$|\1|p'` - 1))

fdisk /dev/mmcblk0 <<EOF
d
2
n
p
2
$END1
$SECTORS
w
EOF

sync

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmp /run
mount /dev/mmcblk0p1 /boot -o remount,ro
mount /dev/mmcblk0p2 / -o remount,rw

resize2fs -fp /dev/mmcblk0p2
echo done

rm /home/pi/resize.sh
sleep 5

reboot -f