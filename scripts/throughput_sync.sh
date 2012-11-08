#! /bin/bash

################### START LOGGING #######################
SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
PROJECT_FOLDER=/home/brainfree/playground/io_tests
LOGFILE="$PROJECT_FOLDER"/log/"$SCRIPT_NAME"_"$CUR_DATE".log
( # Parenthesis is VERY important

####################### PARAMETERS #######################
CACHE_SET=ram0		# The SSD
BACKING_DEV=sda7	# The RAID
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
cd /media/bcache
RES_FILE="$PROJECT_FOLDER"/results/"$SCRIPT_NAME"_"$CUR_DATE".ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -k 2 -t 2 -Rb $RES_FILE
chown brainfree:brainfree $RES_FILE

################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
