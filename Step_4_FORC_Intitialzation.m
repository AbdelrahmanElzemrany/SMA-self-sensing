% =========================================================================
%%Due to the raised complexity of the system I resorted to change the
%%cooling rate of electro-thermal part to a liquid convection one 
%%to minimaize the time of the experiment 
%%By Abdelrahman Elzemrany
% FIRST-ORDER REVERSAL CURVES (FORC) DATA GENERATION ONLY
% NATIVE SIMULINK STRUCTURE EDITION (NO PREISACH DERIVATIVES)
% =========================================================================
clear; clc; close all;

% --- 1. CONFIGURATION & GRID DEFINITION ---
model_name = 'FORC_Extraction_Model'; % Replace with your exact .slx file name (without .slx)
N = 35;                              % Number of reversal curves to collect

T_max = 310;                         % Maximum temperature (Austenite state, 100% stiff)
T_min = 240;                         % Minimum temperature (Martensite state, 100% flexible)

% Generate the coordinate axes for the FORC data matrix
beta_values = linspace(T_max, T_min, N);   % Cooling turnaround thresholds (Rows)
alpha_values = linspace(T_min, T_max, N);  % Heating temperature grid points (Columns)

% Initialize your raw data collection matrix
forc_matrix = zeros(N, N);

dt = .001;                 % Simulation time step
total_ramp_time = 2.5;    % 2.5 seconds to cool down, 2.5 seconds to heat up

fprintf('Starting FORC Automation Loops (%d curves)...\n', N);

% =========================================================================
% 2. AUTOMATED SIMULINK EXECUTION LOOP
% =========================================================================
for i = 1:N
    beta_target = beta_values(i);
    fprintf('  Running Curve %d/%d (Cooling to Reversal Point: %.1f K)\n', i, N, beta_target);
    
    % Define explicit column vectors for time
    t_cool_axis = (0:dt:total_ramp_time)';
    t_heat_axis = ((total_ramp_time + dt):dt:(2 * total_ramp_time))';
    
    % Build linear temperature profiles matching the time grids
    T_cool_profile = linspace(T_max, beta_target, length(t_cool_axis))';
    T_heat_profile = linspace(beta_target, T_max, length(t_heat_axis))';
    
    % Combine both branches into unified vectors
    time_vector = [t_cool_axis; t_heat_axis];
    T_profile = [T_cool_profile; T_heat_profile];
    
    % --- NATIVE STRUCTURE INJECTION ---
    % Clears old data definitions and builds an explicit Simulink structure
    clear sim_input_T; 
    sim_input_T.time = time_vector;
    sim_input_T.signals.values = T_profile;
    sim_input_T.signals.dimensions = 1;
    
    % Push variable directly to the Base Workspace
    assignin('base', 'sim_input_T', sim_input_T);
    
    % Run the simulation for exactly 20 seconds
    simOut = sim(model_name, 'StopTime', '5.0');
    
    % --- Extract logs safely based on return format ---
    if isa(simOut, 'Simulink.SimulationOutput')
        raw_curv = simOut.get('curvature_data');
        raw_temp = simOut.get('T_data');
    else
        % Fallback for older MATLAB versions
        raw_curv = evalin('base', 'curvature_data');
        raw_temp = evalin('base', 'T_data');
    end
    
    % Convert raw outputs to plain numeric vectors safely
    if isa(raw_curv, 'timeseries')
        sim_curv = raw_curv.Data;
        sim_temp = raw_temp.Data;
        sim_time = raw_curv.Time;
    else
        sim_curv = raw_curv;
        sim_temp = raw_temp;
        sim_time = (0:length(sim_curv)-1)' * dt;
    end
    
    % --- Filter for data recorded during the heating phase (Time >= 2.5s) ---
    heating_indices = find(sim_time >= total_ramp_time);
    heating_temp = sim_temp(heating_indices);
    heating_curv = sim_curv(heating_indices);
    
    % Store the curvature values corresponding to your alpha temperature targets
    for j = 1:N
        alpha_target = alpha_values(j);
        if alpha_target >= beta_target
            [~, close_idx] = min(abs(heating_temp - alpha_target));
            forc_matrix(i, j) = heating_curv(close_idx);
        end
    end
end

% Save the raw data safely to a .mat file
save('raw_forc_data.mat', 'forc_matrix', 'alpha_values', 'beta_values');
disp('FORC Data Generation Complete! Saved matrix to raw_forc_data.mat');

% =========================================================================
% 3. PLOT REVERSAL CURVES (2D ONLY)
% =========================================================================
figure;
hold on;
for i = 1:N
    % Find valid data indices where heating temperature >= cooling turnaround point
    valid_idx = find(alpha_values >= beta_values(i));
    if ~isempty(valid_idx)
        plot(alpha_values(valid_idx), forc_matrix(i, valid_idx), '-o', 'LineWidth', 1.2);
    end
end
grid on;
xlabel('Temperature (K)');
ylabel('Curvature \kappa');
title('Collected First-Order Reversal Curves (FORC)');
