#!/bin/bash

# kill child processes when this parent process is terminated
trap "kill $$" SIGINT
trap 'kill -HUP 0' EXIT
trap 'kill $(jobs -p) 2> /dev/null' EXIT

############################################################
# GENERAL SETTINGS
############################################################

MAX_THREADS=5
dry_run=0

############################################################
# PATHS
############################################################

SUITE_PATH="/home/aca/GEM5/cpu2006"
SUITE_CPTS_PATH="/home/aca/GEM5/simpoints"

GEM5_PATH="/home/aca/GEM5/gem5"
CONFIG_FILE="$GEM5_PATH/configs/my_confs/run_se.py"

output_dir="/home/aca/GEM5/results"
outname="l1d_assoc_experiment3"

############################################################
# BENCHMARKS
############################################################

BENCHMARKS_LIST=" 473.astar "

############################################################
# FIXED CACHE CONFIGURATIONS
############################################################

# L1 Instruction Cache
l1i_size="8KiB"
l1i_assoc=2
l1i_latency=2

# L2 Cache
l2_size="128KiB"
l2_assoc=8
l2_latency=15

# L3 Cache
l3_size="1024KiB"
l3_assoc=16
l3_latency=40

############################################################
# L1 DATA CACHE CONFIGURATIONS
############################################################

# Fixed sizes
l1d_sizes=" 4KiB 8KiB 16KiB 32KiB 64KiB "

# Associativity sweep
l1d_assocs=" 1 "

############################################################
# CPU TYPE B ONLY
############################################################

issue_width=1
rob_entries=16
iq_entries=8
lsq_entries=8
regs=64

cpu_type="o3"
cpu_clock="3.4GHz"
mem_size="8GiB"
processor_type="switch"
pred_type="TournamentBP"

############################################################
# SIMULATION PARAMETERS
############################################################

warmup_insts=20000000
realsim_insts=30000000

############################################################
# RUN GEM5
############################################################

online_threads=0

for benchmark in $BENCHMARKS_LIST
do
    echo "================================================="
    echo "Benchmark: $benchmark"
    echo "================================================="

    ########################################################
    # Benchmark info
    ########################################################

    benchmark_exe_dir="$SUITE_PATH/$benchmark"

    benchmark_exe_name=`cat $SUITE_PATH/my_base_ref_info/$benchmark/exe_name`

    benchmark_args=`cat $SUITE_PATH/my_base_ref_info/$benchmark/args`

    ########################################################
    # LOOP OVER CONFIGURATIONS
    ########################################################

    for l1d_size in $l1d_sizes
    do
        for l1d_assoc in $l1d_assocs
 do

            ####################################################
            # CALCULATE L1D LATENCY
            ####################################################

            # Size contribution
            case $l1d_size in
                4KiB) size_factor=0 ;;
                8KiB) size_factor=1 ;;
                16KiB) size_factor=2 ;;
                32KiB) size_factor=3 ;;
                64KiB) size_factor=4 ;;
                *) size_factor=0 ;;
            esac

            # Associativity contribution
            case $l1d_assoc in
                2) assoc_factor=0 ;;
                4) assoc_factor=1 ;;
                8) assoc_factor=2 ;;
                16) assoc_factor=3 ;;
                *) assoc_factor=0 ;;
            esac

            # Final latency
            l1d_latency=$((1 + size_factor + assoc_factor))

            ####################################################
            # OUTPUT DIRECTORY
            ####################################################

            comb="CPU_B_L1D_${l1d_size}_${l1d_assoc}way_LAT_${l1d_latency}"

            exec_outdir="$output_dir/$outname/$benchmark/$comb"

            ####################################################
            # CREATE OUTPUT FILES
 ####################################################

            res_file="run"

            prep_cmd="
                mkdir -p $exec_outdir;
                touch $exec_outdir/$res_file.out;
                touch $exec_outdir/$res_file.err;
            "

            if [[ "$dry_run" -eq "1" ]]
            then
                echo "$prep_cmd"
            else
                eval "$prep_cmd"
            fi

            ####################################################
            # PRINT CONFIGURATION
            ####################################################

            echo "---------------------------------------------"
            echo "Running:"
            echo "Benchmark     : $benchmark"
            echo "L1D Size      : $l1d_size"
            echo "L1D Assoc     : $l1d_assoc"
            echo "L1D Latency   : $l1d_latency"
            echo "---------------------------------------------"

            ####################################################
            # RUN GEM5
            ####################################################

            run_gem5_cmd="(
                cd $benchmark_exe_dir;

                $GEM5_PATH/build/X86/gem5.opt \
                -d $exec_outdir \
$CONFIG_FILE \
                $benchmark_exe_dir/$benchmark_exe_name \
                --args='$benchmark_args' \
                --cpt-dir=$SUITE_CPTS_PATH/$benchmark/cpt \
                --l1d-size=$l1d_size \
                --l1d-assoc=$l1d_assoc \
                --l1d-latency=$l1d_latency \
                --l1i-size=$l1i_size \
                --l1i-assoc=$l1i_assoc \
                --l1i-latency=$l1i_latency \
                --l2-size=$l2_size \
                --l2-assoc=$l2_assoc \
                --l2-latency=$l2_latency \
                --l3-size=$l3_size \
                --l3-assoc=$l3_assoc \
                --l3-latency=$l3_latency \
                --cpu-type=$cpu_type \
                --cpu-clock=$cpu_clock \
                --processor-type=$processor_type \
                --mem-size=$mem_size \
                --warmup-insts=$warmup_insts \
                --realsim-insts=$realsim_insts \
                --set-iw \
                --issue-width=$issue_width \
                --rob-entries=$rob_entries \
                --iq-entries=$iq_entries \
                --lsq-entries=$lsq_entries \
                --regs=$regs \
                --set-bp \
                --pred-type=$pred_type \
                1>>$exec_outdir/$res_file.out \
                2>>$exec_outdir/$res_file.err;
            ) &"

            ####################################################
            # EXECUTE OR PRINT
            ####################################################

            if [[ "$dry_run" -eq "1" ]]
            then
                echo "$run_gem5_cmd"
            else
                eval "$run_gem5_cmd"
            fi

            ####################################################
            # THREAD CONTROL
            ####################################################

            online_threads=$((online_threads + 1))

            if [[ "$online_threads" -ge "$MAX_THREADS" ]]
            then
                wait -n
                online_threads=$((online_threads - 1))
            fi

        done
    done
done

############################################################
# WAIT FOR ALL JOBS
############################################################

wait

echo "================================================="
echo "ALL SIMULATIONS FINISHED"
echo "================================================="

