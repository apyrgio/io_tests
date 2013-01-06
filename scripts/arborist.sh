#! /bin/bash

txtrst=$(tput sgr0) 	# Reset text color
txtred=$(tput setaf 1) 	# Make text red
txtgrn=$(tput setaf 2) 	# Make text green
txtbrn=$(tput setaf 3)	# Make text brown

bcache_stats(){
	STATE=`cat /sys/block/${BCACHE_DEV}/bcache/state`
	DIRTY=`cat /sys/block/${BCACHE_DEV}/bcache/dirty_data`
	WRITTEN=?
	BYPASSED=?
	AVAIL=?
	RATIO=`cat /sys/block/${BCACHE_DEV}/bcache/stats_total/cache_hit_ratio`
	echo -e "$BCACHE_DEV [$STATE]\t$DIRTY\t$WRITTEN\t$BYPASSED\t$AVAIL\t$RATIO"
	LC=$[LC+1]
}

cache_stats(){
	STATE=?
	DIRTY=`cat /sys/block/${CACHE_DEV}/bcache/set/dirty_data`
	WRITTEN=`cat /sys/block/${CACHE_DEV}/bcache/written`
	BYPASSED=`cat /sys/block/${CACHE_DEV}/bcache/set/stats_total/bypassed`
	AVAIL=`cat /sys/block/${CACHE_DEV}/bcache/set/cache_available_percent`
	RATIO=`cat /sys/block/${CACHE_DEV}/bcache/set/stats_total/cache_hit_ratio`
	echo -e "$CACHE_DEV\t [$STATE]\t$DIRTY\t$WRITTEN\t$BYPASSED\t$AVAIL\t$RATIO"
	LC=$[LC+1]
}

dir_stats(){
	ls -oghAti --color --time-style=+"%d-%m-%y_%T" /mnt/sysbench > /tmp/dir_stats.tmp.1
	#sed -i 's/^.\{13\}//' /tmp/dir_stats.tmp.1
	sed -e '1q' /tmp/dir_stats.tmp.1 > /tmp/dir_stats.tmp.2
	sed -i '1d' /tmp/dir_stats.tmp.1
	echo -e "\n${txtbrn}+           ${txtgrn}Stats for /mnt/sysbench         ${txtbrn}+"
	echo "+-------------------------------------------+${txtrst}"
	cat /tmp/dir_stats.tmp.1
	echo "${txtbrn}+-------------------------------------------+${txtrst}"
	cat /tmp/dir_stats.tmp.2
	local LC2=`wc -l /tmp/dir_stats.tmp.1 | sed "s/ \/tmp\/dir_stats.tmp.1//"`
	LC=$[LC+5+LC2]
}

io_stat(){
	echo ""
	tail -n 5 /tmp/io_stat.tmp
	LC=$[LC+6]
}

killall iostat 2>/dev/null
echo ""
iostat -m 1 sdb sdc > /tmp/io_stat.tmp &
CACHE_DEV=sdb
echo -e "${txtgrn}\t\tDirty\tWritten\tBypassed Avail.\tRatio${txtrst}"

while [ true ]; do
	LC=0
	BCACHE_DEV=`ls /sys/block/ | grep bcache`
	bcache_stats 2>/dev/null
	cache_stats 2>/dev/null
	dir_stats 2>/dev/null
	io_stat
	sleep 1		# Sleep for a very small ammount of time
	tput cuu $LC
	tput ed
done

