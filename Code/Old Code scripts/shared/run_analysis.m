%% Master Function to Run Full Structural Analysis
function results = run_analysis(material, dimensions, load_conditions)
    % RUN_ANALYSIS Performs the full structural analysis for an aircraft wing section.
    %
    % Inputs:
    %   material: Struct containing material properties
    %       - E: Young’s modulus (MPa)
    %       - nu: Poisson’s ratio
    %       - rho: Density (kg/m³)
    %   dimensions: Struct with geometric properties
    %       - H, C, tss, tsi, tl, n, pitch, etc.
    %   load_conditions: Struct containing applied loads
    %       - My: Bending moment (N·m)
    %       - F: Shear force (N)
    %       - T: Torsional moment (N·m)
    %       - num_cycles: Number of fatigue load cycles
    %
    % Outputs:
    %   results: Struct containing all calculated outputs.

    fprintf('🚀 Running Full Structural Analysis...\n');

    %% Step 1️⃣: Compute Cross-Sectional Properties
    fprintf('\n📌 Step 1: Computing Structural Properties...\n');
    A_cordon = cordon(dimensions.cordon);
    A_larguerillo = larguerillo(dimensions.larguerillo);
    dimensions.A_larguerillo = A_larguerillo;
    dimensions.A_cordon = A_cordon;
    [A, hcg, I] = cajon(dimensions, material.type, true);
    

    %% Step 2️⃣: Compute Axial Stresses
    fprintf('\n📌 Step 2: Computing Axial Stresses...\n');
    sigma = calculate_esfuerzos(dimensions.H, hcg, load_conditions.My, I);

    %% Step 3️⃣: Compute Load Distribution
    fprintf('\n📌 Step 3: Distributing Loads...\n');
    P = reparto_de_fuerzas(A, sigma, dimensions.n, material.type, dimensions.pitch);

    %% Step 4️⃣: Compute Shear Stresses
    fprintf('\n📌 Step 4: Computing Shear Stresses...\n');
    shear_stresses = calcularEsfuerzosCortantes(load_conditions.F, load_conditions.T, A, material.type);

    %% Step 5️⃣: Perform Resistance Analysis
    fprintf('\n📌 Step 5: Analyzing Resistance Factors...\n');
    stresses = struct('sigma_LS', P.sigma_LS, 'sigma_Li', P.sigma_Li, ...
                      'sigma_Cs', P.sigma_CS, 'sigma_Ci', P.sigma_Ci, ...
                      'sigma_RS', P.sigma_RS, 'sigma_RI', P.sigma_RI, ...
                      'tau_SS', shear_stresses.tau_ss, 'tau_SI', shear_stresses.tau_si, ...
                      'tau_L', shear_stresses.tau_l, 'sigma_C', P.sigma_Ci, ...
                      'tau_C', shear_stresses.tau_si);
    RF = analizar_resistencia(stresses, material.type);

    %% Step 6️⃣: Compute Fatigue Life
    fprintf('\n📌 Step 6: Computing Fatigue Life...\n');
    fatigue = calcular_fatiga(sigma, material.type, load_conditions.num_cycles);

    %% Step 7️⃣: Compute Stability Analysis
    fprintf('\n📌 Step 7: Computing Stability Analysis...\n');
    
    % ✅ Define Proper Stability Geometry Struct
    geometry.L = dimensions.C;   % Wing box width as "length" (could be another value)
    geometry.b = dimensions.C;   % Width of the skin panel
    geometry.t = dimensions.tss; % Thickness of the upper skin
    geometry.I = I;              % Moment of inertia
    
    % Call Stability Function with Correct Data
    stability = calcular_estabilidad(geometry, material, load_conditions.F);


    %% Step 8️⃣: Store Results
    fprintf('\n✅ Analysis Complete!\n');
    results = struct('A', A, 'hcg', hcg, 'I', I, ...
                     'stresses', sigma, 'loads', P, 'shear_stresses', shear_stresses, ...
                     'RF', RF, 'fatigue', fatigue, 'stability', stability);

    %% Display Summary
    fprintf('\n📊 **Final Summary:**\n');
    fprintf('- Center of Gravity (hcg): %.4f m\n', hcg);
    fprintf('- Moment of Inertia (I): %.6f m⁴\n', I);
    fprintf('- Maximum Axial Stress: %.2f MPa\n', sigma / 1e6);
    fprintf('- Maximum Shear Stress: %.2f MPa\n', max([shear_stresses.tau_ss, shear_stresses.tau_si]) / 1e6);
    fprintf('- Fatigue Life Estimate: %.2e cycles\n', fatigue);
    fprintf('- Stability Safety Factor: %.2f (Should be >1)\n', stability);
end
