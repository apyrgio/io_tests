#! /bin/bash

print_help(){
	echo "List of parameters:"
	echo -e "\t--help, -h:\tprint this message and exit"
	echo -e "\t--dry:\t\tdo not run any benchmarks"
}

while [ -n "$1" ]; do
	if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
		print_help
		exit 0
	elif [[ $1 = "--dry" ]]; then
		DRY=true
	else
		echo "${1}: Unknown command. Exiting..."
		exit 1
	fi
	shift
done

################### START LOGGING #######################
SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
PROJECT_FOLDER=/home/brainfree/playground/io_tests
LOGFILE="$PROJECT_FOLDER"/log/"$SCRIPT_NAME"_"$CUR_DATE".log
( # Parenthesis is VERY important

####################### PARAMETERS #######################
CACHE_SET=ram0			# The SSD
BACKING_DEV=sda7		# The RAID
CACHE_SET_SIZE=2621440	# Cache set size in KB (for ramdisk)
CACHE_SET_OPTS=
BACKING_DEV_OPTS=--writeback
DEVICES_SCRIPT="$PROJECT_FOLDER"/scripts/init.sh
BCACHE_SCRIPT="$PROJECT_FOLDER"/scripts/do_bcache.sh
txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green
DRY=false

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

if [ $DRY ]; then
	echo "Dry run. No benchmark started."
	exit 0
fi

echo "${txtred}######### GATE 3: BENCHMARKS #########${txtrst}"

cd /media/bcache
rm -rf /media/bcache/*
for IOENGINE in sync libaio ; do
	for NUMPROCS in 1 2 4 8 ; do
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

################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
