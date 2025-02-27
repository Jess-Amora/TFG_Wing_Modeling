function strength_results = strength_analysis(material, datosEstructural, larguerillo, cordon, cajon, naca_wing, My, Vy, T, num_cycles, database_computer)
    % Computes strength analysis for the wing structure
    % Inputs:
    %   - material: Struct containing material properties
    %   - datosEstructural: Safety factors and design constraints
    %   - larguerillo, cordon, cajon: Structural part data
    %   - naca_wing: Airfoil geometry data
    %   - My: Bending moment (N·m)
    %   - Vy: Shear force (N)
    %   - T: Torsional moment (N·m)
    %   - num_cycles: Number of fatigue cycles
    % ✅ Load database again to ensure it has the latest data
    load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    
    % ✅ Check if `parts` and `cajon` exist
    if ~isfield(TFG_Amora, 'parts') || ~isfield(TFG_Amora.parts, 'cajon')
        error('❌ No structural parts found. Ensure parts have been created before running analysis.');
    end

    %% Initializing
    pitch = datosEstructural.distancia_entre_larguerillo;
    n = datosEstructural.n;
    disp('⚙️ Running Strength Analysis...');
    
    %% 1️⃣ Compute Cajón Properties
    materialType = material.type;  
    pandeoLocalsuperior = true;  
    
    % ✅ Now pass the struct instead of a string
    cajon_struct = cajon_funcion(cajon, materialType, datosEstructural, pandeoLocalsuperior);
    
    % ✅ Store results inside `strength_results` struct
    strength_results = struct( ...
        'A', cajon_struct.A, ...
        'hcg', cajon_struct.hcg, ...
        'I', cajon_struct.I ...
    );
    
    % ✅ Display computed properties
    fprintf('  ✅ Cajón Properties Computed:\n');
    fprintf('  - Center of Gravity (hcg): %.6f m\n', cajon_struct.hcg);
    fprintf('  - Moment of Inertia (I): %.6f m⁴\n', cajon_struct.I);

    %% 2️⃣ Compute Axial Stresses
    sigma = calculate_esfuerzos(cajon.H, cajon_struct.hcg, My, cajon_struct.I);
    strength_results.sigma = sigma;
    
    fprintf('  ✅ Axial Stress Computed:\n');
    fprintf('  - Max Axial Stress: %.2f MPa\n', max(sigma) / 1e6);
    fprintf('  - Min Axial Stress: %.2f MPa\n', min(sigma) / 1e6);
    fprintf('  - Avg Axial Stress: %.2f MPa\n', mean(sigma) / 1e6);


    %% 3️⃣ Compute Load Distribution
    
    % ✅ Extract `A` from the struct (fixing the error)
    A = cajon_struct.A;

    P = reparto_de_fuerzas(A, sigma, n, materialType, pitch);
    strength_results.P = P;

    fprintf('  ✅ Load Distribution Computed:\n');
    fprintf('  - Max Upper Skin Resultant Force: %.2f N\n', max(P.P_RS));
    fprintf('  - Min Upper Skin Resultant Force: %.2f N\n', min(P.P_RS));
    fprintf('  - Avg Upper Skin Resultant Force: %.2f N\n', mean(P.P_RS));
    
    fprintf('  - Max Lower Skin Resultant Force: %.2f N\n', max(P.P_RI));
    fprintf('  - Min Lower Skin Resultant Force: %.2f N\n', min(P.P_RI));
    fprintf('  - Avg Lower Skin Resultant Force: %.2f N\n', mean(P.P_RI));


    %% 4️⃣ Compute Shear Stresses (Using Vy and T)
    shear_stresses = calcularEsfuerzosCortantes(Vy, T, cajon_struct,pitch, materialType);
    strength_results.shear_stresses = shear_stresses;

    fprintf('  ✅ Shear Stress Computed:\n');
    fprintf('  - Max Upper Skin Shear Stress: %.2f MPa\n', max(shear_stresses.tau_ss) / 1e6);
    fprintf('  - Min Upper Skin Shear Stress: %.2f MPa\n', min(shear_stresses.tau_ss) / 1e6);
    fprintf('  - Avg Upper Skin Shear Stress: %.2f MPa\n', mean(shear_stresses.tau_ss) / 1e6);
    
    fprintf('  - Max Lower Skin Shear Stress: %.2f MPa\n', max(shear_stresses.tau_si) / 1e6);
    fprintf('  - Min Lower Skin Shear Stress: %.2f MPa\n', min(shear_stresses.tau_si) / 1e6);
    fprintf('  - Avg Lower Skin Shear Stress: %.2f MPa\n', mean(shear_stresses.tau_si) / 1e6);


    %% 5️⃣ Compute Resistance Factors
    stresses.sigma_LS = P.sigma_LS;
    stresses.sigma_Li = P.sigma_Li;
    stresses.sigma_Cs = P.sigma_CS;
    stresses.sigma_Ci = P.sigma_Ci;
    stresses.sigma_RS = P.sigma_RS;
    stresses.sigma_RI = P.sigma_RI;
    stresses.tau_SS = shear_stresses.tau_ss;
    stresses.tau_SI = shear_stresses.tau_si;
    stresses.tau_L = P.tau_L;
    stresses.tau_C = P.tau_C;
    
    % ✅ Fix: Compute missing sigma_C (Costilla stress)
    stresses.sigma_C = stresses.sigma_Ci;  % Assume lower spar cap stress for costilla
    
    RF = analizar_resistencia(stresses, materialType);
    strength_results.RF = RF;
    
    % ✅ Print computed stresses
    fprintf('\n🔍 Computed Stresses:\n');
    fprintf('  - Upper Stringer Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_LS) / 1e6, min(stresses.sigma_LS) / 1e6, mean(stresses.sigma_LS) / 1e6);
    fprintf('  - Lower Stringer Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_Li) / 1e6, min(stresses.sigma_Li) / 1e6, mean(stresses.sigma_Li) / 1e6);
    fprintf('  - Upper Spar Cap Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_Cs) / 1e6, min(stresses.sigma_Cs) / 1e6, mean(stresses.sigma_Cs) / 1e6);
    fprintf('  - Lower Spar Cap Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_Ci) / 1e6, min(stresses.sigma_Ci) / 1e6, mean(stresses.sigma_Ci) / 1e6);
    fprintf('  - Upper Skin Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_RS) / 1e6, min(stresses.sigma_RS) / 1e6, mean(stresses.sigma_RS) / 1e6);
    fprintf('  - Lower Skin Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_RI) / 1e6, min(stresses.sigma_RI) / 1e6, mean(stresses.sigma_RI) / 1e6);
    fprintf('  - Upper Skin Shear Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.tau_SS) / 1e6, min(stresses.tau_SS) / 1e6, mean(stresses.tau_SS) / 1e6);
    fprintf('  - Lower Skin Shear Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.tau_SI) / 1e6, min(stresses.tau_SI) / 1e6, mean(stresses.tau_SI) / 1e6);
    fprintf('  - Spar Shear Stress (tau_L): Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.tau_L) / 1e6, min(stresses.tau_L) / 1e6, mean(stresses.tau_L) / 1e6);
    fprintf('  - Rib Shear Stress (tau_C): Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.tau_C) / 1e6, min(stresses.tau_C) / 1e6, mean(stresses.tau_C) / 1e6);
    fprintf('  - Costilla Axial Stress: Max %.2f MPa | Min %.2f MPa | Avg %.2f MPa\n', ...
        max(stresses.sigma_C) / 1e6, min(stresses.sigma_C) / 1e6, mean(stresses.sigma_C) / 1e6);
    % ✅ Print computed resistance factors
    fprintf('\n🔍 Resistance Factors:\n');
    fprintf('  - Upper Stringer RF: Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.sigma_LS), min(RF.sigma_LS), mean(RF.sigma_LS));
    fprintf('  - Lower Stringer RF: Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.sigma_Li), min(RF.sigma_Li), mean(RF.sigma_Li));
    fprintf('  - Upper Spar Cap RF: Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.sigma_Cs), min(RF.sigma_Cs), mean(RF.sigma_Cs));
    fprintf('  - Lower Spar Cap RF: Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.sigma_Ci), min(RF.sigma_Ci), mean(RF.sigma_Ci));
    fprintf('  - Spar Shear RF (tau_L): Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.tau_L), min(RF.tau_L), mean(RF.tau_L));
    fprintf('  - Rib Shear RF (tau_C): Max %.2f | Min %.2f | Avg %.2f\n', ...
        max(RF.sigma_VM_C), min(RF.sigma_VM_C), mean(RF.sigma_VM_C));


    
    % % Upper & Lower Skin Analysis (Fix the missing case for metals)
    % if strcmp(materialType, 'metal')
    %     RF.sigma_VM_RS = sqrt(stresses.sigma_RS.^2 + 3 * stresses.tau_SS.^2) / sigma_lim_RS;
    %     fprintf('  - Upper Skin RF: %.2f\n', RF.sigma_VM_RS);
    %     fprintf('  - Lower Skin RF: %.2f\n', RF.sigma_VM_RI);
    % else
    %     fprintf('  - Upper Skin RF: %.2f\n', RF.sigma_VM_RS);
    %     fprintf('  - Lower Skin RF: %.2f\n', RF.sigma_VM_RI);
    % end


    %% 6️⃣ Compute Fatigue Life
    fatigue_results = calcular_fatiga(sigma / 1e6, materialType, num_cycles);
    strength_results.fatigue_results = fatigue_results;
    
    fprintf('  ✅ Fatigue Life Computed.\n');

    %% 7️⃣ Compute Stability
    stability_results = calcular_estabilidad(cajon_struct, material, Vy);
    strength_results.stability_results = stability_results;

    fprintf('  ✅ Stability Analysis Completed.\n');

    %% ✅ Return Results
    disp('✅ Strength Analysis Completed.');
end
