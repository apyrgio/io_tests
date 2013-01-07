#! /bin/bash

################## READ ARGUMENTS ###################

source headers.sh

# Check if user has asked for help
if [[ $1 = '-h' ]] || [[ $1 = '--help' ]]; then print_help; fi

# Fist argument: target
if [[ $1 = 'sas' ]] || [[ $1 = 'ssd' ]] || [[ $1 = 'bcache' ]] || \
	[[ $1 = 'ram' ]]; then TARGET=$1; shift
else
	bad_echo "${1}: Incorrect target.\nValid options are [bcache|sas|ssd|ram]"
	exit 1
fi

# Second argument: mode
if [[ $1 = 'fs' ]] || [[ $1 = 'raw' ]]; then
	MODE=$1; shift
else
	bad_echo "${1}: Incorrect mode.\nValid modes are [fs|raw]"
	exit 1
fi

# We iterate over the rest (optional) arguments
while [[ -n $1 ]]; do
	if [[ $1 = '-h' ]] || [[ $1 = '--help' ]]; then print_help
	elif [[ $1 = '-d' ]] || [[ $1 = '--dry' ]]; then DRY=0
	elif [[ ( $1 = '-w' || $1 = '--wait' ) && $TARGET = 'bcache' ]]; then WAIT=0
	elif [[ $1 = "-o" ]] || [[ $1 = "--output" ]]; then create_outdir $1 $2; shift
	else bad_echo "${1}: Unknown command."; print_help
	fi
	shift
done

exit

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
rm -rf ${BCACHE_DIR}/*

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
		rm -rf /mnt/bcache/*
	done
done

echo "${txtgrn}Benchmarks completed.${txtrst}"
