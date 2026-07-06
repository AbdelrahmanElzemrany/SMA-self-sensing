% =========================================================================
% PURE DIRECTION-LOCKED 1D INVERSE LOOKUP MAPS
% =========================================================================
clear; clc;

load('raw_forc_data.mat'); 
T_max = 300; T_min = 255;

% 1. Extract the Clean Major Heating Curve (Bottom row where beta = 255K)
[~, baseline_idx] = min(beta_values); 
heating_raw = forc_matrix(baseline_idx, :);

% 2. Extract the Clean Major Cooling Curve (The points where heating begins: alpha == beta)
cooling_raw = zeros(1, length(beta_values));
for i = 1:length(beta_values)
    [~, alpha_idx] = min(abs(alpha_values - beta_values(i)));
    cooling_raw(i) = forc_matrix(i, alpha_idx);
end

% 3. Standardize a clean 100-point Curvature tracking axis (0 to 50)
kappa_lut_axis = linspace(0, 50, 100);

% 4. Invert the maps cleanly: Input Curvature -> Output Target Temperature
[c_heat, u_heat] = unique(heating_raw);
lut_heating_T = interp1(c_heat, alpha_values(u_heat), kappa_lut_axis, 'linear', 'extrap');

[c_cool, u_cool] = unique(cooling_raw);
lut_cooling_T = interp1(c_cool, beta_values(u_cool), kappa_lut_axis, 'linear', 'extrap');

% Clamp outputs safely to your precise physical boundaries
lut_heating_T = max(T_min, min(T_max, lut_heating_T));
lut_cooling_T = max(T_min, min(T_max, lut_cooling_T));

save('sma_pure_1d_switching.mat', 'kappa_lut_axis', 'lut_heating_T', 'lut_cooling_T');
disp('SUCCESS: Stable 1D switching parameters created!');
