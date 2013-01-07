#! /bin/bash

./fio_bcache.sh -o ../results/batchos_bcache4k_1
./fio_bcache.sh -o ../results/batchos_bcache4k_2
./fio_bcache.sh -o ../results/batchos_bcache4k_3
mv fio/benchmark32.ini fio/benchmark.ini

./fio_bcache.sh -o ../results/batchos_bcache32k_1
./fio_bcache.sh -o ../results/batchos_bcache32k_2
./fio_bcache.sh -o ../results/batchos_bcache32k_3
mv fio/benchmark512.ini fio/benchmark.ini

./fio_bcache.sh -o ../results/batchos_bcache512k_1
./fio_bcache.sh -o ../results/batchos_bcache512k_2
./fio_bcache.sh -o ../results/batchos_bcache512k_3


