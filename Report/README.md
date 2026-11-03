# L1 Data Cache Performance Analysis Using gem5

**Computer Architecture | Microarchitecture Simulation | Memory Hierarchy Optimization**

This project investigates how **L1 data cache (L1D) capacity, set associativity, and access latency** affect processor performance. Using the **gem5 architectural simulator**, I evaluated multiple cache configurations on two CPU models with different microarchitectural resources and compared their behavior across SPEC CPU workloads.

The goal is to identify configurations that minimize execution time—not simply cache miss rate—and explain the results using **Average Memory Access Time (AMAT)** and workload-specific memory behavior.

## Project objectives

- Explore the trade-off between L1D cache capacity, associativity, hit latency, and miss penalty.
- Compare how two processor configurations respond to the same memory-hierarchy changes.
- Automate simulation runs, extract statistics, and visualize performance trends.
- Identify promising L1D configurations for each benchmark based primarily on execution time.

## Experimental setup

Both CPU configurations use the following **fixed** memory hierarchy outside the L1 data cache:

| Component | Configuration |
| --- | --- |
| L1 instruction cache | 8 KiB, 2-way, latency 2 |
| L2 cache | 128 KiB, 8-way, latency 15 |
| L3 cache | 1024 KiB, 16-way, latency 40 |
| Cache line size | 64 bytes at every cache level |

The two CPU models differ in their execution resources:

| Parameter | CPU A | CPU B |
| --- | ---: | ---: |
| Issue width | 8 | 1 |
| Reorder buffer entries | 192 | 16 |
| Instruction queue entries | 64 | 8 |
| Load/store queue entries | 32 | 8 |
| Physical registers | 256 | 64 |

CPU A has substantially more resources for overlapping work and potentially hiding memory latency; CPU B is more resource-constrained.

### L1D configurations explored

- **CPU A:** cache capacities from **4 to 512 KiB**, with 2-way, 4-way, 8-way, and fully associative alternatives.
- **CPU B:** cache capacities from **4 to 64 KiB**, with up to 8-way and fully associative alternatives, as investigated in the report.
- Cache access latency was adjusted as the configurations changed, rather than assuming all cache designs have identical hit times.

### Benchmarks

The report examines the following SPEC CPU workloads:

| CPU A | CPU B |
| --- | --- |
| `483.xalancbmk` | `400.perlbench` |
| `462.libquantum` | `462.libquantum` |
| `470.lbm` | `470.lbm` |
| `471.omnetpp` | `471.omnetpp` |
| `473.astar` | `473.astar` |

## Methodology

1. **Run gem5 simulations** for the chosen cache capacities and associativity levels, modifying cache latency as needed.
2. **Collect cache statistics** for each benchmark and configuration.
3. **Export the measurements to CSV** for repeatable analysis.
4. **Generate MATLAB plots** to study execution time, miss ratio, and average miss latency.
5. **Compare configurations** using execution time as the main selection criterion, with AMAT as an explanatory metric.

The analysis uses:

\[
\mathrm{AMAT} = \mathrm{Hit\ Time} + (\mathrm{Miss\ Rate} \times \mathrm{Miss\ Penalty})
\]

The report also examines **total cache accesses, hits, misses, miss ratio, and overall average miss latency (OAML)**. Importantly, a lower miss ratio does not always imply a shorter execution time when cache access costs increase.

## Repository organization

- **`A/`** — MATLAB scripts associated with **CPU A**. Running the plotting scripts produces diagrams of the collected simulation statistics; these visualizations were used in the report.
- **`B/`** — MATLAB scripts associated with **CPU B**, serving the same purpose for the second processor configuration.
- **Bash simulation scripts** — The report describes scripts such as `4to64KiB2to16way.sh` and `128to512KiB2to16way.sh` for sweeping cache configurations, and `MyStats.sh` for collecting results into CSV files. See the repository for the scripts that are included.
- **Project report** — Contains the experiment tables, plots, benchmark-by-benchmark discussion, and conclusions.

> **MATLAB plots:** Open the appropriate `A/` or `B/` directory in MATLAB, make the corresponding statistics files available at the paths expected by the scripts, and run the plotting entry point. The report identifies `run_all.m` and `load_benchmark.m` as the plotting workflow. Check file paths in the scripts before execution.

## Main findings

The experimental results demonstrate that **larger or more associative caches are not automatically faster**:

- A larger cache often reduces capacity misses, but higher access latency can offset or outweigh that benefit.
- Increasing associativity can reduce conflict misses while adding cache lookup complexity and hit latency.
- The best configuration depends on workload locality and the CPU's ability to tolerate memory latency.
- Some workloads benefit appreciably from increased capacity; others show diminishing returns even when their miss rate improves.

**Examples from the report:**

| CPU / benchmark | Lowest execution-time configuration reported | Simulated execution time |
| --- | --- | ---: |
| CPU A / `483.xalancbmk` | 4 KiB, 2-way | 0.011122 s |
| CPU A / `462.libquantum` | 4 KiB, 2-way | 0.022589 s |
| CPU A / `470.lbm` | 256 KiB, 2-way | 0.017181 s |
| CPU A / `471.omnetpp` | 4 KiB, 2-way | 0.016711 s |
| CPU A / `473.astar` | 4 KiB, 2-way | 0.006842 s |
| CPU B / `473.astar` | 4 KiB, 4-way | 0.017499 s |

These values are **simulated workload execution times** from the reported experiments, not wall-clock time taken to run gem5. For the full set of CPU B results, other configurations, and detailed explanations, consult the report.

## Tools and technologies

- **gem5** — Architectural simulation and cache-configuration experiments
- **Bash** — Automated simulation runs and statistics collection
- **MATLAB** — Plotting and comparative performance analysis
- **CSV** — Intermediate experiment data
- **SPEC CPU benchmarks** — Workloads for architectural performance evaluation

## Report

The accompanying assignment report contains the complete measurement tables and MATLAB-generated figures, including plots of **execution time vs. cache size/associativity**, **miss ratio**, and **overall average miss latency**. It also discusses results for each benchmark and both CPU models.

## Key takeaway

**Optimizing cache performance requires balancing miss behavior against access latency and processor characteristics.** Minimizing misses alone is not sufficient: the best cache configuration is the one that improves end-to-end execution performance for the target workload.
