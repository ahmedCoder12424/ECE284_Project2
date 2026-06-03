#!/bin/bash
# -- Automated script for ECE 284 Project 1 --

export GEM5_DIR=~/gem5

echo $1

if [ $1 == '401.bzip2' ]; then
	export BENCHMARK=~/Downloads/Project1_SPEC-master/401.bzip2/src/benchmark
	export ARGUMENT=~/Downloads/Project1_SPEC-master/401.bzip2/data/input.program
	export OUT_DIR=~/Downloads/Project1_SPEC-master/401.bzip2/m5out/
fi

if [ $1 == '429.mcf' ]; then
	export BENCHMARK=~/Downloads/Project1_SPEC-master/429.mcf/src/benchmark
	export ARGUMENT=~/Downloads/Project1_SPEC-master/429.mcf/data/inp.in
	export OUT_DIR=~/Downloads/Project1_SPEC-master/429.mcf/m5out/
fi 

if [ $1 == '456.hmmer' ]; then
	export BENCHMARK=~/Downloads/Project1_SPEC-master/456.hmmer/src/benchmark
	export ARGUMENT=~/Downloads/Project1_SPEC-master/456.hmmer/data/bombesin.hmm.new
	export OUT_DIR=~/Downloads/Project1_SPEC-master/456.hmmer/m5out/

fi
if [ $1 == '458.sjeng' ]; then
	export BENCHMARK=~/Downloads/Project1_SPEC-master/458.sjeng/src/benchmark
	export ARGUMENT=~/Downloads/Project1_SPEC-master/458.sjeng/data/test.txt
	export OUT_DIR=~/Downloads/Project1_SPEC-master/458.sjeng/m5out/
fi
if [ $1 == '470.lbm' ]; then
	export BENCHMARK=~/Downloads/Project1_SPEC-master/470.lbm/src/benchmark
	export ARGUMENT="20 reference.dat 0 1 /home/casp26p1/Downloads/Project1_SPEC-master/470.lbm/data/100_100_130_cf_a.of"
	export OUT_DIR=~/Downloads/Project1_SPEC-master/470.lbm/m5out/
fi 
#401.bzip2
#export BENCHMARK=~/Downloads/Project1_SPEC-master/401.bzip2/src/benchmark
#export ARGUMENT=~/Downloads/Project1_SPEC-master/401.bzip2/data/input.program
#export OUT_DIR=~/Downloads/Project1_SPEC-master/401.bzip2/m5out/

#429.mcf
#export BENCHMARK=~/Downloads/Project1_SPEC-master/429.mcf/src/benchmark
#export ARGUMENT=~/Downloads/Project1_SPEC-master/429.mcf/data/inp.in
#export OUT_DIR=~/Downloads/Project1_SPEC-master/429.mcf/m5out/

#456.hmmer
#export BENCHMARK=~/Downloads/Project1_SPEC-master/456.hmmer/src/benchmark
#export ARGUMENT=~/Downloads/Project1_SPEC-master/456.hmmer/data/bombesin.hmm.new
#export OUT_DIR=~/Downloads/Project1_SPEC-master/456.hmmer/m5out/

#458.sjeng
#export BENCHMARK=~/Downloads/Project1_SPEC-master/458.sjeng/src/benchmark
#export ARGUMENT=~/Downloads/Project1_SPEC-master/458.sjeng/data/test.txt
#export OUT_DIR=~/Downloads/Project1_SPEC-master/458.sjeng/m5out/

#470.lbm
#export BENCHMARK=~/Downloads/Project1_SPEC-master/470.lbm/src/benchmark
#export ARGUMENT="20 reference.dat 0 1 /home/casp26p1/Downloads/Project1_SPEC-master/470.lbm/data/100_100_130_cf_a.of"
#export OUT_DIR=~/Downloads/Project1_SPEC-master/470.lbm/m5out/

mkdir -p $OUT_DIR

# Students can edit these variables to optimize their CPI
CPU_TYPE=${10} #TimingSimpleCPU
#CPU_TYPE=DerivO3CPU
#CPU_TYPE=X86MinorCPU       
MAX_INST=$9   
L1D_SIZE=$2 #128kB
L1I_SIZE=$3  #128kB
L2_SIZE=$4   #1MB
L1D_ASSOC=$5 #2
L1I_ASSOC=$6  #2
L2_ASSOC=$7  #1 
CACHE_LINE=$8 #64

echo "Starting Gem5 Simulation ...":

time $GEM5_DIR/build/X86/gem5.opt -d $OUT_DIR \
    $GEM5_DIR/configs/deprecated/example/se.py \
    -c $BENCHMARK \
    -o "$ARGUMENT" \
    -I $MAX_INST \
    --cpu-type=$CPU_TYPE \
    --caches \
    --l2cache \
    --l1d_size=$L1D_SIZE \
    --l1i_size=$L1I_SIZE \
    --l2_size=$L2_SIZE \
    --l1d_assoc=$L1D_ASSOC \
    --l1i_assoc=$L1I_ASSOC \
    --l2_assoc=$L2_ASSOC \
    --cacheline_size=$CACHE_LINE
