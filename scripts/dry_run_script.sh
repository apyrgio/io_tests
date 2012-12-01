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
txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green

################# PREPARE AND START BCACHE ###############

# Prepare devices
. $DEVICES_SCRIPT

# Format, attach and mount the devices
. $BCACHE_SCRIPT

###################### BENCHMARKS #########################
echo "${txtred}######### GATE 3: BENCHMARKS #########${txtrst}"
echo "(no benchmark actually...)"
################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
