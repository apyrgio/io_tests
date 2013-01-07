#! /bin/bash

# There is no error checking here. Green messages do not ensure that
# everything truly went as planned.
#
# TO-DO: implement error-checking

#######################
# ECHO OUT PARAMETERS #
#######################
red_echo "######### THE GATES ARE OPEN ##########"
echo
red_echo "######### GATE 1: RAW DEVICES #########"
echo "Cache set: "; grn_echo "/dev/${CACHE_SET}"
echo "Backing device: "; grn_echo "/dev/${BACKING_DEV}"
echo

##################
# CREATE DEVICES #
##################

#This section is most probably deprecated

#if [[ $CACHE_SET = "ram0" ]]; then
#	# Create 16 ramdisks with 2,5GB size each
#	echo -n "Create ramdisks with size "$CACHE_SET_SIZE" bytes... "
#	modprobe brd rd_size=$CACHE_SET_SIZE
#	grn_echo "done."
#fi
#
# Format (quietly) the backing device as ext4
#echo -n "Format backing device as ext4... "
#mkfs.ext4 /dev/$BACKING_DEV
#echo "${txtgrn}done.${txtrst}"
#echo ""

#################
#  BCACHE STUFF #
#################

# Format each device's superblock using make-bcache

red_echo "########### GATE 2: BCACHE ############"
echo -n "Format cache set... "
CACHE_SET_UUID=`make-bcache -C $CACHE_SET_OPTS /dev/$CACHE_SET | \
   	grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
grn_echo "done."
echo -n "Format backing device... "
make-bcache -B $BACKING_DEV_OPTS /dev/$BACKING_DEV > /dev/null
grn_echo "done."

# Register and attach

echo -n "Register cache set... "
echo /dev/$CACHE_SET > /sys/fs/bcache/register
grn_echo "done."
echo -n "Register backing device... "
echo /dev/$BACKING_DEV > /sys/fs/bcache/register
grn_echo "done."
BCACHE_DEV=`ls /sys/block/ | grep bcache`
echo "Bcache virtual device is: "; grn_echo "dev/"$BCACHE_DEV"."
echo -n "Attach ${CACHE_SET} to ${BCACHE_DEV}... "
echo $CACHE_SET_UUID > /sys/block/$BCACHE_DEV/bcache/attach
grn_echo "done."

##################
# Customizations #
##################

# Bcache
#########

# Comment the following line to enable writethrough for sequential reads
#echo 0 > /sys/block/$BCACHE_DEV/bcache/sequential_cutoff

echo 40 > /sys/block/$BCACHE_DEV/bcache/writeback_percent
#echo 0 > /sys/block/$BCACHE_DEV/bcache/writeback_delay

# Disable congested limits (i.e. when SSD is full with requests,
# do not write-around to the backing device)
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_read_threshold_us
echo 0 > /sys/block/$BCACHE_DEV/bcache/cache/congested_write_threshold_us

# Devices
##########

echo noop > /sys/block/${CACHE_SET}/queue/scheduler
echo 0 > /sys/block/$BCACHE_DEV/queue/rotational

##############
# FS or RAW? #
##############

if [[ $MODE = "fs" ]]; then
	# Mount the virtual device
	echo -n "Format and mount bcache's virtual device... "
	mkfs.ext4 -F -q /dev/$BCACHE_DEV
	mount -t ext4 -o noatime,data=writeback,nobh /dev/$BCACHE_DEV $BENCH_DIR
	grn_echo "done."
fi

