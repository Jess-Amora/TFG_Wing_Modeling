%% MAIN TEST SCRIPT
% This script tests the cordon, larguerillo, cajon, and calculate_esfuerzos functions
addpath('./2. Geometric wing and forces');
clc; clear; close all;

%% 1️⃣ Test Cordon Function
cordon_dims.hcl = 0.015; % Height of cordon (m)
cordon_dims.tcl = 0.003; % Thickness of cordon (m)

A_cordon = cordon(cordon_dims); % Compute area without plotting
fprintf('Cordon Area: %.6f m²\n', A_cordon);

%% 2️⃣ Test Larguerillo Function
larguerillo_dims.type = 'Z'; % Stringer type (Z or T)
larguerillo_dims.wf = 0.03;  % Flange width (m)
larguerillo_dims.tf = 0.002; % Flange thickness (m)
larguerillo_dims.hw = 0.04;  % Web height (m)
larguerillo_dims.tw = 0.002; % Web thickness (m)
larguerillo_dims.wh = 0.01;  % Heel width (m) [Only for Z]
larguerillo_dims.th = 0.002; % Heel thickness (m) [Only for Z]

A_larguerillo = larguerillo(larguerillo_dims); % Compute area
fprintf('Larguerillo Area (%s): %.6f m²\n', larguerillo_dims.type, A_larguerillo);

%% 3️⃣ Test Cajón Function
cajon_dims.H = 0.5;   % Box height (m)
cajon_dims.C = 1.5;   % Box width (m)
cajon_dims.tss = 0.005; % Upper skin thickness (m)
cajon_dims.tsi = 0.005; % Lower skin thickness (m)
cajon_dims.tl = 0.01;  % Spar thickness (m)
cajon_dims.A_larguerillo = A_larguerillo;
cajon_dims.A_cordon = A_cordon;
cajon_dims.n = 5;      % Number of stringers per skin
cajon_dims.pitch = 0.16; % pitch entre larguerillos

materialType = 'metal'; % Choose 'metal' or 'composite'
pandeoLocalsuperior = true; % Consider effective width corrections

[A, hcg, I] = cajon(cajon_dims, materialType, pandeoLocalsuperior);
fprintf('\nCajón Properties:\n');
fprintf('  - Center of Gravity (hcg): %.6f m\n', hcg);
fprintf('  - Moment of Inertia (I): %.6f m⁴\n', I);

%% 4️⃣ Test Calculate Esfuerzos Function
My = 50000; % Example bending moment (N·m)

sigma = calculate_esfuerzos(cajon_dims.H, hcg, My, I);
fprintf('\nCalculated Axial Stress (σ): %.2f MPa\n', sigma / 1e6); % Convert to MPa

%% 5️⃣ Test Reparto de Fuerzas Function

% Define pitch (spacing between stringers) for the test
pitch = 0.2; % Example value in meters

% Compute load distribution
P = reparto_de_fuerzas(A, sigma, cajon_dims.n, materialType, pitch);

% Display results
fprintf('\nLoad Distribution Results:\n');
fprintf('  - Upper Skin Resultant Force (P_RS): %.6f N\n', P.P_RS);
fprintf('  - Lower Skin Resultant Force (P_RI): %.6f N\n', P.P_RI);
fprintf('  - Upper Skin Spar Cap Load (P_CSe): %.6f N\n', P.P_CSe);
fprintf('  - Upper Skin Stringer Load (P_LSe): %.6f N\n', P.P_LSe);
fprintf('  - Lower Skin Spar Cap Load (P_Ci): %.6f N\n', P.P_Ci);
fprintf('  - Lower Skin Stringer Load (P_Li): %.6f N\n', P.P_Li);
fprintf('  - Lower Skin Sheet Load (P_Si): %.6f N\n', P.P_Si);
fprintf('  - Upper Skin Spar Cap Stress (σ_CS): %.2f MPa\n', P.sigma_CS / 1e6);
fprintf('  - Upper Skin Stringer Stress (σ_LS): %.2f MPa\n', P.sigma_LS / 1e6);
fprintf('  - Lower Skin Spar Cap Stress (σ_Ci): %.2f MPa\n', P.sigma_Ci / 1e6);
fprintf('  - Lower Skin Stringer Stress (σ_Li): %.2f MPa\n', P.sigma_Li / 1e6);
fprintf('  - Lower Skin Sheet Stress (σ_Si): %.2f MPa\n', P.sigma_Si / 1e6);

%% 6️⃣ Test Shear Stress Calculation (calcularEsfuerzosCortantes)

% Define shear force and torsional moment for testing
F = 10000;  % Example shear force (N)
T = 5000;   % Example torsional moment (N·m)

