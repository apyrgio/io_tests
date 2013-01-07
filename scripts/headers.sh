#! /bin/bash

txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green

bad_echo(){
	echo -e "${txtred}${1}${txtrst}"
}

good_echo(){
	echo -e "${txtgrn}${1}${txtrst}"
}

print_help(){
	echo
	echo -ne "Correct usage: ./kleene_bench [bcache|sas|ssd|ram] [fs|raw] "
	echo -e "<optional parameters\n"
	echo -e "List of parameters:"
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
	good_echo "done."
}

create_outdir(){
	SWITCH=$1
	shift
	if [[ -e $1 ]]; then # Check if dir exists so as not to overwrite data
		bad_echo "${SWITCH}: Directory exists."
		exit 1
	elif [[ $1 = "-"* ]] || [[ -z $1 ]]; then # Check if user has given a dir
		bad_echo "${SWITCH}: You need to specify a dir name."
		exit 1
	fi
	OUT_DIR=$(readlink -f $1)
	if [[ -z $OUT_DIR ]]; then # If readlink fails, then the dir is incorrect
		bad_echo "${SWITCH}: Wrong dir name."
		exit 1
	fi
}

