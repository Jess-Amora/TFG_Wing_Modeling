function plot_strength_results(strength_results) 
% PLOT_STRENGTH_RESULTS Visualizes strength analysis results for each rib. 
% % Input: % strength_results - Array of structs (one per rib) as produced by 
% the strength_analysis function. % % The function plots: 
% - Axial stress: max, min, and average (in MPa) 
% - Moment of inertia (I) % - Center of gravity height (hcg) 
% - Two example resistance factors (e.g., RF for upper and lower stringers)

% Extract rib indices (assumed stored as rib_index in each element)
rib_idx = [strength_results.rib_index];

% Extract axial stress values for each rib (assume sigma is a vector in each element)
sigma_max = arrayfun(@(x) max(x.sigma), strength_results);
sigma_min = arrayfun(@(x) min(x.sigma), strength_results);
sigma_avg = arrayfun(@(x) mean(x.sigma), strength_results);

% Extract moment of inertia and center of gravity
I_vals   = arrayfun(@(x) x.I, strength_results);
hcg_vals = arrayfun(@(x) x.hcg, strength_results);

% Extract two example resistance factors from the RF struct 
% (adjust field names as needed based on your RF output)
% Suppose each strength_results(i).RF.sigma_LS is a vector.
% We want the maximum of each vector to plot one point per rib.
RF_sigma_LS = arrayfun(@(x) max(x.RF.sigma_LS), strength_results);
RF_sigma_Li = arrayfun(@(x) max(x.RF.sigma_Li), strength_results);

% Create a figure with multiple subplots
figure;
% plot(rib_idx, RF_sigma_LS, '-o');
% Subplot 1: Axial Stress vs Rib Index
subplot(2,2,1);
plot(rib_idx, sigma_max/1e6, '-o', rib_idx, sigma_min/1e6, '-s', rib_idx, sigma_avg/1e6, '-d');
title('Axial Stress (MPa)');
xlabel('Rib Index');
ylabel('Stress (MPa)');
legend('Max', 'Min', 'Avg', 'Location', 'best');
grid on;

% Subplot 2: Moment of Inertia vs Rib Index
subplot(2,2,2);
plot(rib_idx, I_vals, '-o');
title('Moment of Inertia (m^4)');
xlabel('Rib Index');
ylabel('I (m^4)');
grid on;

% Subplot 3: Center of Gravity vs Rib Index
subplot(2,2,3);
plot(rib_idx, hcg_vals, '-o');
title('Center of Gravity (m)');
xlabel('Rib Index');
ylabel('hcg (m)');
grid on;

% Subplot 4: Example Resistance Factors vs Rib Index
subplot(2,2,4);
plot(rib_idx, RF_sigma_LS, '-o', rib_idx, RF_sigma_Li, '-s');
title('Resistance Factors');
xlabel('Rib Index');
ylabel('RF');
legend('RF Upper Stringer', 'RF Lower Stringer', 'Location', 'best');
grid on;

% Optionally, add more plots in a new figure (e.g., load distribution, fatigue, etc.)
% For example:
% figure;
% plot(rib_idx, arrayfun(@(x) mean(x.P.P_RS), strength_results), '-o');
% title('Average Upper Skin Resultant Force vs Rib Index');
% xlabel('Rib Index');
% ylabel('Force (N)');
% grid on;
end