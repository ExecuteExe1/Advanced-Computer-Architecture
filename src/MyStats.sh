#!/bin/bash

############################################################
# PATHS
############################################################

output_dir="/home/aca/GEM5/results"
outname="l1d_assoc_experiment"

RESULTS_PATH="$output_dir/$outname"

############################################################
# BENCHMARKS
############################################################

BENCHMARKS_LIST=" 473.astar "

############################################################

# CACHE CONFIGURATIONS
############################################################

l1d_sizes="4KiB 8KiB 16KiB 32KiB 64KiB "

l1d_assocs="1 2 4 8"

############################################################
# STATS TO EXTRACT
############################################################

STATS_LIST=(
    "simSeconds"
    "board.cache_hierarchy.l1dcaches.overallHits::total"
    "board.cache_hierarchy.l1dcaches.overallMisses::total"
    "board.cache_hierarchy.l1dcaches.overallAccesses::total"
    "board.cache_hierarchy.l1dcaches.overallAvgMissLatency::total"
    "board.cache_hierarchy.l1dcaches.overallMissRate::total"
)

STATS_NAMES_LIST=(
    "sim_seconds"
    "overall_hits"
    "overall_misses"
    "overall_accesses"
    "avg_miss_latency"
    "miss_ratio"
)

############################################################
# CREATE CASE NAMES
############################################################

case_names=""

for l1d_size in $l1d_sizes
do
    for l1d_assoc in $l1d_assocs
    do

        ####################################################
        # SAME LATENCY MODEL
        ####################################################

        case $l1d_size in
            4KiB)  size_factor=0 ;;
            8KiB)  size_factor=1 ;;
            16KiB) size_factor=2 ;;
            32KiB) size_factor=3 ;;
            64KiB) size_factor=4 ;;
           128KiB) size_factor=5 ;;
           256KiB) size_factor=6 ;;
           512KiB) size_factor=7 ;;
           1024KiB) size_factor=8 ;;
            *)     size_factor=0 ;;
        esac


  case $l1d_assoc in
            2)  assoc_factor=0 ;;
            4)  assoc_factor=1 ;;
            8)  assoc_factor=2 ;;
            16) assoc_factor=3 ;;
            *)  assoc_factor=0 ;;
        esac

        l1d_latency=$((1 + size_factor + assoc_factor))

        case_name="CPU_A_L1D_${l1d_size}_${l1d_assoc}way_LAT_${l1d_latency}"

        case_names+="$case_name "
    done
done

############################################################
# MOVE TO RESULTS DIRECTORY
############################################################

cd "$RESULTS_PATH"

mkdir -p stats

############################################################
# EXTRACT STATS
############################################################

for i in ${!STATS_LIST[@]}
do

    stat=${STATS_LIST[$i]}
    stat_name=${STATS_NAMES_LIST[$i]}
final_csv="${outname}_${stat_name}.csv"

    ########################################################
    # CSV HEADER
    ########################################################

    echo "Configuration,Value" > "$final_csv"

    ########################################################
    # PROCESS BENCHMARKS
    ########################################################

    for benchmark in $BENCHMARKS_LIST
    do

        for case_name in $case_names
        do

            stats_file="$benchmark/$case_name/stats.txt"

            ################################################
            # HANDLE MISSING FILE
            ################################################

            if [[ ! -f "$stats_file" ]]
            then
                echo "$case_name,MISSING" >> "$final_csv"
                continue
            fi

            ################################################
            # EXTRACT VALUE
            ################################################

            stats_value=$(grep -w "$stat" "$stats_file" | tail -1 | awk '{print $2}')

            ################################################
            # HANDLE EMPTY VALUE
################################################

            if [[ -z "$stats_value" ]]
            then
                stats_value="N/A"
            fi

            ################################################
            # WRITE TO CSV
            ################################################

            echo "$case_name,$stats_value" >> "$final_csv"

        done

    done

    ########################################################
    # MOVE TO STATS FOLDER
    ########################################################

    mv "$final_csv" "stats/$final_csv"

done

############################################################
# RETURN
############################################################

cd - > /dev/null

echo "==============================================="
echo "ALL STAT FILES GENERATED"
echo "==============================================="
echo "Saved in:"
echo "$RESULTS_PATH/stats"
echo "==============================================="
