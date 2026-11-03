benchmarks = {'perlbench','libquantum','lbm','omnetpp','astar'};
cache_size = [4 8 16 32 64];

for i = 1:length(benchmarks)

    name = benchmarks{i};
    data = load_benchmarkB(name);

    figure('Name',name);

    % =====================================================
    % 1. Execution Time vs Cache Size
    % =====================================================
    subplot(2,2,1)
    plot(cache_size, data.sim_2,'-o'); hold on;
    plot(cache_size, data.sim_4,'-o');
    plot(cache_size, data.sim_8,'-o');
    plot(cache_size, data.sim_16,'-o');
    grid on;
    title('Execution Time vs Cache Size');
    xlabel('Cache Size');
    ylabel('Sim Sec');
    legend('2-way','4-way','8-way','Full Assoc','Location','best');

    % =====================================================
    % 2. Miss Ratio vs Cache Size
    % =====================================================
    subplot(2,2,2)
    plot(cache_size, data.miss_2,'-o'); hold on;
    plot(cache_size, data.miss_4,'-o');
    plot(cache_size, data.miss_8,'-o');
    plot(cache_size, data.miss_16,'-o');
    grid on;
    title('Miss Ratio vs Cache Size');
    xlabel('Cache Size');
    legend('2-way','4-way','8-way','Full Assoc','Location','best');

    % =====================================================
    % 3. OAML vs Cache Size
    % =====================================================
    subplot(2,2,3)
    plot(cache_size, data.oaml_2,'-o'); hold on;
    plot(cache_size, data.oaml_4,'-o');
    plot(cache_size, data.oaml_8,'-o');
    plot(cache_size, data.oaml_16,'-o');
    grid on;
    title('OAML vs Cache Size');
    xlabel('Cache Size');
    legend('2-way','4-way','8-way','Full Assoc','Location','best');

    % =====================================================
    % 4. ASSOCIATIVITY EFFECT (fixed cache size = 8KiB)
    % =====================================================

    fixed_idx = 2; % 8KiB row

    % ============================
    % REORDER: Full → 2 → 4 → 8
    % original order = [2 4 8 Full]
    % ============================
    order = [4 1 2 3];

    sim_fixed  = data.sim_assoc(fixed_idx,order);
    miss_fixed = data.miss_assoc(fixed_idx,order);
    oaml_fixed = data.oaml_assoc(fixed_idx,order);

    assoc_x = 1:4;
    assoc_labels = {'Full Assoc','2-Way','4-Way','8-Way'};

    figure('Name',[name ' - Associativity']);

    subplot(1,3,1)
    plot(assoc_x, sim_fixed,'-o','LineWidth',2);
    grid on;
    xticks(assoc_x);
    xticklabels(assoc_labels);
    title('Execution Time vs Associativity');
    xlabel('Associativity');
    ylabel('Sim Sec');

    subplot(1,3,2)
    plot(assoc_x, miss_fixed,'-o','LineWidth',2);
    grid on;
    xticks(assoc_x);
    xticklabels(assoc_labels);
    title('Miss Ratio vs Associativity');
    xlabel('Associativity');

    subplot(1,3,3)
    plot(assoc_x, oaml_fixed,'-o','LineWidth',2);
    grid on;
    xticks(assoc_x);
    xticklabels(assoc_labels);
    title('OAML vs Associativity');
    xlabel('Associativity');
    ylabel('OAML (ticks)');
end