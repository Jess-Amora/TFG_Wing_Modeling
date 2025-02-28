function results = calculate_weight_wing_fuel_v1(ala, avion, rib_prop)
    % CALCULATE_FINAL_FORCES_V1 Computes the final forces on the wing,
    % considering both aerodynamic forces and mass forces (wing weight and fuel),
    % with weight distributed according to c(y)^3.
    %
    % Inputs:
    %   - ala: Struct containing wing geometry and rib locations.
    %   - avion: Struct with aircraft properties (MTOW, etc.) and coordinates.
    %   - cargas: Struct with aerodynamic load distribution (Schrenk, etc.).
    %   - rib_prop: Table with rib properties (columns: rib_id, C, H)
    %
    % Outputs:
    %   - results: Struct containing final aerodynamic and mass forces, plus
    %              rib–spar intersection coordinates and computed moments.
    
    %% 📌 Load Inputs and basic parameters
    MTOW = avion.MTOW;
    n = avion.datosEstructural.n;
    Lw = avion.geometria.Lw;
    pendiente_perpendicular_larguero_posterior = ala.geometria.pendiente_perpendicular_larguero_posterior;
    
    %% Calculate rib–spar intersection coordinates (R_i)
    % Instead of using the previous coord_interseccion_paralela_costillas_pasa_por_A,
    % we use the guide’s prescription.
    R_i.anterior = squeeze(ala.costillas(2:end-1, :, end));
    R_i.posterior = squeeze(ala.costillas(2:end-1, :, 1));
    R_i.eje = R_i.anterior + avion.datosEstructural.distancia_eje_de_referencia_estructural_larguero ...
              * (R_i.posterior - R_i.anterior);
    
    %% ✅ Compute Weight Forces from chord distribution (pages 15 & 17)
    % Instead of using x_L, we now use the local chord from rib_prop.
    %
    % Total wing weight and fuel weight (as fractions of MTOW)
    peso_ala = 0.1 * MTOW;          % Wing weight (10% of MTOW)
    peso_combustible = 0.2 * MTOW;    % Fuel weight (20% of MTOW)
    
    % Extract chord for each rib from rib_prop table (assumed in same units as MTOW calculations)
    chord_all = rib_prop.C;  % This gives a vector of chord lengths per rib
    % Normalize by the sum of c^3 over all ribs to compute the scaling constants.
    sumC3 = sum(chord_all.^3);
    k_ala = peso_ala / sumC3;
    k_comb = peso_combustible / sumC3;
    
    % Distributed weight at each rib station:
    % Option 1: Use all rib stations
    W_ala_full = k_ala * chord_all.^3 * n;  % Multiply by load factor if needed
    W_comb_full = k_comb * chord_all.^3 * n;
    
    % Option 2: If you want to consider only internal ribs (e.g., ribs 2 to end-1)
    W_ala_internal = W_ala_full(2:end-1);
    W_comb_internal = W_comb_full(2:end-1);
    
    %% 🔹 Discretization of Forces at Rib Intersections (Mass part)
    h_A_masica = zeros(size_L, 1);
    h_R_masica = zeros(size_L, 1);
    l1_A = zeros(size_L, 1);
    l2_A = zeros(size_L, 1);
    l1_R = zeros(size_L, 1);
    l2_R = zeros(size_L, 1);
    
    P_A_masica = zeros(size_L, 1);
    P_R_masica = zeros(size_L, 1);
    R1_A_masica = zeros(size_L, 1);
    R2_A_masica = zeros(size_L, 1);
    R1_R_masica = zeros(size_L, 1);
    R2_R_masica = zeros(size_L, 1);
    V = struct();
    
    for i = 1:size_L
        % Use the intersection coordinates (here you can adapt if necessary)
        h_A_masica(i) = norm([x_L(i) y_L(i)] - R_i.anterior(i+1, :));
        h_R_masica(i) = norm([x_L(i) y_L(i)] - R_i.posterior(i+1, :));
    
        l1_A(i) = norm(ala.costillas(i+1, :, end) - R_i.anterior(i+1, :));
        l2_A(i) = norm(ala.costillas(i+2, :, end) - R_i.anterior(i+1, :));
        l1_R(i) = norm(ala.costillas(i+1, :, 1) - R_i.posterior(i+1, :));
        l2_R(i) = norm(ala.costillas(i+2, :, 1) - R_i.posterior(i+1, :));
    
        P_A_masica(i) = L(i) * h_R_masica(i) / (h_A_masica(i) + h_R_masica(i));
        P_R_masica(i) = L(i) * h_A_masica(i) / (h_A_masica(i) + h_R_masica(i));
    
        R1_A_masica(i) = P_A_masica(i) * l2_A(i) / (l1_A(i) + l2_A(i));
        R2_A_masica(i) = P_A_masica(i) * l1_A(i) / (l1_A(i) + l2_A(i));
        R1_R_masica(i) = P_R_masica(i) * l2_R(i) / (l1_R(i) + l2_R(i));
        R2_R_masica(i) = P_R_masica(i) * l1_R(i) / (l1_R(i) + l2_R(i));
    end
    
    V.rear(1) = R1_R_masica(1);
    V.front(1) = R1_A_masica(1);
    V.rear(size_L+1) = R2_R_masica(end);
    V.front(size_L+1) = R2_A_masica(end);
    
    for i = 2:size_L
        V.rear(i) = R1_R_masica(i) + R2_R_masica(i-1);
        V.front(i) = R1_A_masica(i) + R2_A_masica(i-1);
    end
    
    
    %% ✨ Compute Rib–Spar Intersection Coordinates (R_i) already computed above.
    % (R_i.eje is computed earlier using the guide's formula.)
    
    %% My and T calculations( My = 0, T = 0)
    yshear = 0; % Modify y-coordinates as needed
    [My, T] = calcMyT(V.front, V.rear, R_i.anterior, R_i.posterior, yshear);
    
    %% ✨ Return Results
    results = struct();
    results.L = L;
    results.W_ala = W_ala_internal;   % Weight distribution for the wing structure (internal ribs)
    results.W_comb = W_comb_internal; % Weight distribution for the fuel (internal ribs)
    results.P_A_masica = P_A_masica;
    results.P_R_masica = P_R_masica;
    results.R1_A_masica = R1_A_masica;
    results.R2_A_masica = R2_A_masica;
    results.R1_R_masica = R1_R_masica;
    results.R2_R_masica = R2_R_masica;
    results.total_lift_required = total_lift_required;
    results.error_check = error_check;
    results.R_i = R_i;  % Rib–spar intersection coordinates.
    results.V = V;
    results.My = My;
    results.T = T;
    
end
