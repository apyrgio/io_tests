#! /bin/bash

export OUT_DIR=../results/batchos_sas4k_1
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas4k_2
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas4k_3
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_ssd4k_1
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd4k_2
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd4k_3
./sysbench.sh fio ssd
mv fio/benchmark32.ini fio/benchmark.ini

export OUT_DIR=../results/batchos_sas32k_1
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas32k_2
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas32k_3
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_ssd32k_1
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd32k_2
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd32k_3
./sysbench.sh fio ssd
mv fio/benchmark512.ini fio/benchmark.ini

export OUT_DIR=../results/batchos_sas512k_1
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas512k_2
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_sas512k_3
./sysbench.sh fio sas
export OUT_DIR=../results/batchos_ssd512k_1
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd512k_2
./sysbench.sh fio ssd
export OUT_DIR=../results/batchos_ssd512k_3
./sysbench.sh fio ssd


