#! /bin/bash

#################
#  BCACHE STUFF #
#################

# Format devices

echo "${txtred}######### GATE 2: BCACHE #########${txtrst}"
echo -n "Format cache set... "
CACHE_SET_UUID=`make-bcache -C $CACHE_SET_OPTS /dev/$CACHE_SET | \
   	grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
echo "${txtgrn}done.${txtrst}"
echo -n "Format backing device... "
make-bcache -B $BACKING_DEV_OPTS /dev/$BACKING_DEV > /dev/null
echo "${txtgrn}done.${txtrst}"

# Register and attach

echo -n "Register cache set... "
echo /dev/$CACHE_SET > /sys/fs/bcache/register
echo "${txtgrn}done.${txtrst}"
echo -n "Register backing device... "
echo /dev/$BACKING_DEV > /sys/fs/bcache/register
echo "${txtgrn}done.${txtrst}"
BCACHE_DEV=`ls /sys/block/ | grep bcache`
echo "Bcache virtual device is: ${txtgrn}dev/"$BCACHE_DEV".${txtrst}"
echo -n "Attach ${CACHE_SET} to ${BCACHE_DEV}... "
echo $CACHE_SET_UUID > /sys/block/$BCACHE_DEV/bcache/attach
echo "${txtgrn}done.${txtrst}"

##################
# Customizations #
##################

# Bcache

# Comment the following line to enable writethrough for sequential reads
echo 0 > /sys/block/$BCACHE_DEV/bcache/sequential_cutoff

echo 40 > /sys/block/$BCACHE_DEV/bcache/writeback_percent
#echo 0 > /sys/block/$BCACHE_DEV/bcache/writeback_delay

# Disable congested limits (i.e. when SSD is full with requests,
# do not write them to the hard drive)
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_read_threshold_us
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_write_threshold_us

# Devices

echo noop > /sys/block/${CACHE_SET}/queue/scheduler

######### END OF CUSTOMIZATIONS #########

# Mount the virtual device
echo -n "Format and mount bcache's virtual device... "
mkfs.ext4 -F -q /dev/$BCACHE_DEV
mount -t ext4 -o noatime /dev/$BCACHE_DEV /mnt/bcache
echo "${txtgrn}done.${txtrst}"

echo ""
