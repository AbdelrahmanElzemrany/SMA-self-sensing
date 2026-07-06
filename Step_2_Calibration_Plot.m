%% Multi-Rate High-Fidelity Plotting Engine (Curves Only)
clc;
close all;
disp('Extracting and plotting dual-rate sensor arrays...');

%% 1. Extract Arrays Safely from 'out' Workspace Structure
try
    if isa(out.actual_T, 'timeseries')
        actual_T = out.actual_T.Data;
    elseif isa(out.actual_T, 'Simulink.SimulationData.Signal')
        actual_T = out.actual_T.Values.Data;
    else
        actual_T = out.actual_T;
    end
    
    if isa(out.estim_T, 'timeseries')
        estim_T = out.estim_T.Data;
    elseif isa(out.estim_T, 'Simulink.SimulationData.Signal')
        estim_T = out.estim_T.Values.Data;
    else
        estim_T = out.estim_T;
    end
    
    actual_T = actual_T(:);
    estim_T  = estim_T(:);
catch ME
    error('Array extraction failed: %s', ME.message);
end

%% 2. Configure Dynamic Time Tracks
dt_fast = 0.001; 
dt_slow = 0.230;

if length(actual_T) == length(estim_T)
    % Scenario A: Full length arrays (Synchronized lengths)
    time_slow = (0:length(actual_T)-1)' * dt_fast;
else
    % Scenario B: The 14 compressed hardware snapshots mapped to true arrival times
    time_slow = zeros(length(actual_T), 1);
    for i = 1:7
        time_slow(2*i-1) = (2*i - 2) * dt_slow;
        time_slow(2*i)   = (2*i - 1) * dt_slow;
    end
end
time_fast = (0:length(estim_T)-1)' * dt_fast;

%% 3. Generate High-Fidelity Validation Plot (Stairs Mode)
figure('Color', [1 1 1], 'Position', [200, 200, 800, 500]); 
hold on; grid on;

% Plot actual thermocouple data with true Zero-Order Hold (ZOH) steps
h_stairs = stairs(time_slow, actual_T, 'LineWidth', 2.5, 'Color', [0.85 0.33 0.10]);
h_dots   = plot(time_slow, actual_T, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerEdgeColor', 'k');

% Plot high-speed estimated temperature as a smooth continuous line
h_estim = plot(time_fast, estim_T, 'LineWidth', 2.0, 'Color', [0.00 0.45 0.74]);

% Layout formatting controls
xlabel('Time (Seconds)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Temperature (Kelvin)', 'FontSize', 11, 'FontWeight', 'bold');
title('Observer vs. Thermocouple Response (Dual-Rate Real-Time System)', 'FontSize', 12, 'FontWeight', 'bold');

% Auto-scale axes based on data boundaries
xlim([0, max(time_fast)]);
ylim([min([actual_T; estim_T])-10, max([actual_T; estim_T])+10]);

legend([h_stairs, h_estim], ...
       {'Actual T (Hardware Snapshots)', 'Estimated T (1ms Continuous Observer)'}, ...
       'Location', 'southeast');

hold off;
