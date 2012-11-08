#! /bin/bash

################## ECHO OUT PARAMETERS ###############
echo "############### THE GATES ARE OPEN ###############"
echo ""
echo "################ GATE 1: DEVICES ################"
echo "Cache set: /dev/"$CACHE_SET
echo "Backing device: /dev/"$BACKING_DEV
echo ""
echo ""

################## CREATE DEVICES ####################

# Create 16 ramdisks with 2,5GB size each
modprobe brd rd_size=$CACHE_SET_SIZE
echo "Created ramdisks with size "$CACHE_SET_SIZE" bytes" 

# Format (quietly) the backing device as ext3
mkfs -t ext2 -q /dev/$BACKING_DEV
echo "Formated backing device as ext3"
echo ""
