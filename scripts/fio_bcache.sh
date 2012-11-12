#! /bin/bash

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

################# PREPARE AND START BCACHE ###############

# Prepare devices
. $DEVICES_SCRIPT

# Format, attach and mount the devices
. $BCACHE_SCRIPT

###################### BENCHMARKS #########################
echo "#################### GATE 3: BENCHMARKS ################"

for IOENGINE in sync libaio posixaio ; do
	for NUMPROCS in 1 2 4 8 ; do
		SIZE="$[512 / $NUMPROCS]"M
		export IOENGINE
		export NUMPROCS
		export SIZE
		RES_FILE="$PROJECT_FOLDER"/results/fio/"$SCRIPT_NAME"_"$IOENGINE""$NUMPROCS"_"$CUR_DATE"
		fio "$PROJECT_FOLDER"/scripts/fio/everything.ini > "$RES_FILE"
		chown brainfree:brainfree "$RES_FILE"
	done
done


################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
