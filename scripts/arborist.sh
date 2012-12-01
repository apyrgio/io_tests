#! /bin/bash

bcache_stats(){
	STATE=`cat /sys/block/${BCACHE_DEV}/bcache/state`
	DIRTY=`cat /sys/block/${BCACHE_DEV}/bcache/dirty_data`
	WRITTEN=?
	BYPASSED=?
	AVAIL=?
	RATIO=`cat /sys/block/${BCACHE_DEV}/bcache/stats_total/cache_hit_ratio`
}

cache_stats(){
	STATE=?
	DIRTY=`cat /sys/block/${CACHE_DEV}/bcache/set/dirty_data`
	WRITTEN=`cat /sys/block/${CACHE_DEV}/bcache/written`
	BYPASSED=`cat /sys/block/${CACHE_DEV}/bcache/set/stats_total/bypassed`
	AVAIL=`cat /sys/block/${CACHE_DEV}/bcache/set/cache_available_percent`
	RATIO=`cat /sys/block/${CACHE_DEV}/bcache/set/stats_total/cache_hit_ratio`
}
	
CACHE_DEV=ram0
echo -e "\t\tDirty\tWritten\tBypassed Avail.\tRatio"

while [ true ]; do
	BCACHE_DEV=`ls /sys/block/ | grep bcache`
	bcache_stats 2>/dev/null
	echo -e "$BCACHE_DEV [$STATE]\t$DIRTY\t$WRITTEN\t$BYPASSED\t$AVAIL\t$RATIO"
	cache_stats 2>/dev/null
	echo -e "$CACHE_DEV [$STATE]\t$DIRTY\t$WRITTEN\t$BYPASSED\t$AVAIL\t$RATIO"
	sleep 1
	tput cuu 2
	tput el 2
done

