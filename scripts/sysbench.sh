#! /bin/bash

UTILITY=$1
TYPE=$2
PROJECT_FOLDER=/home/brainfree/playground/io_tests

if [[ -z $UTILITY ]] || [[ -z $TYPE ]]; then
	echo "Usage: # ./sysbench [fio|iozone] [ram|hdd]"
	exit 1
fi

mkdir -p /mnt/sysbench
umount /mnt/sysbench

echo "Inititate benchmarking of $TYPE with the $UTILITY tool."

if [[ $TYPE = "ram" ]]; then
	echo -n "Create ramdisk... "
	modprobe brd rd_size=2621440
	echo "done."
	echo -n "Format ramdisk as ext2... "
	mke2fs -t ext2 -q /dev/ram0
	echo "done."
	echo -n "Mount ramdisk... "
	mount -t ext2 -o noatime /dev/ram0 /mnt/sysbench
	echo "done."
	echo "noop" > /sys/block/ram0/queue/scheduler
	echo "0" > /sys/block/ram0/queue/rotational
fi

if [[ $TYPE = "hdd" ]]; then
	echo -n "Format hdd as ext2... "
	mke2fs -t ext2 -q /dev/sda7
	echo "done."
	echo -n "Mount hdd... "
	mount -t ext2 -o noatime /dev/sda7 /mnt/sysbench
	echo "done."
fi

cd /mnt/sysbench
if [[ $UTILITY = "fio" ]]; then
	for IOENGINE in sync libaio ; do
		for NUMPROCS in 1 2 4 8 ; do
			SIZE="$[512 / $NUMPROCS]"M
			export IOENGINE
			export NUMPROCS
			export SIZE
			RES_FILE="$PROJECT_FOLDER"/results/fio_"$TYPE"_"$IOENGINE""$NUMPROCS"
			echo -n "fio: Benchmarking $TYPE using $IOENGINE engine and $NUMPROCS threads... "
			fio "$PROJECT_FOLDER"/scripts/fio/benchmark.ini > $RES_FILE
			chown brainfree:brainfree $RES_FILE
			echo "done."
		done
	done
elif [[ $UTILITY = "iozone" ]]; then #Currently doing only synchronous read/writes
	for NUMPROCS in 1 2 4 8; do
		SIZE="$[2048 / $NUMPROCS]"M
		RES_FILE="$PROJECT_FOLDER"/results/iozone_"$TYPE""$NUMPROCS".ods
		iozone -i0 -i1 -i2 -s $SIZE -r4K -I -p -c -C -e -t $NUMPROCS -Rb $RES_FILE
		chown brainfree:brainfree $RES_FILE
	done
else
	echo "Unsupported utility"
fi
