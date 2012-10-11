#! /bin/bash

###################### PURE BCACHE ######################

# Prepare devices
sync; echo 3 > /proc/sys/vm/drop_caches
dd if=/dev/zero of=/dev/shm/bcache.tmp bs=1M count=600
losetup /dev/loop0 /dev/shm/bcache.tmp
mkfs.ext4 /dev/loop0
mkfs.ext4 /dev/sda6

# Format devices
CACHE_SET_UUID=`/usr/sbin/make-bcache -C /dev/loop0 | grep 'Set UUID' | sed -e 's/Set UUID://' -e 's/^[ \t]*//'`
/usr/sbin/make-bcache -B /dev/sda6

# Register, attach and mount
echo /dev/sda6 > /sys/fs/bcache/register
echo /dev/loop0 > /sys/fs/bcache/register
echo $CACHE_SET_UUID > /sys/block/bcache0/bcache/attach
dev=`cat /sys/block/bcache0/dev | sed -e 's/:/ /'`
mknod -m 0660 /dev/test b $dev
mkfs -t ext4 /dev/test
mount /dev/test /media/bcache

###################### BENCHMARKS #########################

############# Benchmark 1: Test DIRECT I/O of RAM as cache for sda6
RES_FILE=bcache_ram_writethrough_dio_`date +%s`.ods
iozone -az -i 0 -i 1 -i 2 -g 512M -I -f /media/bcache/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chmod 777 /home/brainfree/io_tests/results/$RES_FILE

############# Benchmark 2:  Test DIRECT I/O to hard drive
mkdir -p /media/hdd
mkfs.ext4 /dev/sda7
mount /dev/sda7 /media/hdd
RES_FILE=hdd_dio_`date +%s`.ods
iozone -az -i 0 -i 1 -i 2 -g 2G -f /media/hdd/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chmod 777 /home/brainfree/io_tests/results/$RES_FILE
rm -r /media/hdd

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




