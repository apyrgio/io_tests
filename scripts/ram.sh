#! /bin/bash

cd /media/bcache
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -t 2 -Rb ram_sync_2.ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -k 2 -t 2 -Rb ram_async_2.ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -t 4 -Rb ram_sync_4.ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -k 4 -t 4 -Rb ram_async_4.ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -t 8 -Rb ram_sync_8.ods
iozone -i 0 -i 1 -i 2 -i 8 -s 128M -r 4K -I -k 8 -t 8 -Rb ram_async_8.ods


