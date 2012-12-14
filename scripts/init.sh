#! /bin/bash

#######################
# ECHO OUT PARAMETERS #
#######################
echo "${txtred}######### THE GATES ARE OPEN #########${txtrst}"
echo ""
echo "${txtred}######### GATE 1: RAW DEVICES #########${txtrst}"
echo "Cache set: ${txtgrn}/dev/${CACHE_SET}${txtrst}"
echo "Backing device: ${txtgrn}/dev/${BACKING_DEV}${txtrst}"
echo ""

##################
# CREATE DEVICES #
##################


if [[ $CACHE_SET = "ram0" ]]; then
	# Create 16 ramdisks with 2,5GB size each
	echo -n "Create ramdisks with size "$CACHE_SET_SIZE" bytes... "
	modprobe brd rd_size=$CACHE_SET_SIZE
	echo "${txtgrn}done.${txtrst}"
fi

# Format (quietly) the backing device as ext3
echo -n "Format backing device as ext4... "
#mkfs.ext4 /dev/$BACKING_DEV
echo "${txtgrn}done.${txtrst}"
echo ""
