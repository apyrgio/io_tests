#! /bin/bash

################### START LOGGING #######################
SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
CUR_DATE=`date +"%d-%m-%y_%T"`
LOGFILE=/home/brainfree/io_tests/log/"$SCRIPT_NAME"_"$CUR_DATE".log
( # Parenthesis is VERY important

################### BCACHE PARAMETERS ##################
CACHE_SET=ram0		# The SSD
BACKING_DEV=sda7	# The RAID
CACHE_SET_SIZE=2621440	# Cache set size in KB (for ramdisk)
CACHE_SET_OPTS=
BACKING_DEV_OPTS=--writeback
DEVICES_SCRIPT=/home/brainfree/io_tests/scripts/init.sh
BCACHE_SCRIPT=/home/brainfree/io_tests/scripts/do_bcache.sh

################# PREPARE AND START BCACHE ###############

# Prepare devices
. $DEVICES_SCRIPT

# Format, attach and mount the devices
. $BCACHE_SCRIPT

###################### BENCHMARKS #########################
echo "#################### GATE 3: BENCHMARKS ################"
RES_FILE="$SCRIPT_NAME"_cfq_v1_"$CUR_DATE".ods
iozone -az -i 0 -i 1 -i 2 -n 128M -g 2G -q 32K -I -f /media/bcache/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chown brainfree:brainfree /home/brainfree/io_tests/results/$RES_FILE

RES_FILE="$SCRIPT_NAME"_cfq_v2.1_"$CUR_DATE".ods
iozone -az -i 0 -i 1 -i 2 -n 128M -g 2G -q 32K -I -f /media/bcache/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chown brainfree:brainfree /home/brainfree/io_tests/results/$RES_FILE

RES_FILE="$SCRIPT_NAME"_cfq_v2.2_"$CUR_DATE".ods
iozone -az -i 0 -i 1 -i 2 -n 128M -g 2G -q 32K -I -f /media/bcache/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chown brainfree:brainfree /home/brainfree/io_tests/results/$RES_FILE

################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chown brainfree:brainfree $LOGFILE
######################################################
