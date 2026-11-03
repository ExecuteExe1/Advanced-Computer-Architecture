## gem5 Simulation Scripts

This directory contains Bash scripts developed to automate L1 Data Cache (L1D) performance experiments using the **gem5 architectural simulator**.

The simulation scripts execute SPEC CPU2006 benchmarks across different cache configurations, varying **L1D cache size, associativity, and access latency** while keeping the remaining cache hierarchy fixed. They also support parallel execution of multiple simulations to reduce total execution time.

The statistics extraction script processes the generated `stats.txt` files and exports key performance metrics, including execution time, cache hits, cache misses, miss ratio, total memory accesses, and average miss latency, into CSV files for further analysis and visualization using MATLAB.

**CPU A and CPU B:** The scripts can be used for either CPU architecture by simply modifying the corresponding CPU parameters (issue width, reorder buffer size, instruction queue size, load/store queue size, and physical registers) and adjusting the output directory and configuration names accordingly.

**Benchmarks:**In order to change the benchmark used on your CPU configuration you need to change the corresponding field with the name of the benchmark you wish to test
