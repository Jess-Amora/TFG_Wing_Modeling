function [results] = generate_wing_v7(avion, cargas)
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

    datosEstructural = avion.datosEstructural;

    %% Step 1: Compute Structural Geometry
    geom = computeStructuralGeometry_v0(avion);


    %% Step 2: Generate Costillas (Ribs) and Compute Rib Midpoints & Loads
    [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
        generateCostillas(geom, datosEstructural, cargas, avion);
    
    %% Step 3: Generate Wing Mesh and Node Placement
    % mesh = generateWingMesh_v0(geom, costillas, costilla_medios, datosEstructural, avion);
    % mesh = generateWingMesh_v2(geom, costillas, datosEstructural, avion);
    mesh = generateWingMesh_v0(geom, costillas, costilla_medios, datosEstructural, avion);
    results=[];
    
    % %% Step 4: Compute Continuous Load Distribution (Integrate aerodynamic load)
    % [x_l, y_l, l, x_L, y_L, L, cociente_L_W_inicial] = ...
    %     computeLoadDistribution_v0(geom, costilla_medios, cargas, avion, num_costillas, num_costillas_triangulo, datosEstructural);

    %% Assemble results structure (to be used by downstream FEA processes)
    results = struct();
    results.costillas = costillas;
    results.numero_costillas = num_costillas;
    results.numero_costillas_triangulo = num_costillas_triangulo;
    % results.cociente_L_W_inicial = cociente_L_W_inicial;
    results.costilla_costilla_medio = costilla_costilla_medio;
    results.larguerillos = mesh.larguerillos;
    % results.x_l = x_l;
    % results.y_l = y_l;
    % results.l = l;
    % results.x_L = x_L;
    % results.y_L = y_L;
    % results.L = L;
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
function mesh = generateWingMesh_v0(geom, costillas, datosEstructural, avion)
%GENERATEWINGMESH Generate precise wing mesh and node placement using geometric data.
%
%   This function uses the geometry (geom) and rib (costillas) data, along with 
%   structural parameters (datosEstructural) and aircraft data (avion), to build a 
%   mesh of the wing. The mesh includes the stringer (larguerillo) nodes on the 
%   posterior and anterior edges, and nodes along the intermediate stringers.
%
%   Inputs:
%       geom            - Structure with geometry data (fields include: 
%                         c1, Lf, Lw, c2, pendiente_larg_posterior, pendiente_larg_anterior,
%                         const_larg_anterior, x_local_ala, linea_larg_posterior)
%       costillas       - Array (num_costillas x 2 x numero_points) with rib coordinates.
%       datosEstructural- Structure containing:
%                         .distancia_larguero_posterior_cuerda_porcentaje
%                         .distancia_larguero_anterior_cuerda_porcentaje
%                         .distancia_entre_larguerillo  (vertical spacing)
%                         .numero_de_puntos_en_las_lineas
%       avion           - Aircraft data, including:
%                         avion.geometria.y_global_punta_ala_borde_ataque and MTOW.
%
%   Output:
%       mesh            - Structure with the following fields:
%                         .nodos_posterior, .nodos_anterior (edge nodes)
%                         .larguerillos (stringer nodes)
%                         .Numero_nodos_elementos_ala (node count per stringer)
%                         .id_nodo_local_larguerillo_costilla (node identification matrix)
%

    %% Extract basic parameters
    numero_points = datosEstructural.numero_de_puntos_en_las_lineas;
    c1  = geom.c1;
    Lf  = geom.Lf;
    Lw  = geom.Lw;
    % c2 is used in load calculations for the anterior edge:
    c2  = geom.c2;
    
    % Structural chord percentages (as provided in datosEstructural)
    Dist_post = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    Dist_ant  = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    delta_larguerillo = datosEstructural.distancia_entre_larguerillo;
    
    % Get geometric slopes and intercepts
    pendiente_post = geom.pendiente_larg_posterior;      % posterior stringer slope
    pendiente_ant  = geom.pendiente_larg_anterior;         % anterior stringer slope
    const_ant      = geom.const_larg_anterior;             % anterior intercept
    
    % y_global from avion geometry
    y_global = avion.geometria.y_global_punta_ala_borde_ataque;
    
    %% Compute Larguerillo (Stringer) Mesh Parameters
    % The lateral (chordwise) extent for the stringers is defined by the difference
    % in the percentages along the chord.
    longitud_porcentaje = Dist_post - Dist_ant;
    numero_larguerillos_total = floor(c1 * longitud_porcentaje / delta_larguerillo);
    % Determine how many stringers come from the rib (costilla) domain:
    % (Using the norm of the difference between the first and last nodes of the ribs.)
    numero_larguerillos_costilla_final = floor( norm( squeeze(costillas(end,:,1)) - squeeze(costillas(end,:,end)) ) / delta_larguerillo );
    
    % Preallocate larguerillos array:
    % Dimensions: (numero_larguerillos_total x 2 x numero_points)
    larguerillos = zeros(numero_larguerillos_total, 2, numero_points);
    
    % Compute the "encastre" (attachment) coordinates for the stringers:
    coord_encastre_x = Lf * ones(numero_larguerillos_total,1);
    coord_encastre_y = c1 * Dist_post - delta_larguerillo * ( (1:numero_larguerillos_total)' );
    % The constant for the attachment line is computed from the posterior stringer:
    constante_encastre = coord_encastre_y - pendiente_post * coord_encastre_x;
    
    %% Build Larguerillos in Two Zones
    % (A) For stringers that align directly with the rib endpoints (from costilla domain):
    for i = 1:numero_larguerillos_costilla_final
        % For these stringers, the x-coordinates run linearly from Lf to Lf+Lw.
        x_line = linspace(Lf, Lf + Lw, numero_points);
        % The corresponding y-coordinates run from a fixed value at the attachment
        % (computed from c1*Dist_post and reduced by vertical spacing) to the wing tip.
        y_start = c1 * Dist_post - i * delta_larguerillo;
        y_end   = y_global + c2 * Dist_post - i * delta_larguerillo;
        y_line = linspace(y_start, y_end, numero_points);
        larguerillos(i,:,:) = [x_line; y_line];
    end
    
    % (B) For the remaining stringers, compute the connection with the anterior edge.
    for i = numero_larguerillos_costilla_final+1 : numero_larguerillos_total
        % Determine the x-coordinate where the stringer should meet the anterior edge.
        % This is computed by finding the intersection of the line through the
        % attachment point (given by constante_encastre) with the anterior stringer line.
        x_int = -(const_ant - constante_encastre(i)) / (pendiente_ant - pendiente_post);
        y_int = pendiente_ant * x_int + const_ant;
        % Generate the x-coordinate from Lf to this computed intersection:
        x_line = linspace(Lf, x_int, numero_points);
        % Generate the corresponding y-coordinate:
        y_start = c1 * Dist_post - i * delta_larguerillo;
        y_line = linspace(y_start, y_int, numero_points);
        larguerillos(i,:,:) = [x_line; y_line];
    end
    
    %% Compute Edge Nodes from Rib Data
    % The nodes along the posterior edge of the wing come from the first point of each rib,
    % and along the anterior edge from the last point of each rib.
    num_costillas = size(costillas,1);
    puntos_medio_posterior = zeros(num_costillas-1, 2);
    puntos_medio_anterior  = zeros(num_costillas-1, 2);
    for i = 2:num_costillas
        puntos_medio_posterior(i-1,:) = (squeeze(costillas(i, :, 1)) + squeeze(costillas(i-1, :, 1))) / 2;
        puntos_medio_anterior(i-1,:)  = (squeeze(costillas(i, :, end)) + squeeze(costillas(i-1, :, end))) / 2;
    end
    
    % Use the provided interleave_matrices function to merge endpoints and midpoints.
    nodos_posterior = interleave_matrices(squeeze(costillas(:,:,1))', puntos_medio_posterior');
    nodos_anterior  = interleave_matrices(squeeze(costillas(:,:,end))', puntos_medio_anterior');
    
    %% Count Nodes
    num_nodos_posterior = size(nodos_posterior,2);
    num_nodos_anterior  = size(nodos_anterior,2);
    Numero_nodos_elementos_ala = zeros(2 + numero_larguerillos_total, 2);
    Numero_nodos_elementos_ala(1,1) = num_nodos_posterior;
    Numero_nodos_elementos_ala(2,1) = num_nodos_anterior;
    Numero_nodos_dos_largueros = num_nodos_posterior + num_nodos_anterior;
    
    %% (Optional) Determine Intersection Indices for Stringers
    % Compute the intersections between each larguerillo and the rib-to-rib lines.
    % (This uses your existing function cortes_de_dos_funciones_lineales_v3.)
    intersecciones = cortes_de_dos_funciones_lineales_v3( squeeze(larguerillos(:,:,1)), ...
                           pendiente_post, ...
                           [nodos_posterior(1:2,:)]', ... % using posterior nodes as reference
                           geom.pendiente_perp );
                       
    % Create a simple index array indicating how many intersections lie before x = Lf.
    index_intersections = sum(intersecciones(:,:,1) < Lf, 2);
    
    %% (Optional) Adjust Stringer Nodes
    % If needed, call your adjustment function to insert extra nodes where the
    % spacing is too large.
    % [nodos_larguerillos, inserted_nodes] = adjust_nodos_larguerillos_v2(nodos_larguerillos, ...
    %    pendiente_post, geom.pendiente_perp, Numero_nodos_dos_largueros, delta_larguerillo, alfa, threshold_distance);
    % For this implementation, we assume no further adjustment.
    
    %% Assemble Mesh Structure
    mesh = struct();
    mesh.nodos_posterior = nodos_posterior;
    mesh.nodos_anterior  = nodos_anterior;
    mesh.larguerillos    = larguerillos;
    mesh.Numero_nodos_elementos_ala = Numero_nodos_elementos_ala;
    % Optionally, store intersection indices and any node id matrix if needed.
    mesh.index_intersections = index_intersections;
    mesh.nodos_intersecciones = intersecciones;
    % mesh.id_nodo_local_larguerillo_costilla = id_nodo_local_larguerillo_costilla; % if computed
    
    fprintf('Generated %d larguerillos (stringers) with %d posterior nodes and %d anterior nodes.\n', ...
        numero_larguerillos_total, num_nodos_posterior, num_nodos_anterior);
end

%% ------------------------------------------------------------------------
function [costillas, costilla_medios, load_data, num_costillas_total, num_costillas_tri, costilla_costilla_medio] = ...
         generateCostillas(geom, datosEstructural, cargas, avion)
%GENERATECOSTILLAS Computes rib (costilla) geometry including a triangular zone.
%
%   This function divides the rib generation into two zones:
%
%   1. Triangular Zone (root region):
%      Ribs in the triangular zone have their posterior x‐coordinate fixed at Lf
%      and their y‐coordinates descend from c1*Dist_posterior to 0.25*c1. For
%      each triangular rib, the intersection with the anterior stringer is computed
%      using a line with slope equal to the perpendicular to the posterior stringer.
%
%   2. Normal Zone:
%      Ribs along the posterior stringer are computed from a starting x-coordinate
%      (where the posterior line’s y exceeds the last triangular rib) to (Lf+Lw).
%
%   Additionally, the function computes aerodynamic center intersections,
%   midpoints (for load interpolation), and scales the load.
%
%   Inputs:
%       geom           - Structure with geometry (fields include: c1, Lf, Lw,
%                        numero_points, x_local_ala, linea_larg_posterior, 
%                        linea_centro, pendiente_larg_anterior, const_larg_anterior,
%                        pendiente_perp, alfa_larg_posterior).
%       datosEstructural - Contains parameters like:
%                        distancia_entre_costillas, distancia_larguero_posterior_cuerda_porcentaje,
%                        n, and numero_de_puntos_en_las_lineas.
%       cargas         - Structure with aerodynamic load distribution (e.g., cargas.schrenk).
%       avion          - Aircraft data (e.g., MTOW).
%
%   Outputs:
%       costillas             - (num_ribs x 2 x numero_points) array with rib coordinates.
%       costilla_medios       - Midpoints (2-column array) between consecutive ribs.
%       load_data             - Aerodynamic load (vector) at each midpoint.
%       num_costillas_total   - Total number of ribs.
%       num_costillas_tri     - Number of ribs in the triangular (root) zone.
%       costilla_costilla_medio - (num_ribs*2-1 x 4) matrix with endpoints and midpoints.
%

    %----- Extract key parameters -----
    c1              = geom.c1;
    Lf              = geom.Lf;
    Lw              = geom.Lw;
    numero_points   = geom.numero_points;       % resolution along each rib
    x_local_ala     = geom.x_local_ala;           % x-coordinates along the wing span
    linea_larg_posterior = geom.linea_larg_posterior;  % posterior stringer line (y vs. x)
    linea_centro    = geom.linea_centro;          % aerodynamic center line
    pendiente_larg_anterior = geom.pendiente_larg_anterior;
    const_larg_anterior = geom.const_larg_anterior;
    pendiente_perp  = geom.pendiente_perp;        % perpendicular to posterior stringer
    alfa            = geom.alfa_larg_posterior;     % angle of the posterior stringer (in radians)
    
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    n_val           = datosEstructural.n;
    MTOW            = avion.MTOW;
    
    % For the triangular zone, use the posterior chord percentage
    Dist_posterior  = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    
    %----- TRIANGULAR ZONE -----
    % Define the y-range for triangular ribs:
    y_start_tri   = c1 * Dist_posterior;   % top of triangular zone at fuselage
    y_end_tri     = 0.25 * c1;             % lower bound of triangular zone
    delta_y       = distancia_entre_costillas / sin(alfa);
    
    % Create a descending sequence from y_start_tri to y_end_tri.
    y_tri_all     = y_start_tri : -delta_y : y_end_tri;
    if numel(y_tri_all) < 2
        num_costillas_tri = 0;
        costillas_tri   = [];
        coord_aero_tri  = [];
        l_tri           = [];
    else
        % As in the old code, remove the first element:
        y_tri = y_tri_all(2:end);
        num_costillas_tri = numel(y_tri);
        % The posterior x-coordinate is fixed at Lf:
        x_tri = Lf * ones(num_costillas_tri, 1);
        
        % Preallocate triangular rib array and aerodynamic intersections.
        costillas_tri  = zeros(num_costillas_tri, 2, numero_points);
        coord_aero_tri = zeros(num_costillas_tri, 2);
        
        for i = 1:num_costillas_tri
            % For each rib, the line is defined by point (Lf, y_tri(i)) and slope = pendiente_perp.
            % Its line constant: b = y - pendiente_perp*x.
            b_tri = y_tri(i) - pendiente_perp * Lf;
            % Find intersection with the anterior stringer:
            x_int = (b_tri - const_larg_anterior) / (pendiente_larg_anterior - pendiente_perp);
            y_int = pendiente_larg_anterior * x_int + const_larg_anterior;
            % Generate rib coordinates along the line from (Lf, y_tri(i)) to (x_int, y_int).
            costillas_tri(i,1,:) = linspace(Lf, x_int, numero_points);
            costillas_tri(i,2,:) = linspace(y_tri(i), y_int, numero_points);
            % Compute aerodynamic center intersection using polyline_intersection:
            [xa, ya] = polyline_intersection(squeeze(costillas_tri(i,1,:))', squeeze(costillas_tri(i,2,:))', x_local_ala, linea_centro);
            if ~isempty(xa)
                coord_aero_tri(i,:) = [xa(1), ya(1)];
            else
                coord_aero_tri(i,:) = [NaN, NaN];
            end
        end
        
        % Compute midpoints and load for the triangular zone:
        num_mid_tri = num_costillas_tri - 1;
        coord_aero_tri_mid = zeros(num_mid_tri, 2);
        l_tri = zeros(num_mid_tri, 1);
        for i = 1:num_mid_tri
            coord_aero_tri_mid(i,:) = (coord_aero_tri(i,:) + coord_aero_tri(i+1,:)) / 2;
            l_tri(i) = spline(x_local_ala, cargas.schrenk, coord_aero_tri_mid(i,1));
            l_tri(i) = l_tri(i) * n_val * MTOW * 2 / (Lw^2);
        end
    end
    
    %----- NORMAL ZONE -----
    % Determine the starting point for normal ribs.
    if num_costillas_tri > 0
        y_threshold = y_tri(end);
    else
        y_threshold = -Inf;
    end
    x_candidates = linspace(Lf, Lf+Lw, 1000);
    y_candidates = interp1(x_local_ala, linea_larg_posterior, x_candidates, 'spline');
    idx_start = find(y_candidates > y_threshold, 1, 'first');
    if isempty(idx_start)
        x_normal_start = Lf + 1e-6;
    else
        x_normal_start = x_candidates(idx_start);
    end
    normal_length = (Lf+Lw) - x_normal_start;
    num_costillas_norm = floor(normal_length / (distancia_entre_costillas * cos(alfa)));
    
    if num_costillas_norm > 0
        x_norm = x_normal_start + (0:(num_costillas_norm-1))' * distancia_entre_costillas * cos(alfa);
        y_norm = interp1(x_local_ala, linea_larg_posterior, x_norm, 'spline');
        costillas_norm = zeros(num_costillas_norm, 2, numero_points);
        coord_aero_norm = zeros(num_costillas_norm, 2);
        for i = 1:num_costillas_norm
            % For each normal rib, compute its intersection with the anterior stringer.
            b_norm = y_norm(i) - pendiente_perp * x_norm(i);
            x_int = (b_norm - const_larg_anterior) / (pendiente_larg_anterior - pendiente_perp);
            y_int = pendiente_larg_anterior * x_int + const_larg_anterior;
            costillas_norm(i,1,:) = linspace(x_norm(i), x_int, numero_points);
            costillas_norm(i,2,:) = linspace(y_norm(i), y_int, numero_points);
            [xa, ya] = polyline_intersection(squeeze(costillas_norm(i,1,:))', squeeze(costillas_norm(i,2,:))', x_local_ala, linea_centro);
            if ~isempty(xa)
                coord_aero_norm(i,:) = [xa(1), ya(1)];
            else
                coord_aero_norm(i,:) = [NaN, NaN];
            end
        end
        num_mid_norm = num_costillas_norm - 1;
        coord_aero_norm_mid = zeros(num_mid_norm, 2);
        l_norm = zeros(num_mid_norm, 1);
        for i = 1:num_mid_norm
            coord_aero_norm_mid(i,:) = (coord_aero_norm(i,:) + coord_aero_norm(i+1,:)) / 2;
            l_norm(i) = spline(x_local_ala, cargas.schrenk, coord_aero_norm_mid(i,1));
            l_norm(i) = l_norm(i) * n_val * MTOW * 2 / (Lw^2);
        end
    else
        costillas_norm   = [];
        coord_aero_norm  = [];
        l_norm           = [];
    end
    
    %----- COMBINE ZONES -----
    if ~isempty(costillas_norm)
        costillas = [costillas_tri; costillas_norm];
        combined_aero = [coord_aero_tri; coord_aero_norm];
        l_combined    = [l_tri; l_norm];
    else
        costillas = costillas_tri;
        combined_aero = coord_aero_tri;
        l_combined = l_tri;
    end
    num_costillas_total = size(costillas,1);
    
    % Compute midpoints between consecutive ribs using the combined aerodynamic intersections.
    if num_costillas_total > 1
        costilla_medios = zeros(num_costillas_total-1, 2);
        for i = 1:(num_costillas_total-1)
            costilla_medios(i,:) = (combined_aero(i,:) + combined_aero(i+1,:)) / 2;
        end
    else
        costilla_medios = [];
    end
    
    load_data = l_combined;
    
    %----- Build costilla_costilla_medio -----
    % Alternate between the endpoints (first and last nodes) of each rib and the midpoint.
    costilla_costilla_medio = zeros(num_costillas_total*2 - 1, 4);
    idx = 1;
    for i = 1:(num_costillas_total-1)
        pt_start = [squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1))];
        pt_end   = [squeeze(costillas(i,1,end)), squeeze(costillas(i,2,end))];
        costilla_costilla_medio(idx,:) = [pt_start, pt_end];
        idx = idx + 1;
        pt_mid = ([squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1))] + ...
                  [squeeze(costillas(i+1,1,1)), squeeze(costillas(i+1,2,1))]) / 2;
        costilla_costilla_medio(idx,:) = [pt_mid, pt_mid];
        idx = idx + 1;
    end
    pt_last = [squeeze(costillas(end,1,1)), squeeze(costillas(end,2,1))];
    pt_last_end = [squeeze(costillas(end,1,end)), squeeze(costillas(end,2,end))];
    costilla_costilla_medio(end,:) = [pt_last, pt_last_end];
    plotStructural_ribs(avion, geom, costillas, costilla_medios, costilla_costilla_medio)
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
function plotStructuralGeometry_v0(geom, avion)
    % PLOTSTRUCTURALGEOMETRY_V0: Plots the key structural lines of the wing
    % based on computed geometry from computeStructuralGeometry_v0.
    %
    % Inputs:
    %   - geom: Structure containing all geometric parameters.
    %   - savePath: Folder path where the figure should be saved.
    %
    % Outputs:
    %   - Saves a .png file in the specified folder.

    % Initializing
    datosEstructural = avion.datosEstructural;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    x_local_ala = avion.coordenadas.x_local_ala;
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    % Create figure
    figure;
    hold on;
    title('Structural Geometry of the Wing');
    xlabel('Spanwise Coordinate (x)');
    ylabel('Chordwise Coordinate (y)');
    axis equal;
    grid on;

    % Plot key lines
    % plot(geom.x_local_ala, geom.linea_larg_anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    % plot(geom.x_local_ala, geom.linea_larg_posterior, 'b', 'LineWidth', 2, 'DisplayName', 'Larguero Posterior');
    plot(geom.x_local_ala, geom.linea_centro, 'c--', 'LineWidth', 1, 'DisplayName', 'Centro Aerodinámico');
    plot(geom.x_local_ala, geom.linea_eje, 'g--', 'LineWidth', 1, 'DisplayName', 'Eje Estructural');
    
    %% Cajón fuselaje
    plot(linspace(0,geom.Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala');
    plot(linspace(0,geom.Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(geom.Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');

    % La línea de los bordes de ataque
    plot(x_local_ala,linspace(0,y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    % La línea de los bordes de salida
    plot(x_local_ala,linspace(c1,y_global_punta_ala_borde_ataque + c2,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    
    % La línea de la cuerda final/en la punta
    plot(b/2* ones(1, numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque,y_global_punta_ala_borde_ataque+c2,numero_de_puntos_en_las_lineas),'k--');
    
    % Cajón de torsión
    plot(x_local_ala,geom.linea_larg_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion');
    plot(x_local_ala,geom.linea_larg_posterior,'r','LineWidth',3, 'HandleVisibility', 'off');
    plot(geom.Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');
    plot((geom.Lf+geom.Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');


    % Add legend
    legend('Location', 'best');
    hold off;

    % Save figure
    if nargin > 1 && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures); % ✅ Create folder if it does not exist
            disp(['📁 Created missing folder: ', avion.folder.figures]);
        end

        saveas(gcf, fullfile(avion.folder.figures, 'Step_1_wing_structural_geometry.png'));
        saveas(gcf, fullfile(avion.folder.figures, 'Step_1_wing_structural_geometry.fig'));
        disp(['Figure saved to: ', fullfile(avion.folder.figures, 'wing_structural_geometry.png')]);
    end

    close(gcf)
end


%% Función plot costillas
function plotStructural_ribs(avion, geom, costillas, costilla_medios, costilla_costilla_medio)
    % plotStructural_ribs: Plots the wing with structural ribs.
    % 
    % Inputs:
    %   - avion: Structure containing aircraft data.
    %   - geom: Structure containing geometric parameters.
    %   - costillas: Rib coordinates from generateCostillas_v0.
    %   - costilla_medios: Midpoints between ribs.
    %   - costilla_costilla_medio: Alternating endpoints and midpoints.

    datosEstructural = avion.datosEstructural;

    % Extract geometry
    Lf = geom.Lf;
    Lw = geom.Lw;
    c1 = geom.c1;
    c2 = geom.c2;
    b = avion.geometria.b;
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    % Structural data
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = geom.x_local_ala;

    % Initialize figure
    figure;
    hold on;
    title('Wing Structure with Ribs');
    xlabel('Spanwise Coordinate (x)');
    ylabel('Chordwise Coordinate (y)');
    axis equal;
    grid on;

    %% Wing outline
    plot(linspace(0, Lf, numero_de_puntos_en_las_lineas), zeros(1, numero_de_puntos_en_las_lineas), 'k--', 'DisplayName', 'Wing Root');
    plot(linspace(0, Lf, numero_de_puntos_en_las_lineas), c1 * ones(1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(Lf * ones(1, numero_de_puntos_en_las_lineas), linspace(0, c1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(zeros(1, numero_de_puntos_en_las_lineas), linspace(0, c1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');

    % Leading & trailing edges
    plot(x_local_ala, linspace(0, y_global_punta_ala_borde_ataque, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(x_local_ala, linspace(c1, y_global_punta_ala_borde_ataque + c2, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');

    % Tip chord
    plot(b / 2 * ones(1, numero_de_puntos_en_las_lineas), linspace(y_global_punta_ala_borde_ataque, y_global_punta_ala_borde_ataque + c2, numero_de_puntos_en_las_lineas), 'k');

    %% Torsion Box
    plot(x_local_ala, geom.linea_larg_anterior, 'r', 'LineWidth', 3, 'DisplayName', 'Torsion Box');
    plot(x_local_ala, geom.linea_larg_posterior, 'r', 'LineWidth', 3, 'HandleVisibility', 'off');
    plot(Lf * ones(1, numero_de_puntos_en_las_lineas), linspace(Distancia_larguero_anterior_cuerda_porcentaje * c1, c1 * Distancia_larguero_posterior_cuerda_porcentaje, numero_de_puntos_en_las_lineas), 'r', 'LineWidth', 3, 'HandleVisibility', 'off');
    plot((Lf + Lw) * ones(1, numero_de_puntos_en_las_lineas), linspace(y_global_punta_ala_borde_ataque + Distancia_larguero_anterior_cuerda_porcentaje * c2, y_global_punta_ala_borde_ataque + c2 * Distancia_larguero_posterior_cuerda_porcentaje, numero_de_puntos_en_las_lineas), 'r', 'LineWidth', 3, 'HandleVisibility', 'off');

    %% Structural Reference Lines
    plot(x_local_ala, geom.linea_centro, 'c--', 'LineWidth', 1, 'DisplayName', 'Aerodynamic Center');
    plot(x_local_ala, geom.linea_eje, 'g--', 'LineWidth', 1, 'DisplayName', 'Structural Axis');

    %% Plot ribs (costillas)
    num_costillas = size(costillas, 1);
    for i = 1:num_costillas
        if i == 1
            plot(squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'DisplayName', 'Ribs');
        else
            plot(squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'HandleVisibility', 'off');
        end
    end

    %% Midpoint connections
    num_costilla_medios = size(costilla_medios, 1);
    for i = 1:num_costilla_medios
        plot(costilla_medios(i, 1), costilla_medios(i, 2), 'bo', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
    end

    %% Midpoint-endpoint connections
    num_costilla_costilla_medio = size(costilla_costilla_medio, 1);
    for i = 1:num_costilla_costilla_medio
        plot([costilla_costilla_medio(i, 1), costilla_costilla_medio(i, 3)], [costilla_costilla_medio(i, 2), costilla_costilla_medio(i, 4)], 'b-', 'HandleVisibility', 'off');
    end

    %% Legend & Save
    legend('Location', 'best');
    hold off;

    % Save to Figures folder
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(gcf, fullfile(avion.folder.figures, 'Step_2_ribs_structure.png'));
        saveas(gcf, fullfile(avion.folder.figures, 'Step_2_ribs_structure.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Step_2_ribs_structure.png')]);
    end

    % Close figure
    close(gcf);
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
function [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
         generateCostillas_v1(geom, datosEstructural, cargas, avion)
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
