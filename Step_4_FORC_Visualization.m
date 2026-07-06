% 3. PLOT REVERSAL CURVES (2D ONLY)
% =========================================================================
N=35;
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