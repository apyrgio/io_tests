#! /bin/bash

SCRIPT_NAME=`echo "${0##*/}" | sed 's/.sh//'`
echo "$SCRIPT_NAME"
CUR_DATE=`date +%s`
LOGFILE=/home/brainfree/io_tests/log/"$SCRIPT_NAME"_"$CUR_DATE".log

################### START LOGGING #######################
( # Parenthesis is VERY important
#########################################################

################### PARAMETERS ##########################

FAST_BDEV=/dev/loop0
SLOW_BDEV=/dev/sda6
OPTS=--writeback

echo "$LOGFILE"
. /home/brainfree/io_tests/scripts/testit2.sh

################### STOP LOGGING #####################
) 2>&1 | tee $LOGFILE
chmod 777 $LOGFILE
######################################################
