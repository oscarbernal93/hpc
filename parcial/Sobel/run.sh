#!/bin/bash

#SBATCH --job-name=sobel
#SBATCH --output=results_compartida.txt
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --gres=gpu:1

export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

export CUDA_VISIBLE_DEVICES=0

PG=compartida

i=0
for imagen in imagenes/aguila.jpg imagenes/shadow.jpg imagenes/montanna.jpg imagenes/mago.jpg imagenes/lenna.png imagenes/kafra.jpg imagenes/gatos.jpg imagenes/elefante.jpg imagenes/ciudad.jpg imagenes/chica.jpg
do
  echo "$imagen:"
  for i in `seq 1 20`;
  do
    eval "./$PG $imagen"
  done
done
