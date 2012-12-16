#! /bin/bash

UTILITY=$1
TYPE=$2
PROJECT_FOLDER=/root/playground/io_tests

if [[ -z $UTILITY ]] || [[ -z $TYPE ]]; then
	echo "Usage: # ./sysbench [fio|iozone] [ram|sas|ssd]"
	exit 1
fi

mkdir -p /mnt/sysbench
umount /mnt/sysbench 2>/dev/null

echo "Inititate benchmarking of $TYPE with the $UTILITY tool."

if [[ $TYPE = "ram" ]]; then
	echo -n "Create ramdisk... "
	modprobe brd rd_size=2621440
	echo "done."
	echo -n "Format ramdisk as ext4... "
	mkfs.ext4 -F -q /dev/ram0
	echo "done."
	echo -n "Mount ramdisk... "
	mount -t ext4 -o noatime /dev/ram0 /mnt/sysbench
	echo "done."
	echo "noop" > /sys/block/ram0/queue/scheduler
	echo "0" > /sys/block/ram0/queue/rotational
elif [[ $TYPE = "sas" ]]; then
	echo -n "Format sas as ext4... "
	mkfs.ext4 -F -q /dev/sdc
	echo "done."
	echo -n "Mount sas... "
	mount -t ext4 -o noatime /dev/sdc /mnt/sysbench
	echo "done."
elif [[ $TYPE = "ssd" ]]; then
	echo -n "Format ssd as ext4... "
    mkfs.ext4 -F -q /dev/sdb
    echo "done."
    echo -n "Mount sdd... "
    mount -t ext4 -o noatime /dev/sdb /mnt/sysbench
    echo "done."
	echo "noop" > /sys/block/sdb/queue/scheduler
    echo "0" > /sys/block/sdb/queue/rotational
fi

cd /mnt/sysbench
rm -rf /mnt/sysbench/*
if [[ $UTILITY = "fio" ]]; then
	for IOENGINE in sync libaio ; do
		for NUMPROCS in 1 2 4 8 ; do
			SIZE="$[8 / $NUMPROCS]"G
			export IOENGINE
			export NUMPROCS
			export SIZE
			RES_FILE="$PROJECT_FOLDER"/results/dev100_"$TYPE"_"$IOENGINE""$NUMPROCS"
			echo -n "fio: Benchmarking $TYPE using $IOENGINE engine and $NUMPROCS threads... "
			fio "$PROJECT_FOLDER"/scripts/fio/benchmark.ini > $RES_FILE
			rm -rf /mnt/sysbench/*
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
