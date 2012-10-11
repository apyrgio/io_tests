#! /bin/bash

################### STOP BCACHE #########################
BCACHE_DEV=`ls /sys/block/ | grep bcache`
umount /dev/$BCACHE_DEV
echo 1 > /sys/block/$BCACHE_DEV/bcache/stop
echo 1 > /sys/block/ram0/bcache/set/stop

################### CLEAR DEVICES #######################
if [ -n "`lsmod | grep brd`" ]; then
	echo "Unload brd module"
	rmmod brd
fi
