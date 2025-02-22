clc; clear; close all;
addpath('./shared');
% Test parameters for a NACA 6-series airfoil
m = 0.02;      % Maximum camber (2% of chord)
p = 0.4;       % Position of max camber (40% of chord)
t = 0.12;      % Maximum thickness (12% of chord)
c = 1.0;       % Chord length (1 meter)
num_points = 100; % Number of points along the chord
show_graph = true; % Display airfoil graph

% Call the function
[x, y_u, y_l] = naca6series(m, p, t, c, num_points, show_graph);

% Assertions & Validation
assert(length(x) == num_points, 'Error: x should have num_points elements.');
assert(length(y_u) == num_points, 'Error: y_u should have num_points elements.');
assert(length(y_l) == num_points, 'Error: y_l should have num_points elements.');
assert(all(y_u >= y_l), 'Error: Upper surface should always be above lower surface.');
assert(all(x >= 0 & x <= c), 'Error: x-coordinates must be within the chord length.');

% Print test success message
disp('✅ NACA 6-Series function test passed successfully!');
