#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..
configs=$base/configs

num_threads=6
device=0

CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/bpe_2000.yaml
