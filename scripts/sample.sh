#! /bin/bash

################### START LOGGING #######################
SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
LOGFILE=/home/brainfree/playground/io_tests/log/"$SCRIPT_NAME"_"$CUR_DATE".log
( # Parenthesis is VERY important

################### BCACHE PARAMETERS ##################
CACHE_SET=ram0		# The SSD
BACKING_DEV=sda7	# The RAID
CACHE_SET_SIZE=2621440	# Cache set size in KB (for ramdisk)
CACHE_SET_OPTS=
BACKING_DEV_OPTS=--writeback
DEVICES_SCRIPT=/home/brainfree/playground/io_tests/scripts/init.sh
BCACHE_SCRIPT=/home/brainfree/playground/io_tests/scripts/do_bcache.sh

################# PREPARE AND START BCACHE ###############

# Prepare devices
. $DEVICES_SCRIPT

# Format, attach and mount the devices
. $BCACHE_SCRIPT

###################### BENCHMARKS #########################
echo "#################### GATE 3: BENCHMARKS ################"
RES_FILE="$SCRIPT_NAME"_"$CUR_DATE".ods
cd /media/bcache
iozone -az -i 0 -i 1 -i 2 -n 128M -g 2G -q 32K -I -Rb /home/brainfree/playground/io_tests/results/$RES_FILE
chown brainfree:brainfree /home/brainfree/playground/io_tests/results/$RES_FILE

################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
