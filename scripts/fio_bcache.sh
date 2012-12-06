#! /bin/bash

txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green

################## READ ARGUMENTS ###################

print_help(){
	echo -e "\nList of parameters:"
	echo -e "-h, --help:\tprint this message and exit"
	echo -e "-d, --dry:\tdo not run any benchmarks"
	echo -e "-w, --wait:\twait for writeback to finish between each test"
	exit 0
}

wait_dirty(){
	if [[ ! $WAIT ]]; then return; fi
	echo 1 > /sys/block/$BCACHE_DEV/bcache/writeback_running
	echo -n "Waiting for bcache to finish writeback... "
	BACK_STATE="cat /sys/block/${BCACHE_DEV}/bcache/state"
	while [[ $(eval $BACK_STATE) = "dirty" ]]; do
		sleep 1
	done
	echo "${txtgrn}done.${txtrst}"
}

while [ -n "$1" ]; do
	if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then print_help
	elif [[ $1 = "-d" ]] || [[ $1 = "--dry" ]]; then DRY=0
	elif [[ $1 = "-w" ]] || [[ $1 = "--wait" ]]; then WAIT=0
	else echo "${txtred}${1}: Unknown command${txtrst}"; print_help
	fi
	shift
done

####################### PARAMETERS #######################

SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
PROJECT_FOLDER=/home/brainfree/playground/io_tests
CACHE_SET=ram0			# The SSD
BACKING_DEV=sda7		# The RAID
CACHE_SET_SIZE=2621440	# Cache set size in KB (for ramdisk)
CACHE_SET_OPTS="-b 1024k"
BACKING_DEV_OPTS="--writeback"
DEVICES_SCRIPT="$PROJECT_FOLDER"/scripts/init.sh
BCACHE_SCRIPT="$PROJECT_FOLDER"/scripts/do_bcache.sh

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

cd /media/bcache
rm -rf /media/bcache/*
for IOENGINE in sync libaio ; do
	for NUMPROCS in 1 2 4 8 ; do
		wait_dirty	#will do only when -w or --wait option is given
		SIZE="$[512 / $NUMPROCS]"M
		export IOENGINE
		export NUMPROCS
		export SIZE
		RES_FILE="$PROJECT_FOLDER"/results/"$SCRIPT_NAME"_"$IOENGINE""$NUMPROCS"
		echo -n "fio: Benchmarking bcache using $IOENGINE engine and $NUMPROCS threads... "
		fio "$PROJECT_FOLDER"/scripts/fio/benchmark.ini > $RES_FILE
		echo "${txtgrn}done.${txtrst}"
		rm -rf /media/bcache/*
		chown brainfree:brainfree "$RES_FILE"
	done
done
