%% 🛠 TEST SCRIPT: Pre-Dimensioning Verification
clc; clear; close all;

%% 1️⃣ Define Test Inputs: Internal Forces
forces.My = 5e6;   % Bending Moment (Nm)
forces.Vy = 2e5;   % Shear Force (N)
forces.T  = 8e4;   % Torsional Moment (Nm)

%% 2️⃣ Define Material Properties (Example: Aluminum 2024-T3)
material.E     = 73.1e9;  % Young's Modulus (Pa)
material.yield = 345e6;   % Yield Strength (Pa)
material.nu    = 0.33;    % Poisson’s Ratio
material.rho   = 2.78e3;  % Density (kg/m³)

%% 3️⃣ Run Pre-Dimensioning Function
fprintf('🔹 Running Pre-Dimensioning for Test Case...\n');
structure = pre_dimensioning(forces.My, forces.Vy, forces.T, material);

%% 4️⃣ Display Results
fprintf('\n✅ **Pre-Dimensioning Results:**\n');
fprintf('  - Upper Skin Thickness (tss): %.6f m\n', structure.tss);
fprintf('  - Lower Skin Thickness (tsi): %.6f m\n', structure.tsi);
fprintf('  - Stringer Area (A_Ls): %.6f m²\n', structure.A_Ls);
fprintf('  - Stringer Area (A_Li): %.6f m²\n', structure.A_Li);
fprintf('  - Spar Thickness (tl): %.6f m\n', structure.tl);

fprintf('\n🛠 **Test Completed Successfully!**\n');
