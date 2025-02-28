function results = calculate_weight_wing_fuel(ala, avion, rib_prop,n)
    % CALCULATE_WEIGHT_WING_FUEL_V1
    % Computes the distributed weight forces (wing and fuel) along the span,
    % then discretizes these forces at the rib–spar intersections using the
    % structural axis (R_i.eje) computed from costilla intersections.
    %
    % Inputs:
    %   - ala: Struct containing wing geometry and rib locations.
    %   - avion: Struct with aircraft properties (MTOW, coordinates, etc.)
    %   - rib_prop: Table with rib properties (columns: rib_id, C, H)
    %
    % Outputs:
    %   - results: Struct containing:
    %         .W_ala: Distributed wing weight (internal ribs)
    %         .W_comb: Distributed fuel weight (internal ribs)
    %         .P_A_masica, .P_R_masica: Mass force splits at rib intersections
    %         .R_i: Rib–spar intersection coordinates
    %         (plus other outputs like My, T from calcMyT)
    
    %% Basic Parameters
    MTOW = avion.MTOW;
    % Lw = avion.geometria.Lw;
    % Lf = avion.geometria.Lf;
    % c1 = avion.geometria.c1;
    % c2 = avion.geometria.c2;
    
    % For the structural axis (eje estructural), the guide prescribes:
    eje_distancia = avion.datosEstructural.distancia_eje_de_referencia_estructural_larguero;
    
    %% Calculate Rib–Spar Intersection Coordinates (R_i)
    % Use the costillas data from ala.costillas (for internal ribs only)
    R_i.anterior = squeeze(ala.costillas(2:end-1, :, end));  % anterior spar intersections
    R_i.posterior = squeeze(ala.costillas(2:end-1, :, 1));   % posterior spar intersections
    R_i.eje = R_i.anterior + eje_distancia * (R_i.posterior - R_i.anterior);
    
    %% Compute Weight Forces from Chord Distribution (pages 15 & 17)
    % Total wing and fuel weights (as fractions of MTOW)
    peso_ala = 0.1 * MTOW;          % Wing weight = 10% of MTOW
    peso_combustible = 0.2 * MTOW;    % Fuel weight = 20% of MTOW
    
    % Extract the chord for each rib from rib_prop (assumed to be in consistent units)
    chord_all = rib_prop.C;  % Vector with chord length per rib
    % We'll use all ribs to compute the normalization constant
    sumC3 = sum(chord_all.^3);
    k_ala = peso_ala / sumC3;
    k_comb = peso_combustible / sumC3;
    
    % Distributed weight at each rib station (including all ribs)
    W_ala_full = k_ala * (chord_all.^3) * n;  % Wing weight distributed along ribs
    W_comb_full = k_comb * (chord_all.^3) * n;  % Fuel weight distributed along ribs
    
    % % Distributed weight of the fuel at each rib station (including all ribs)
    % z_ant = rib_prop.z_anterior;
    % z_pos = rib_prop.z_posterior;
    % h_media = (z_ant + z_pos)/2;
    % delta = h_media / chord_all;
    % V_fuel = 2 * delta * ((1/3) *(c1^2 + c1*c2 + c2*2)) * Lw + 2*c1*h_media * Lf;
    % k_comb = peso_combustible / V_fuel;
    % W_comb_full = k_comb * V_fuel * n;  % Fuel weight distributed along ribs

    % For application at the rib–spar intersections, we assume forces are applied at internal ribs.
    % So, we consider ribs 2 to (end-1):
    W_ala_internal = W_ala_full(2:end-1);
    W_comb_internal = W_comb_full(2:end-1);
    
    % % Total mass force at each internal rib station:
    % F_mass = W_ala_internal + W_comb_internal;
    
    %% Discretization of Wing Mass Forces at Rib Intersections
    % We'll now distribute the mass force F_mass at each rib into upper (anterior) 
    % and lower (posterior) components based on the relative distances from the 
    % rib–spar intersection (similar to the aerodynamic splitting).
    %
    % To that end, we need to compute local geometric parameters.
    %
    % For consistency, we define size_L as the number of internal rib stations:
    size_L = length(W_ala_internal);
    
    % For mass force splitting, define arrays (using the same structural coordinates as in the aero case)
    % Here, we assume that the horizontal (x) coordinate for mass distribution is taken from R_i.eje.
    % For simplicity, we define x_L and y_L as the x and y components of R_i.eje.
    x_L = R_i.eje(:,1);
    y_L = R_i.eje(:,2);
    
    % Preallocate arrays for the mass force splitting at each rib intersection.
    h_A_masica_ala = zeros(size_L, 1);
    h_R_masica_ala = zeros(size_L, 1);
    l1_A = zeros(size_L, 1);
    l2_A = zeros(size_L, 1);
    l1_R = zeros(size_L, 1);
    l2_R = zeros(size_L, 1);
    
    P_A_masica_ala = zeros(size_L, 1);
    P_R_masica_ala = zeros(size_L, 1);
    R1_A_masica_ala = zeros(size_L, 1);
    R2_A_masica_ala = zeros(size_L, 1);
    R1_R_masica_ala = zeros(size_L, 1);
    R2_R_masica_ala = zeros(size_L, 1);
    V_mass_wing = struct();
    
    % Here we assume that the mass forces are applied similarly as the aerodynamic ones,
    % but using F_mass(i) instead of L(i).
    % (The following loop structure mimics your original aerodynamic discretization.)
    for i = 1:size_L
        % Compute distances from the current rib point to the anterior and posterior spar intersection.
        h_A_masica_ala(i) = norm(R_i.eje(i,:) - R_i.anterior(i+1,:));
        h_R_masica_ala(i) = norm(R_i.eje(i,:) - R_i.posterior(i+1,:));
    
        % Compute distances along the rib surface (from costilla points)
        l1_A(i) = norm(ala.costillas(i+1, :, end) - R_i.anterior(i+1,:));
        l2_A(i) = norm(ala.costillas(i+2, :, end) - R_i.anterior(i+1,:));
        l1_R(i) = norm(ala.costillas(i+1, :, 1) - R_i.posterior(i+1,:));
        l2_R(i) = norm(ala.costillas(i+2, :, 1) - R_i.posterior(i+1,:));
    
        % Distribute the mass force F_mass(i) into upper and lower components based on relative distances:
        P_A_masica_ala(i) = W_ala_internal(i) * h_R_masica_ala(i) / (h_A_masica_ala(i) + h_R_masica_ala(i));
        P_R_masica_ala(i) = W_ala_internal(i) * h_A_masica_ala(i) / (h_A_masica_ala(i) + h_R_masica_ala(i));
    
        % Further distribute these into reactions at the costilla intersections:
        R1_A_masica_ala(i) = P_A_masica_ala(i) * l2_A(i) / (l1_A(i) + l2_A(i));
        R2_A_masica_ala(i) = P_A_masica_ala(i) * l1_A(i) / (l1_A(i) + l2_A(i));
        R1_R_masica_ala(i) = P_R_masica_ala(i) * l2_R(i) / (l1_R(i) + l2_R(i));
        R2_R_masica_ala(i) = P_R_masica_ala(i) * l1_R(i) / (l1_R(i) + l2_R(i));
    end
    
    % Assemble the reaction forces at the extremities:
    V_mass_wing.rear(1) = R1_R_masica_ala(1);
    V_mass_wing.front(1) = R1_A_masica_ala(1);
    V_mass_wing.rear(size_L+1) = R2_R_masica_ala(end);
    V_mass_wing.front(size_L+1) = R2_A_masica_ala(end);
    
    for i = 2:size_L
        V_mass_wing.rear(i) = R1_R_masica_ala(i) + R2_R_masica_ala(i-1);
        V_mass_wing.front(i) = R1_A_masica_ala(i) + R2_A_masica_ala(i-1);
    end
    
    %% Discretization of Fuel Mass Forces at Rib Intersections
    % We'll now distribute the mass force F_mass at each rib into upper (anterior) 
    % and lower (posterior) components based on the relative distances from the 
    % rib–spar intersection (similar to the aerodynamic splitting).
    %
    % To that end, we need to compute local geometric parameters.
    %
    % For consistency, we define size_L as the number of internal rib stations:
    size_L = length(W_ala_internal);
    
    % For mass force splitting, define arrays (using the same structural coordinates as in the aero case)
    % Here, we assume that the horizontal (x) coordinate for mass distribution is taken from R_i.eje.
    % For simplicity, we define x_L and y_L as the x and y components of R_i.eje.
    x_L = R_i.eje(:,1);
    y_L = R_i.eje(:,2);
    
    % Preallocate arrays for the mass force splitting at each rib intersection.
    h_A_masica_comb = zeros(size_L, 1);
    h_R_masica_comb = zeros(size_L, 1);
    l1_A = zeros(size_L, 1);
    l2_A = zeros(size_L, 1);
    l1_R = zeros(size_L, 1);
    l2_R = zeros(size_L, 1);
    
    P_A_masica_comb = zeros(size_L, 1);
    P_R_masica_comb = zeros(size_L, 1);
    R1_A_masica_comb = zeros(size_L, 1);
    R2_A_masica_comb = zeros(size_L, 1);
    R1_R_masica_comb = zeros(size_L, 1);
    R2_R_masica_comb = zeros(size_L, 1);
    V_mass_comb = struct();
    
    % Here we assume that the mass forces are applied similarly as the aerodynamic ones,
    % but using F_mass(i) instead of L(i).
    % (The following loop structure mimics your original aerodynamic discretization.)
    for i = 1:size_L
        % Compute distances from the current rib point to the anterior and posterior spar intersection.
        h_A_masica_comb(i) = norm(R_i.eje(i,:) - R_i.anterior(i+1,:));
        h_R_masica_comb(i) = norm(R_i.eje(i,:) - R_i.posterior(i+1,:));
    
        % Compute distances along the rib surface (from costilla points)
        l1_A(i) = norm(ala.costillas(i+1, :, end) - R_i.anterior(i+1,:));
        l2_A(i) = norm(ala.costillas(i+2, :, end) - R_i.anterior(i+1,:));
        l1_R(i) = norm(ala.costillas(i+1, :, 1) - R_i.posterior(i+1,:));
        l2_R(i) = norm(ala.costillas(i+2, :, 1) - R_i.posterior(i+1,:));
    
        % Distribute the mass force F_mass(i) into upper and lower components based on relative distances:
        P_A_masica_comb(i) = W_comb_internal(i) * h_R_masica_comb(i) / (h_A_masica_comb(i) + h_R_masica_comb(i));
        P_R_masica_comb(i) = W_comb_internal(i) * h_A_masica_comb(i) / (h_A_masica_comb(i) + h_R_masica_comb(i));
    
        % Further distribute these into reactions at the costilla intersections:
        R1_A_masica_comb(i) = P_A_masica_comb(i) * l2_A(i) / (l1_A(i) + l2_A(i));
        R2_A_masica_comb(i) = P_A_masica_comb(i) * l1_A(i) / (l1_A(i) + l2_A(i));
        R1_R_masica_comb(i) = P_R_masica_comb(i) * l2_R(i) / (l1_R(i) + l2_R(i));
        R2_R_masica_comb(i) = P_R_masica_comb(i) * l1_R(i) / (l1_R(i) + l2_R(i));
    end
    
    % Assemble the reaction forces at the extremities:
    V_mass_comb.rear(1) = R1_R_masica_comb(1);
    V_mass_comb.front(1) = R1_A_masica_comb(1);
    V_mass_comb.rear(size_L+1) = R2_R_masica_comb(end);
    V_mass_comb.front(size_L+1) = R2_A_masica_comb(end);
    
    for i = 2:size_L
        V_mass_comb.rear(i) = R1_R_masica_comb(i) + R2_R_masica_comb(i-1);
        V_mass_comb.front(i) = R1_A_masica_comb(i) + R2_A_masica_comb(i-1);
    end
    %% (Optional) Verification of mass force distribution:
    total_mass_force = sum(W_ala_internal + W_comb_internal);
    % Note: total_mass_force here is much lower than the total lift requirement.
    fprintf('Total mass force (wing+fuel) on internal ribs: %.2f N\n', total_mass_force);
    
    %% My and T calculations for mass forces (My = 0, T = 0)
    % yshear = 0; % For weight forces, moment arm may be negligible or defined differently.
    % [My_mass, T_mass] = calcMyT(V_mass_wing.front, V_mass_wing.rear, R_i.anterior, R_i.posterior, yshear);
    

    %% Assemble output results
    results = struct();
    results.W_ala = W_ala_internal;    % Wing weight distribution (internal ribs)
    results.W_comb = W_comb_internal;  % Fuel weight distribution (internal ribs)
    results.P_A_masica_ala = P_A_masica_ala;
    results.P_R_masica_ala = P_R_masica_ala;
    results.R1_A_masica_ala = R1_A_masica_ala;
    results.R2_A_masica_ala = R2_A_masica_ala;
    results.R1_R_masica_ala = R1_R_masica_ala;
    results.R2_R_masica_ala = R2_R_masica_ala;
    results.P_A_masica_comb = P_A_masica_comb;
    results.P_R_masica_comb = P_R_masica_comb;
    results.R1_A_masica_comb = R1_A_masica_comb;
    results.R2_A_masica_comb = R2_A_masica_comb;
    results.R1_R_masica_comb = R1_R_masica_comb;
    results.R2_R_masica_comb = R2_R_masica_comb;
    results.total_mass_force = total_mass_force;
    results.R_i = R_i;  % Rib–spar intersection coordinates
    results.V_mass_wing = V_mass_wing;
    results.V_mass_comb = V_mass_comb;
end
