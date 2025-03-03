function strength_results = strength_analysis(material, datosEstructural, rib_props, larguerillo, cordon, cajon, naca_wing, My, Vy, T, num_cycles, database_computer)
    % Computes strength analysis for the wing structure, now on a per-rib basis.
    % Inputs:
    %   - material: Struct containing material properties.
    %   - datosEstructural: Safety factors and design constraints.
    %   - larguerillo, cordon, cajon: Structural part data.
    %   - naca_wing: Airfoil geometry data.
    %   - My: Bending moment (N·m).
    %   - Vy: Shear force (N).
    %   - T: Torsional moment (N·m).
    %   - num_cycles: Number of fatigue cycles.
    %   - database_computer: Path to the database.
    %
    % The function loads the latest TFG_Amora database, retrieves the cajón data,
    % and then performs strength analysis for each rib (slice) of the cajón.
    
    % ✅ Load database to ensure latest data
    load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    
    % ✅ Check if `parts` and `cajon` exist
    if ~isfield(TFG_Amora, 'parts') || ~isfield(TFG_Amora.parts, 'cajon')
        error('❌ No structural parts found. Ensure parts have been created before running analysis.');
    end

    %% Initializing
    pitch = datosEstructural.distancia_entre_larguerillo;
    n = datosEstructural.n;
    disp('⚙️ Running Strength Analysis (per rib)...');
    
    %% 1️⃣ Compute Cajón Properties for each rib slice
    materialType = material.type;  
    pandeoLocalsuperior = true;  
    
    % For the new approach, cajon is passed along with rib properties.
    % (Assume cajon now contains the necessary dimensions and that the rib
    % properties were previously computed and stored in cajon.rib_props.)
    %
    % Call the updated cajon_funcion, which returns an array of structs.
    
    cajon_struct = cajon_funcion(cajon, rib_props, materialType, datosEstructural, pandeoLocalsuperior);
    
    % Preallocate results array (one per rib)
    num_ribs = length(cajon_struct);
    strength_results = repmat(struct(), num_ribs, 1);
    
    %% Loop over each rib slice
    for i = 1:num_ribs
        % For this rib, extract its properties
        A_i     = cajon_struct(i).A;
        hcg_i   = cajon_struct(i).hcg;
        I_i     = cajon_struct(i).I;
        H_i     = cajon_struct(i).H;
        pitch_i = cajon_struct(i).pitch;
        
        % 2️⃣ Compute Axial Stresses for rib i
        sigma_i = calculate_esfuerzos(H_i, hcg_i, My, I_i);
        
        % 3️⃣ Compute Load Distribution for rib i
        P_i = reparto_de_fuerzas(A_i, sigma_i, n, materialType, pitch_i);
        
        % 4️⃣ Compute Shear Stresses for rib i (using same Vy and T)
        shear_i = calcularEsfuerzosCortantes(Vy, T, cajon_struct(i), pitch_i, materialType);
        
        % 5️⃣ Compute Resistance Factors for rib i
        stresses.sigma_LS = P_i.sigma_LS;
        stresses.sigma_Li = P_i.sigma_Li;
        stresses.sigma_Cs = P_i.sigma_CS;
        stresses.sigma_Ci = P_i.sigma_Ci;
        stresses.sigma_RS = P_i.sigma_RS;
        stresses.sigma_RI = P_i.sigma_RI;
        stresses.tau_SS   = shear_i.tau_ss;
        stresses.tau_SI   = shear_i.tau_si;
        stresses.tau_L    = P_i.tau_L;
        stresses.tau_C    = P_i.tau_C;
        % For costilla stress, assume same as lower spar cap stress:
        stresses.sigma_C  = stresses.sigma_Ci;
        
        RF_i = analizar_resistencia(stresses, materialType);
        
        % 6️⃣ Compute Fatigue Life for rib i
        fatigue_i = calcular_fatiga(sigma_i / 1e6, materialType, num_cycles);
        
        % 7️⃣ Compute Stability for rib i
        stability_i = calcular_estabilidad(cajon_struct(i), material, Vy);
        
        % Store all computed results for rib i
        strength_results(i).A                = A_i;
        strength_results(i).hcg              = hcg_i;
        strength_results(i).I                = I_i;
        strength_results(i).sigma            = sigma_i;
        strength_results(i).P                = P_i;
        strength_results(i).shear_stresses   = shear_i;
        strength_results(i).RF               = RF_i;
        strength_results(i).fatigue_results  = fatigue_i;
        strength_results(i).stability_results= stability_i;
        strength_results(i).rib_index        = rib_props.rib_id(i);
        
        % Optionally display a brief summary for this rib
        fprintf('Rib %d:\n', strength_results(i).rib_index);
        fprintf('  - hcg: %.6f m, I: %.6f m⁴\n', hcg_i, I_i);
        fprintf('  - Axial Stress: Max %.2f MPa, Min %.2f MPa, Avg %.2f MPa\n', ...
                max(sigma_i)/1e6, min(sigma_i)/1e6, mean(sigma_i)/1e6);
        fprintf('  - Upper Skin Resultant Force: Max %.2f N, Min %.2f N, Avg %.2f N\n', ...
                max(P_i.P_RS), min(P_i.P_RS), mean(P_i.P_RS));
        fprintf('  - Lower Skin Resultant Force: Max %.2f N, Min %.2f N, Avg %.2f N\n\n', ...
                max(P_i.P_RI), min(P_i.P_RI), mean(P_i.P_RI));
    end
    
    disp('✅ Strength Analysis Completed for all ribs.');
end
