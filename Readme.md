## CPU Cache Performance Analysis and Optimization Using gem5

This project investigates the impact of L1 Data Cache (L1D) configurations on CPU performance using the gem5 architectural simulator.

Two CPU architectures with different execution resources are evaluated across multiple SPEC CPU benchmarks to investigate how cache size, associativity, and memory access latency influence execution time and overall system performance.

Automated Bash scripts execute simulations across different cache configurations, varying cache capacity from 4 KiB to 512 KiB and evaluating 2-way, 4-way, 8-way, and fully associative configurations.

Performance metrics, including execution time, cache hits, cache misses, miss ratio, and average miss latency, are collected and analyzed using CSV files and MATLAB visualizations.

The study uses the Average Memory Access Time (AMAT) model to evaluate the trade-offs between cache hit latency and miss penalties, identifying workload-dependent configurations that balance memory performance and cache complexity.

The project highlights how larger caches and higher associativity do not necessarily improve execution performance, emphasizing the importance of workload characteristics, memory locality, and processor microarchitecture.

**Technologies:** gem5 Simulator, Bash Scripting, MATLAB, CSV, Computer Architecture, Cache Memory Optimization.
