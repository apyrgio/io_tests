#! /bin/bash

txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green

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
	sleep 1
done
echo "${txtgrn}done${txtrst}"

if [ -n "`lsmod | grep brd`" ]; then
	echo -n "Unloading brd module... "
	rmmod -w brd
	echo "${txtgrn}done${txtrst}"
fi
