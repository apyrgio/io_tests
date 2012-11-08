#! /bin/bash

#################### FORMAT DEVICES ######################
echo "################## GATE 2: FORMATTING ##################"
CACHE_SET_UUID=`make-bcache -C $CACHE_SET_OPTS /dev/$CACHE_SET | grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
echo "Cache set has been formatted"
make-bcache -B $BACKING_DEV_OPTS /dev/$BACKING_DEV
echo "Backing device has been formatted"

# Register and attach
echo /dev/$CACHE_SET > /sys/fs/bcache/register
echo "Cache set has been registered"
echo /dev/$BACKING_DEV > /sys/fs/bcache/register
echo "Backing device has been registered"
BCACHE_DEV=`ls /sys/block/ | grep bcache`
echo "Bcache special device is dev/"$BCACHE_DEV"."
echo $CACHE_SET_UUID > /sys/block/$BCACHE_DEV/bcache/attach

# Customise bcache

# Uncomment to enable writethrough for sequential reads
echo 0 > /sys/block/$BCACHE_DEV/bcache/sequential_cutoff

# Disable congested limits (i.e. when SSD is full with requests,
# do not write them to the hard drive)
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_read_threshold_us
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_write_threshold_us

# Mount the backing device and choose queueing strategy
mkfs -t ext4 -q /dev/$BCACHE_DEV
mount /dev/$BCACHE_DEV /media/bcache
echo "Bcache special device has been formatted and mounted"
