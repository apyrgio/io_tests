#! /bin/bash

#######################
# ECHO OUT PARAMETERS #
#######################
echo "${txtred}######### THE GATES ARE OPEN #########${txtrst}"
echo ""
echo "${txtred}######### GATE 1: DEVICES #########${txtrst}"
echo "Cache set: ${txtgrn}/dev/${CACHE_SET}${txtrst}"
echo "Backing device: ${txtgrn}/dev/${BACKING_DEV}${txtrst}"
echo ""

##################
# CREATE DEVICES #
##################

# Create 16 ramdisks with 2,5GB size each
echo -n "Create ramdisks with size "$CACHE_SET_SIZE" bytes... "
modprobe brd rd_size=$CACHE_SET_SIZE
echo "${txtgrn}done.${txtrst}"

# Format (quietly) the backing device as ext3
echo -n "Format backing device as ext3... "
mkfs -t ext2 -q /dev/$BACKING_DEV
echo "${txtgrn}done.${txtrst}"

echo ""
