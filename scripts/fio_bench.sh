#! /bin/bash

modprobe brd rd_size=2621440
mke2fs -t ext2 -q /dev/ram0
mount -t ext2 -o noatime /dev/ram0 /media/bcache
echo "noop" > /sys/block/ram0/queue/scheduler
echo "0" > /sys/block/sda/queue/rotational

for IOENGINE in sync libaio posixaio ; do
	for NUMPROCS in 1 2 4 8 ; do
		SIZE=$[500 / $NUMPROCS]
		export IOENGINE
		export NUMPROCS
		export SIZE
		RES_FILE=fio_"$IOENGINE"_"$NUMPROCS"
		fio fio/everything.ini > ../results/fio/"$RES_FILE"
		chown brainfree:brainfree ../results/fio/"$RES_FILE"
	done
done
