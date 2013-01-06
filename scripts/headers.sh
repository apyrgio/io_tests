#! /bin/bash

print_help(){
	echo -e "\nList of parameters:"
	echo -e "-h, --help:\tprint this message and exit"
	echo -e "-d, --dry:\tdo not run any benchmarks"
	echo -e "-w, --wait:\twait for writeback to finish between each test"
	echo -e "-o [dir], --output [dir]: store results in this folder"
	echo
	exit 0
}

wait_dirty(){
	if [[ ! $WAIT ]]; then return; fi
	echo 1 > /sys/block/$BCACHE_DEV/bcache/writeback_running
	echo -n "Waiting for bcache to finish writeback... "
	BACK_STATE="cat /sys/block/${BCACHE_DEV}/bcache/state"
	while [[ $(eval $BACK_STATE) = "dirty" ]]; do
		sleep 1
	done
	echo "${txtgrn}done.${txtrst}"
}

create_outdir (){
	SWITCH=$1
	shift
	if [[ -e $1 ]]; then #Check if dir exists so as not to overwrite data
		echo "${txtred}Directory exists. Aborting.${txtrst}"
		exit 1
	elif [[ $1 = "-"* ]] || [[ -z $1 ]]; then #Check if user has given a dir
		echo "${txtred}${SWITCH}: You need to specify a dir name.${txtrst}"
		exit 1
	elif ! mkdir $1 ; then #If mkdir fails, then the dir is incorrect
		echo "${txtred}${SWITCH}: Wrong dir name.${txtrst}"
		exit 1
	fi
	OUT_DIR=$(readlink -f $1)
}

