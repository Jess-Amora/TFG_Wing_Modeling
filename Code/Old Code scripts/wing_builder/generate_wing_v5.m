function [results] = generate_wing_v5(avion, datosEstructural, cargas, databasePath)
%GENERATE_WING_V2 Robust and modular generation of the wing FEA model.
%
%   This function creates the node, rib (costilla) and mesh structure of the
%   wing based on aircraft geometry (avion), structural parameters (datosEstructural)
%   and aerodynamic loads (cargas). It has been refactored into modular subfunctions,
%   uses vectorized operations and improved numerical handling so that node placement
%   is accurate for different aircraft configurations.
%
%   Inputs:
%       avion            - Structure with aircraft geometry and coordinates.
%                          (e.g., avion.geometria.Lf, Lw, c1, c2,
%                           avion.geometria.y_global_punta_ala_borde_ataque,
%                           avion.geometria.flecha_radian, and avion.coordenadas.x_local_ala)
%       datosEstructural - Structure with structural parameters (including:
%                          distancia_larguero_anterior_cuerda_porcentaje,
%                          distancia_larguero_posterior_cuerda_porcentaje,
%                          distancia_centro_aerodinamico,
%                          distancia_eje_de_referencia_estructural_cuerda,
%                          numero_de_puntos_en_las_lineas,
%                          distancia_entre_costillas, distancia_entre_larguerillo,
%                          and n)
%       cargas           - Structure with aerodynamic loads (e.g., cargas.schrenk)
%       databasePath     - Path to the database file (used for saving or plotting)
%
%   Output:
%       results - Structure containing the following fields:
%           .costillas                            - The computed rib coordinates.
%           .numero_costillas                     - Number of ribs.
%           .numero_costillas_triangulo           - Number of ribs in the triangular root.
%           .cociente_L_W_inicial                 - Integrated load coefficient.
%           .costilla_costilla_medio              - Matrix of endpoints and midpoints between ribs.
%           .larguerillos                         - Mesh nodes along the stringers.
%           .x_l, .y_l, .l                       - Continuous load distribution coordinates and values.
%           .x_L, .y_L, .L                       - Integration points and local load integration.
%           .coord_aerodinamica_costillas_punto_medio - Rib intersection midpoints.
%           .geometria                            - Structure with all computed geometry lines.
%           .mesh                                 - Structure with mesh nodes and connectivity.
%
%   Note: This refactored version calls several subfunctions to compute the
%         structural geometry, ribs (costillas), mesh nodes, and load distribution.
%

    %% Step 1: Compute Structural Geometry
    geom = computeStructuralGeometry_v0(avion, datosEstructural);
    
    %% Step 2: Generate Costillas (Ribs) and Compute Rib Midpoints & Loads
    [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
        generateCostillas_v0(geom, datosEstructural, cargas, avion);
    
    %% Step 3: Generate Wing Mesh and Node Placement
    mesh = generateWingMesh_v0(geom, costillas, datosEstructural, avion);
    
    %% Step 4: Compute Continuous Load Distribution (Integrate aerodynamic load)
    [x_l, y_l, l, x_L, y_L, L, cociente_L_W_inicial] = ...
        computeLoadDistribution_v0(geom, costilla_medios, cargas, avion, num_costillas, num_costillas_triangulo, datosEstructural);
    
    %% Assemble results structure (to be used by downstream FEA processes)
    results = struct();
    results.costillas = costillas;
    results.numero_costillas = num_costillas;
    results.numero_costillas_triangulo = num_costillas_triangulo;
    results.cociente_L_W_inicial = cociente_L_W_inicial;
    results.costilla_costilla_medio = costilla_costilla_medio;
    results.larguerillos = mesh.larguerillos;
    results.x_l = x_l;
    results.y_l = y_l;
    results.l = l;
    results.x_L = x_L;
    results.y_L = y_L;
    results.L = L;
    results.coord_aerodinamica_costillas_punto_medio = costilla_medios;
    results.coord_aerodinamico_costillas = []; % (Optional: add if computed in future)
    results.geometria = geom;
    results.mesh = mesh;
    
    % results.mesh = mesh;
    % results.numero_larguerillos_total = mesh.numero_larguerillos_total;  % ✅ Add this

    % Optionally, save results to the database (or use in plotting functions)
    % save(databasePath, 'results');
    
    disp('Wing model generation complete.');
end

%% ------------------------------------------------------------------------
function geom = computeStructuralGeometry_v0(avion, datosEstructural)
%computeStructuralGeometry_v0 Computes the key structural lines and parameters.
%
%   Uses aircraft geometry and structural percentages to calculate the chord
%   lines, slopes, intercepts, and related parameters.
%
    % Extract geometry parameters
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    y_global = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha = avion.geometria.flecha_radian; % in radians
    
    % Structural percentages from datosEstructural
    Dist_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_points = datosEstructural.numero_de_puntos_en_las_lineas;
    
    % x_local_ala provided in avion (assumed sorted)
    x_local_ala = avion.coordenadas.x_local_ala;
    
    % Compute chord lines (using linspace for a smooth distribution)
    linea_larg_anterior = linspace(c1*Dist_anterior, y_global + c2*Dist_anterior, numero_points);
    linea_larg_posterior = linspace(c1*Dist_posterior, y_global + c2*Dist_posterior, numero_points);
    linea_centro = linspace(c1*distancia_centro, c1*distancia_centro + Lw*sin(flecha), numero_points);
    linea_eje = linspace(c1*distancia_eje, c2*distancia_eje + y_global, numero_points);
    
    % Compute slopes (pendiente) of anterior and posterior stringers
    pendiente_larg_anterior = (linea_larg_anterior(end) - linea_larg_anterior(1)) / Lw;
    pendiente_larg_posterior = (linea_larg_posterior(end) - linea_larg_posterior(1)) / Lw;
    pendiente_eje = (linea_eje(end) - linea_eje(1)) / Lw;
    
    % Compute perpendicular slope to the posterior stringer (avoid division by zero)
    tol = 1e-8;
    if abs(pendiente_larg_posterior) < tol
        pendiente_perp = Inf;
    else
        pendiente_perp = -1 / pendiente_larg_posterior;
    end
    alfa_larg_posterior = atan(pendiente_larg_posterior);
    
    % Compute intercepts (ordenada al origen) at x = Lf
    const_larg_anterior = linea_larg_anterior(1) - pendiente_larg_anterior * Lf;
    const_larg_posterior = linea_larg_posterior(1) - pendiente_larg_posterior * Lf;
    const_eje = linea_eje(1) - pendiente_eje * Lf;
    
    % Package into a structure
    geom = struct();
    geom.Lf = Lf;
    geom.Lw = Lw;
    geom.c1 = c1;
    geom.c2 = c2;
    geom.flecha = flecha;
    geom.x_local_ala = x_local_ala;
    geom.linea_larg_anterior = linea_larg_anterior;
    geom.linea_larg_posterior = linea_larg_posterior;
    geom.linea_centro = linea_centro;
    geom.linea_eje = linea_eje;
    geom.pendiente_larg_anterior = pendiente_larg_anterior;
    geom.pendiente_larg_posterior = pendiente_larg_posterior;
    geom.pendiente_eje = pendiente_eje;
    geom.pendiente_perp = pendiente_perp;
    geom.alfa_larg_posterior = alfa_larg_posterior;
    geom.const_larg_anterior = const_larg_anterior;
    geom.const_larg_posterior = const_larg_posterior;
    geom.const_eje = const_eje;
    geom.numero_points = numero_points;
    geom.Dist_larg_anterior = Dist_anterior;
    geom.Dist_larg_posterior = Dist_posterior;

    
end

%% ------------------------------------------------------------------------
function [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
         generateCostillas_v0(geom, datosEstructural, cargas, avion)
%generateCostillas_v0 Computes the rib (costilla) geometry and aerodynamic load.
%
%   This function computes the coordinates for the ribs by finding the
%   intersection between lines defined on the posterior and anterior stringers.
%   It also calculates the midpoints (to apply aerodynamic loads) and scales the load.
%
    % Extract relevant parameters from geometry
    Lf = geom.Lf;
    Lw = geom.Lw;
    c1 = geom.c1;
    c2 = geom.c2;
    numero_points = geom.numero_points;
    linea_larg_posterior = geom.linea_larg_posterior;
    linea_larg_anterior = geom.linea_larg_anterior;
    pendiente_larg_anterior = geom.pendiente_larg_anterior;
    alfa_larg_posterior = geom.alfa_larg_posterior;
    const_larg_anterior = geom.const_larg_anterior;
    
    % Structural parameter: spacing between ribs
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    
    % Estimate the length of the posterior stringer
    % (from point at (Lf, c1*Dist_posterior) to (Lf+Lw, y_global + c2*Dist_posterior))
    x_start = Lf;
    y_start = c1 * geom.Dist_larg_posterior;
    x_end = Lf + Lw;
    y_end = avion.geometria.y_global_punta_ala_borde_ataque + c2 * geom.Dist_larg_posterior;
    longitud_posterior = norm([x_end - x_start, y_end - y_start]);
    
    % Determine the number of ribs (costillas)
    num_costillas = floor(longitud_posterior / distancia_entre_costillas);
    
    % Preallocate costillas array: dimensions (num_costillas x 2 x numero_points)
    costillas = zeros(num_costillas, 2, numero_points);
    
    % Compute the posterior rib points along the posterior stringer.
    % Use the angle of the posterior stringer (alfa) and spacing.
    x_cost_post = Lf + (0:(num_costillas-1))' * distancia_entre_costillas * cos(alfa_larg_posterior);
    y_cost_post = interp1(geom.x_local_ala, linea_larg_posterior, x_cost_post, 'spline');
    
    % For each rib, determine the intersection with the anterior stringer.
    % The rib is assumed to be along a line with slope = pendiente_perp (perpendicular to posterior).
    m_perp = geom.pendiente_perp;
    % Compute the line intercept for each rib: b = y - m_perp*x.
    b_cost = y_cost_post - m_perp * x_cost_post;
    
    % Intersection with the anterior stringer (line: y = pendiente_larg_anterior*x + const_larg_anterior)
    x_intersections = (const_larg_anterior - b_cost) ./ (m_perp - pendiente_larg_anterior);
    y_intersections = pendiente_larg_anterior * x_intersections + const_larg_anterior;
    
    % Build each rib as a line from the posterior point to the intersection point.
    for i = 1:num_costillas
        costillas(i,1,:) = linspace(x_cost_post(i), x_intersections(i), numero_points);
        costillas(i,2,:) = linspace(y_cost_post(i), y_intersections(i), numero_points);
    end
    
    % Compute rib midpoints (costilla_medios) between adjacent ribs for load application.
    costilla_medios = zeros(num_costillas-1, 2);
    for i = 1:(num_costillas-1)
        costilla_medios(i,:) = ([x_intersections(i), y_intersections(i)] + [x_intersections(i+1), y_intersections(i+1)]) / 2;
    end
    
    % Compute aerodynamic load at each midpoint using spline interpolation on cargas.schrenk.
    load_data = zeros(num_costillas-1, 1);
    for i = 1:(num_costillas-1)
        load_data(i) = interp1(geom.x_local_ala, cargas.schrenk, costilla_medios(i,1), 'spline');
    end
    % Scale load using n and MTOW (as in your original code)
    n_val = datosEstructural.n;
    MTOW = avion.MTOW;
    load_data = load_data * n_val * MTOW * 2 / (Lw^2);
    
    % For the triangular (root) section, we define a number of ribs (e.g., 30% of total)
    num_costillas_triangulo = max(0, floor(num_costillas * 0.3));
    
    % Build costilla_costilla_medio: alternating endpoints and midpoints between ribs.
    costilla_costilla_medio = zeros(num_costillas*2 - 1, 4);
    idx = 1;
    for i = 1:(num_costillas-1)
        costilla_costilla_medio(idx,:) = [ squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1)), ...
                                             squeeze(costillas(i,1,end)), squeeze(costillas(i,2,end)) ];
        idx = idx + 1;
        costilla_costilla_medio(idx,:) = [ (squeeze(costillas(i,1,1)) + squeeze(costillas(i+1,1,1)))/2, ...
                                           (squeeze(costillas(i,2,1)) + squeeze(costillas(i+1,2,1)))/2, ...
                                           (squeeze(costillas(i,1,end)) + squeeze(costillas(i+1,1,end)))/2, ...
                                           (squeeze(costillas(i,2,end)) + squeeze(costillas(i+1,2,end)))/2 ];
        idx = idx + 1;
    end
    % Last rib endpoint
    costilla_costilla_medio(end,:) = [ squeeze(costillas(end,1,1)), squeeze(costillas(end,2,1)), ...
                                       squeeze(costillas(end,1,end)), squeeze(costillas(end,2,end)) ];
