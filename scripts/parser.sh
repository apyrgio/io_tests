#! /bin/bash

## CAVEATS ######################################################
#																#
# 2) Any .ods, .csv file that has the same name as the root will#
#    be deleted.												#
# 3) The csv/ods file that will be created will have as columns #
#    (test jobs) the filenames in the direcory minus the first	#
#    two words, e.g.:											#
#		fio_bcache_libaio1 --> libaio1							#
#		fio_ram_sync2_64k --> sync2_64k							#
# 4) The result numbers must be exactly four in each result		#
#	 file. They must be preceeded by the string "...aggrb=" and	#
#	 followed either by a decimal point and then "MB/s...", or	#
#	 no decimal point and followed by "KB/s..." or "B/s..."		#
#																#
#################################################################

## END RESULT ###################################################
#																#
# The following is the end result in .ods format:				#
# Filename: Root's filename.									#
#                                                               #
#				libaio1    libaio2    sync1    sync2			#
# seq-write      35325     3532532     354      52				#
# rand-write     52466       35353      34      43				#
# seq-read       35325      353553    4355     355				#
# rand-read     335315      335355    3535      34				#
#																#
# Keep in mind that all numbers will be converted in KB/sec.	#
# Also, the .cvs format is like the above, just comma-delimited.#
#																#
#################################################################

if [[ ! -e $1 ]]; then
	echo "Give a valid job directory, you tzakass."
	exit 1
fi

HOME_DIR=$PWD
cd $1
BENCH=`basename $PWD` # The csv/ods files will be named after their dir

# Delete previous ods, csv files
rm -f /tmp/parser_file /tmp/parser_dir ${BENCH}.csv ${BENCH}.ods
ls | grep -v \\. > /tmp/parser_dir # List all result files
# Write the expected format in the csv file
echo -e "\nseq-write\nrand-write\nseq-read\nrand-read" > ${BENCH}.csv

for FILE in `cat /tmp/parser_dir`; do
	grep 'aggrb' $FILE > /tmp/parser_file # Find all lines with "aggrb="
	#... and write to a tmp file "bandwidth [MB|KB|B]" for each row
	sed -i 's/.*aggrb=\([0-9]*.[0-9][0-9]*\)\([A-Z]*\).*/\1 \2/' \
		/tmp/parser_file

	# Cut the first two words out of the result filename to get the actual
	# job name during the benchmark
	TEST=`echo "$FILE" | sed 's/[a-z]*[A-Z]*_[a-z]*[A-Z]*_//'`
	sed -i '1 s/$/,'$TEST'/' ${BENCH}.csv # Append the job name to the end
	COUNT=2									# to end of the row

	for WORD in `cat /tmp/parser_file`; do
		if [[ $WORD = "B" ]]; then
			NUM=$[$NUM / 1024]
		elif [[ $WORD = "MB" ]]; then
			NUM=`${HOME_DIR}/float_mul.py $NUM 1024`
		elif [[ ! $WORD = "KB" ]]; then
			NUM=$WORD
			continue
		fi
		# Finally, convert and append each result to the end of each row
		sed -i ''$COUNT' s/$/,'$NUM'/' ${BENCH}.csv
		COUNT=$[$COUNT+1]
	done
done

echo -n "Waiting for Libreoffice to convert the files.. "
soffice --headless --convert-to ods ${BENCH}.csv > /dev/null
if [[ -e "${BENCH}.ods" ]]; then echo "done."
else echo -e "failed.\nCheck if another instance of Libreoffice is open."
fi
