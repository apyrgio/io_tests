############# Benchmark 0: Test DIRECT I/O of RAM
dd if=/dev/zero of=/dev/shm/bcache.tmp bs=1M count=600
losetup /dev/loop0 /dev/shm/bcache.tmp
mkfs.ext4 /dev/loop0
mkdir -p /media/ram_test
mount /dev/loop0 /media/ram_test
RES_FILE=ram_dio_`date +%s`.ods
iozone -az -i 0 -i 1 -i 2 -g 512M -I -f /media/ram_test/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chmod 777 /home/brainfree/io_tests/results/$RES_FILE
umount -l /media/ram_test

############# Benchmark 1:  Test DIRECT I/O to hard drive
mkdir -p /media/hdd
mkfs.ext4 /dev/sda7
mount /dev/sda7 /media/hdd
RES_FILE=hdd_dio_`date +%s`.ods
iozone -az -i 0 -i 1 -i 2 -g 2G -I -f /media/hdd/tmp -Rb /home/brainfree/io_tests/results/$RES_FILE
chmod 777 /home/brainfree/io_tests/results/$RES_FILE