% Compute shear stresses
shear_stresses = calcularEsfuerzosCortantes(F, T, A, materialType);

% Display results
fprintf('\nShear Stress Results:\n');
fprintf('  - Upper Skin Shear Stress (τ_ss): %.2f MPa\n', shear_stresses.tau_ss / 1e6);
fprintf('  - Lower Skin Shear Stress (τ_si): %.2f MPa\n', shear_stresses.tau_si / 1e6);
fprintf('  - Spar Shear Stress (τ_l): %.2f MPa\n', shear_stresses.tau_l / 1e6);
fprintf('  - Upper Skin Torsional Shear Stress (τ_ss_torsion): %.2f MPa\n', shear_stresses.tau_ss_torsion / 1e6);
fprintf('  - Lower Skin Torsional Shear Stress (τ_si_torsion): %.2f MPa\n', shear_stresses.tau_si_torsion / 1e6);
fprintf('  - Spar Torsional Shear Stress (τ_l_torsion): %.2f MPa\n', shear_stresses.tau_l_torsion / 1e6);





%% Test Script for analizar_resistencia.m


% Example stress values from analysis (in MPa)
stresses = struct();
stresses.sigma_LS = 100;  % Upper stringer axial stress
stresses.sigma_Li = 150;  % Lower stringer axial stress
stresses.sigma_Cs = 200;  % Upper spar cap axial stress
stresses.sigma_Ci = 180;  % Lower spar cap axial stress
stresses.sigma_RS = 120;  % Upper skin axial stress
stresses.sigma_RI = 90;   % Lower skin axial stress
stresses.tau_SS = 50;     % Upper skin shear stress
stresses.tau_SI = 40;     % Lower skin shear stress

% Test for Metal
RF_metal = analizar_resistencia(stresses, 'metal');
fprintf('Resistance Factors for Metal:\n');
disp(RF_metal);

% Test for Composite
RF_composite = analizar_resistencia(stresses, 'composite');
fprintf('\nResistance Factors for Composite:\n');
disp(RF_composite);


%% Test Script for Fatigue Analysis

% clc; clear; close all;

% Example stress values (MPa)
stress = 150; % Applied cyclic stress
num_cycles = 1e6; % Load cycles

% Test for Metal
fprintf('🔬 Fatigue Analysis for Metal:\n');
fatigue_metal = calcular_fatiga(stress, 'metal', num_cycles);
disp(fatigue_metal);

% Test for Composite
fprintf('\n🔬 Fatigue Analysis for Composite:\n');
fatigue_composite = calcular_fatiga(stress, 'composite', num_cycles);
disp(fatigue_composite);

%% Test Script for Stability Analysis

% clc; clear; close all;

% Define geometry (example values)
geometry.L = 1.5;  % Length (m)
geometry.t = 0.005; % Thickness (m)
geometry.b = 0.2;  % Width (m)
geometry.I = 1e-6; % Moment of inertia (m^4)

% Define material properties (Aluminum 2024-T3)
material.E = 70000; % Young's modulus (MPa)
material.v = 0.33;  % Poisson's ratio

% Applied Load (N)
applied_load = 10000;

% Run Stability Analysis
stability = calcular_estabilidad(geometry, material, applied_load);
disp(stability);

%% Test Script for Full Structural Analysis

% clc; clear; close all;

% Define Material Properties
material.type = 'metal'; % 'metal' or 'composite'
material.E = 70000; % MPa
material.nu = 0.33;
material.rho = 2.7e-9; % tonne/mm³

% Define Geometric Properties
dimensions.H = 0.5;
dimensions.C = 1.5;
dimensions.tss = 0.005;
dimensions.tsi = 0.005;
dimensions.tl = 0.01;
dimensions.n = 5;
dimensions.pitch = 0.2;
dimensions.cordon.hcl = 0.015;
dimensions.cordon.tcl = 0.003;
dimensions.larguerillo.type = 'Z';
dimensions.larguerillo.wf = 0.03;
dimensions.larguerillo.tf = 0.002;
dimensions.larguerillo.hw = 0.04;
dimensions.larguerillo.tw = 0.002;
dimensions.larguerillo.wh = 0.01;
dimensions.larguerillo.th = 0.002;

% Define Load Conditions
load_conditions.My = 50000; % Bending Moment (N·m)
load_conditions.F = 10000;  % Shear Force (N)
load_conditions.T = 2000;   % Torsional Moment (N·m)
load_conditions.num_cycles = 1e6; % Fatigue cycles

% Run Analysis
results = run_analysis(material, dimensions, load_conditions);

% Display Results
disp(results);