end

%% ------------------------------------------------------------------------
function mesh = generateWingMesh_v0(geom, costillas, datosEstructural, avion)
%GENERATEWINGMESH Constructs the mesh and node placement for the wing.
%
%   The mesh is generated by “interleaving” the nodes from the posterior and
%   anterior stringers and then computing additional nodes for the stringers
%   (larguerillos) by linear interpolation.
%
    % Extract nodal coordinates from ribs:
    % Use the posterior nodes (first slice) and anterior nodes (last slice)
    nodos_posterior = squeeze(costillas(:, :, 1))';  % dimensions: 2 x num_costillas
    nodos_anterior = squeeze(costillas(:, :, end))';   % dimensions: 2 x num_costillas
    
    % (Optional) You can call your interleave_matrices function here if you wish:
    % nodos_posterior = interleave_matrices(squeeze(costillas(:,:,1))', []);
    % nodos_anterior = interleave_matrices(squeeze(costillas(:,:,end))', []);
    
    % Determine the number of nodes along the chord direction
    num_nodos = size(nodos_posterior, 2);
    
    % Estimate the total number of larguerillos based on the chord length.
    chord_length = norm(nodos_anterior(:,1) - nodos_posterior(:,1));
    num_larguerillos_total = floor(chord_length / datosEstructural.distancia_entre_larguerillo);
    
    % Generate larguerillos: For each, interpolate linearly between the posterior and anterior nodes.
    larguerillos = zeros(num_larguerillos_total, 2, num_nodos);
    for i = 1:num_larguerillos_total
        t = i / (num_larguerillos_total + 1);
        larguerillos(i, :, :) = (1 - t) * nodos_posterior + t * nodos_anterior;
    end
    
    % Assemble mesh structure
    mesh = struct();
    mesh.nodos_posterior = nodos_posterior;
    mesh.nodos_anterior = nodos_anterior;
    mesh.larguerillos = larguerillos;
end

%% ------------------------------------------------------------------------
function [x_l, y_l, l, x_L, y_L, L, cociente_L_W_inicial] = ...
         computeLoadDistribution_v0(geom, costilla_medios, cargas, avion, num_costillas, num_costillas_triangulo, datosEstructural)
%COMPUTELOADDISTRIBUTION Computes the continuous load distribution.
%
%   This function uses the rib midpoints (costilla_medios) to define a
%   continuous load distribution along the wing. It then integrates the load
%   using a trapezoidal rule to obtain an overall coefficient.
%
    % Use the rib midpoints as load application points.
    x_l = costilla_medios(:, 1);
    y_l = costilla_medios(:, 2);
    
    % Interpolate the aerodynamic load (schrenk) at these x-coordinates.
    l = interp1(geom.x_local_ala, cargas.schrenk, x_l, 'spline');
    
    % Scale the load as in the original code.
    n_val = datosEstructural.n;
    MTOW = avion.MTOW;
    l = l * n_val * MTOW * 2 / (geom.Lw^2);
    
    % Compute integrated load (L) using the trapezoidal rule.
    L_vec = zeros(length(x_l)-1, 1);
    for i = 1:length(x_l)-1
        L_vec(i) = 0.5 * (l(i) + l(i+1)) * (x_l(i+1) - x_l(i));
    end
    L = L_vec;
    
    % Define integration points (midpoints of x_l and y_l, excluding endpoints).
    x_L = x_l(2:end-1);
    y_L = y_l(2:end-1);
    
    % Compute the load coefficient (cociente_L_W_inicial).
    cociente_L_W_inicial = 2 * sum(L) / (n_val * MTOW);
end
