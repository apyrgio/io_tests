#! /bin/bash

################### STOP BCACHE #########################
BCACHE_DEV=`ls /sys/block/ | grep bcache`

if [ -z "$BCACHE_DEV" ]; then
	echo "Nothing to destroy. Leaving..."
	exit 0
fi
 
echo 1 > /sys/block/$BCACHE_DEV/bcache/detach
echo 1 > /sys/block/$BCACHE_DEV/bcache/stop
echo 1 > /sys/block/ram0/bcache/set/stop

################### CLEAR DEVICES #######################
umount /media/bcache

echo -n "Waiting for bcache to finish detaching... "
while [ -e /sys/block/$BCACHE_DEV ]; do
	sleep 3
done
echo "Done"

if [ -n "`lsmod | grep brd`" ]; then
	echo -n "Unloading brd module... "
	rmmod -w brd
	echo "Done"
fi
