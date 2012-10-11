#! /bin/bash

################### START LOGGING #######################
( # Parenthesis is VERY important
#########################################################

################### PARAMETERS ##########################
SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +%s`
LOGFILE=/home/brainfree/io_tests/log/$SCRIPT_NAME_$CUR_DATE.log

FAST_BDEV=/dev/sdb1
SLOW_BDEV=/dev/sdc1

###################### PURE BCACHE ######################
# Prepare devices
umount -l $SLOW_BDEV
umount -l $FAST_BDEV
mkdosfs $SLOW_BDEV -F16
mkdosfs $FAST_BDEV -F32

# Format devices
CACHE_SET_UUID=`/usr/sbin/make-bcache -C $FAST_BDEV | grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
/usr/sbin/make-bcache -B --writeback $SLOW_BDEV

# Register, attach and mount
echo $SLOW_BDEV > /sys/fs/bcache/register
echo $FAST_BDEV > /sys/fs/bcache/register
echo $CACHE_SET_UUID > /sys/block/bcache0/bcache/attach
dev=`cat /sys/block/bcache0/dev | sed -e 's/:/ /'`
mknod -m 0660 /dev/test b $dev
mkfs -t ext4 /dev/test
mount /dev/test /media/bcache

###################### BENCHMARKS #########################

############# Benchmark 1: Test DIRECT I/O of fast usb as cache for slow usb

RES_FILE=bcache_usb_writeback_dio_`date +%s`.ods
iozone -az -i 0 -i 1 -i 2 -g 256M -I -f /media/bcache/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chmod 777 /home/brainfree/io_tests/results/$RES_FILE


: <<'COMMENT_SECTION'
############# Benchmark 3:  Test writethrough mode

# Unmount devices
umount /media/bcache
rmnod /dev/test
echo 1 > /sys/block/bcache0/bcache/detach
echo 1 > /sys/fs/bcache/164b49ac-b0a2-49cb-822f-56b0974d87da/unregister

# Format devices
CACHE_SET_UUID=`/usr/sbin/make-bcache -C /dev/loop0 | grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
/usr/sbin/make-bcache -B --writeback /dev/sda6

# Register, attach and mount
echo /dev/sda6 > /sys/fs/bcache/register
echo /dev/loop0 > /sys/fs/bcache/register
echo $CACHE_SET_UUID > /sys/block/bcache0/bcache/attach
dev=`cat /sys/block/bcache0/dev | sed -e 's/:/ /'`
mknod -m 0660 /dev/test b $dev
mkfs -t ext4 /dev/test
mount /dev/test /media/bcache
COMMENT_SECTION


################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
######################################################




