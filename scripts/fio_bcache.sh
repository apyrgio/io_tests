#! /bin/bash

txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green

################## READ ARGUMENTS ###################

source headers.sh

while [[ -n $1 ]]; do
	if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then print_help
	elif [[ $1 = "-d" ]] || [[ $1 = "--dry" ]]; then DRY=0
	elif [[ $1 = "-w" ]] || [[ $1 = "--wait" ]]; then WAIT=0
	elif [[ $1 = "-o" ]] || [[ $1 = "--output" ]]; then create_outdir $1 $2; shift
	else echo "${txtred}${1}: Unknown command${txtrst}"; print_help
	fi
	shift
done

####################### PARAMETERS #######################

SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
PROJECT_FOLDER=/root/playground/io_tests
CACHE_SET=sdb			# The SSD
BACKING_DEV=sdc			# The RAID
CACHE_SET_SIZE=2621440	# Cache set size in KB (for ramdisk)
CACHE_SET_OPTS="-b 512k"
BACKING_DEV_OPTS="--writeback"
DEVICES_SCRIPT="$PROJECT_FOLDER"/scripts/init.sh
BCACHE_SCRIPT="$PROJECT_FOLDER"/scripts/do_bcache.sh
BCACHE_DIR=/mnt/sysbench

################# PREPARE AND START BCACHE ###############

BCACHE_DEV=`ls /sys/block/ | grep bcache`
if [ -z "$BCACHE_DEV" ]; then
	# Prepare devices
	. $DEVICES_SCRIPT

	# Format, attach and mount the devices
	. $BCACHE_SCRIPT
else
	echo -e "${txtgrn}Bcache is running.\n${txtrst}"
fi

##################### BENCHMARKS ########################

if [[ $DRY ]]; then
	echo "Dry run. No benchmark started."
	exit 0
fi

echo "${txtred}######### GATE 3: BENCHMARKS #########${txtrst}"

if [[ -z $OUT_DIR ]]; then OUT_DIR="$PROJECT_FOLDER"/results; fi

mkdir -p $BCACHE_DIR
cd $BCACHE_DIR
rm ${BCACHE_DIR}/*

for IOENGINE in sync libaio ; do
	for NUMPROCS in 1 2 ; do
		wait_dirty	#will do only when -w or --wait option is given
		SIZE="$[8 / $NUMPROCS]"G
		TIME=1m
		export IOENGINE
		export NUMPROCS
		export SIZE
		export TIME
		RES_FILE="$OUT_DIR"/"$SCRIPT_NAME"_"$IOENGINE""$NUMPROCS"
		echo -n "fio: Benchmarking bcache using $IOENGINE engine and $NUMPROCS threads... "
		fio "$PROJECT_FOLDER"/scripts/fio/benchmark.ini > $RES_FILE
		echo "${txtgrn}done.${txtrst}"
		rm /mnt/bcache/*
	done
done

echo "${txtgrn}Benchmarks completed.${txtrst}"
