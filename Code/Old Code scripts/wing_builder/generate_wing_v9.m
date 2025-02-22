function [results] = generate_wing_v9(avion, cargas)
%GENERATE_WING_V7 Robust and modular generation of the wing FEA model.
%
%   Inputs:
%       avion            - Aircraft geometry and parameters.
%       cargas           - Aerodynamic load distribution structure.
%
%   Output:
%       results          - Structure containing geometry, ribs, stringers, and mesh.
%

    datosEstructural = avion.datosEstructural;
    
    %% Step 1: Compute Structural Geometry
    geom_struct = computeStructuralGeometry_0(avion);
    plotStructuralGeometry_v0(geom_struct, avion);
    %% Step 2: Generate Ribs (Costillas)
    ribs_struct = generateCostillas_1(geom_struct, cargas, avion);
    plotStructural_ribs_v0(avion, geom_struct, ribs_struct)
    % [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
    %     generateCostillas(geom, datosEstructural, cargas, avion);
    % 
    % %% Step 3: Generate Stringers (Larguerillos)
    % larguerillos = generateLarguerillos_v0(geom, ribs_struct, avion);
    % spar_nodes = generate_spar_nodes(ribs_struct)
    % 
    % %% Step 4:
    % [index_larguerillos_anterior, index_counter_quitar, intersecciones] = analyze_larguerillos_v0(...
    % larguerillos, nodos_posterior, nodos_anterior, ribs_struct, avion, numero_costillas, numero_larguerillos_costilla_final);
    % 
    %% Step 4: Generate Wing Mesh using costillas and larguerillos
    mesh_struct = generateWingMesh_3(geom_struct, ribs_struct, avion);
    plotAla2Dlarguerillo_0(avion,geom_struct, ribs_struct,mesh_struct);
    plotAla2D_mesh_solo_nodos_v7(avion,geom_struct,ribs_struct,mesh_struct);
    % 
    %% Assemble results structure
    results = struct();
    % results.costillas = costillas;
    % results.numero_costillas = num_costillas;
    % results.numero_costillas_triangulo = num_costillas_tri;
    % results.costilla_costilla_medio = costilla_costilla_medio;
    % results.larguerillos = larguerillos;
    % results.mesh = mesh;
    % results.coord_aerodinamica_costillas_punto_medio = costilla_medios;
    results.geom_struct = geom_struct;
    results.ribs_struct = ribs_struct;
    results.mesh_struct = mesh_struct;
    disp('Wing model generation complete.');
end

%% ------------------------------------------------------------------------
function larguerillos = generateLarguerillos_v0(geom, ribs_struct, avion)
%GENERATELARGUERILLOS_V0 Generates the stringer (larguerillo) nodes.
%
%   This function computes the positions for the stringers based on the
%   geometry and the previously computed ribs.
%
%   Inputs:
%       geom            - Structural geometry structure.
%       costillas       - Rib coordinates array.
%       datosEstructural- Structural parameters.
%       avion           - Aircraft data (used to extract y_global).
%
%   Output:
%       larguerillos    - Array (numero_larguerillos_total x 2 x numero_points)
%                         with the (x,y) coordinates along each stringer.
%

    numero_points = datosEstructural.numero_de_puntos_en_las_lineas;
    c1  = geom.c1;
    Lf  = geom.Lf;
    Lw  = geom.Lw;
    c2  = geom.c2;
    datosEstructural = avion.datosEstructural;
    costillas = ribs_struct.costillas;

    % Structural chord percentages and spacing for stringers
    Dist_post = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    Dist_ant  = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    delta_larguerillo = datosEstructural.distancia_entre_larguerillo;
    
    % Determine number of stringers based on chord length
    longitud_porcentaje = Dist_post - Dist_ant;
    numero_larguerillos_total = floor(c1 * longitud_porcentaje / delta_larguerillo);
    % Also determine how many stringers come from the costilla domain
    numero_larguerillos_costilla_final = floor( norm( squeeze(costillas(end,:,1)) - squeeze(costillas(end,:,end)) ) / delta_larguerillo );
    
    % Preallocate larguerillos array
    larguerillos = zeros(numero_larguerillos_total, 2, numero_points);
    
    % Compute the "attachment" coordinates (encastre)
    coord_encastre_x = Lf * ones(numero_larguerillos_total,1);
    coord_encastre_y = c1 * Dist_post - delta_larguerillo * ( (1:numero_larguerillos_total)' );
    % Compute the posterior stringer slope (from the posterior line)
    pendiente_post = (geom.linea_larg_posterior(end) - geom.linea_larg_posterior(1)) / Lw;
    constante_encastre = coord_encastre_y - pendiente_post * coord_encastre_x;
    
    % (A) For stringers aligned with the costilla domain:
    y_global = avion.geometria.y_global_punta_ala_borde_ataque;
    for i = 1:numero_larguerillos_costilla_final
        x_line = linspace(Lf, Lf+Lw, numero_points);
        y_start = c1 * Dist_post - i * delta_larguerillo;
        y_end   = y_global + c2 * Dist_post - i * delta_larguerillo;
        y_line = linspace(y_start, y_end, numero_points);
        larguerillos(i,:,:) = [x_line; y_line];
    end
    
    % (B) For the remaining stringers, compute connection with the anterior edge.
    % First compute the anterior stringer slope and intercept.
    pendiente_ant = (geom.linea_larg_anterior(end) - geom.linea_larg_anterior(1)) / Lw;
    const_ant = geom.linea_larg_anterior(1) - pendiente_ant * Lf;
    for i = numero_larguerillos_costilla_final+1 : numero_larguerillos_total
        % Find intersection with the anterior edge
        x_int = -(const_ant - constante_encastre(i)) / (pendiente_ant - pendiente_post);
        y_int = pendiente_ant * x_int + const_ant;
        x_line = linspace(Lf, x_int, numero_points);
        y_start = c1 * Dist_post - i * delta_larguerillo;
        y_line = linspace(y_start, y_int, numero_points);
        larguerillos(i,:,:) = [x_line; y_line];
    end
end

%% ------------------------------------------------------------------------
function mesh = generateWingMesh_v0(geom, costillas, larguerillos, datosEstructural, avion)
%GENERATEWINGMESH_V0 Generates the wing mesh based on ribs and stringers.
%
%   This function computes the edge nodes (posterior and anterior) from the
%   rib data and then integrates the pre‐computed stringers (larguerillos)
%   into the mesh structure.
%
%   Inputs:
%       geom            - Structural geometry.
%       costillas       - Rib coordinates (num_costillas x 2 x numero_points).
%       larguerillos    - Stringer nodes computed in generateLarguerillos_v0.
%       datosEstructural- Structural parameters.
%       avion           - Aircraft data.
%
%   Output:
%       mesh            - Mesh structure containing node positions and indices.
%

    numero_points = datosEstructural.numero_de_puntos_en_las_lineas;
    
    %% Compute Edge Nodes from Rib Data
    num_costillas = size(costillas,1);
    puntos_medio_posterior = zeros(num_costillas-1, 2);
    puntos_medio_anterior  = zeros(num_costillas-1, 2);
    for i = 2:num_costillas
        puntos_medio_posterior(i-1,:) = (squeeze(costillas(i, :, 1)) + squeeze(costillas(i-1, :, 1))) / 2;
        puntos_medio_anterior(i-1,:)  = (squeeze(costillas(i, :, end)) + squeeze(costillas(i-1, :, end))) / 2;
    end
    
    % Merge the rib endpoints and midpoints into edge node lists
    nodos_posterior = interleave_matrices(squeeze(costillas(:,:,1))', puntos_medio_posterior');
    nodos_anterior  = interleave_matrices(squeeze(costillas(:,:,end))', puntos_medio_anterior');
    
    %% Count and Store Node Information
    num_nodos_posterior = size(nodos_posterior,2);
    num_nodos_anterior  = size(nodos_anterior,2);
    Numero_nodos_elementos_ala = zeros(2 + size(larguerillos,1), 2);
    Numero_nodos_elementos_ala(1,1) = num_nodos_posterior;
    Numero_nodos_elementos_ala(2,1) = num_nodos_anterior;
    
    %% Compute Intersection Indices for Stringers
    % This uses your provided function to compute intersections between each
    % larguerillo (using its first slice, i.e. x-coordinates) and the posterior edge.
    pendiente_post = (geom.linea_larg_posterior(end) - geom.linea_larg_posterior(1)) / geom.Lw;
    intersecciones = cortes_de_dos_funciones_lineales_v3( squeeze(larguerillos(:,:,1)), ...
                           pendiente_post, ...
                           [nodos_posterior(1:2,:)]', ... % posterior edge nodes as reference
                           geom.pendiente_perp );
    index_intersections = sum(intersecciones(:,:,1) < geom.Lf, 2);
    
    %% Assemble Mesh Structure
    mesh = struct();
    mesh.nodos_posterior = nodos_posterior;
    mesh.nodos_anterior  = nodos_anterior;
    mesh.larguerillos    = larguerillos;
    mesh.Numero_nodos_elementos_ala = Numero_nodos_elementos_ala;
    mesh.index_intersections = index_intersections;
    mesh.nodos_intersecciones = intersecciones;
    
    fprintf('Generated mesh with %d stringers, %d posterior nodes, and %d anterior nodes.\n', ...
            size(larguerillos,1), num_nodos_posterior, num_nodos_anterior);
end
function [index_larguerillos_anterior, index_counter_quitar_nodos_larguerillos_menor_Lf, intersecciones_costillas_larguerillos] = analyze_larguerillos_v0(...
    larguerillos, nodos_posterior, nodos_anterior, costilla_costilla_medio, Lf, linea_larg_anterior, avion, numero_costillas, numero_larguerillos_costilla_final)
% ANALYZE_LARGUERILLOS_V0 Analyzes stringer intersections and removes out‐of-bound ones.
%
%   This function examines the stringers (larguerillos) to:
%       - Determine, for each stringer, the index of the last node in the anterior
%         edge (nodos_anterior) that is valid based on the stringer’s endpoint.
%       - Compute intersections between the stringer “start points” and the rib
%         connection lines (costilla_costilla_medio).
%       - Count, for each stringer, how many intersections occur to the left of the
%         fuselage (x < Lf) or to the right of the front spar.
%
%   Inputs:
%       larguerillos               - 3D array of stringer coordinates (N x 2 x num_points)
%       nodos_posterior            - Node coordinates from the posterior edge (from ribs)
%       nodos_anterior             - Node coordinates from the anterior edge (from ribs)
%       costilla_costilla_medio    - Matrix of endpoints and midpoints between ribs (M x 4)
%       Lf                         - Fuselage half-length (starting from mid fuselage)
%       linea_larg_anterior        - Front spar line (vector of y-values corresponding to x_local_ala)
%       avion                      - Aircraft data (contains x_local_ala and geometry info)
%       numero_costillas           - Total number of ribs (costillas)
%       numero_larguerillos_costilla_final - Number of stringers associated with the rib domain
%
%   Outputs:
%       index_larguerillos_anterior                - 1 x N array of intersection indices per stringer.
%       index_counter_quitar_nodos_larguerillos_menor_Lf - N x 1 array counting intersections
%                                                        to remove (left of Lf or right of front spar).
%       intersecciones_costillas_larguerillos      - Intersection points array (N x numero_costillas x 2)
%

    % Total number of stringers (larguerillos)
    numero_larguerillos_total = size(larguerillos, 1);
    
    % Initialize index for each stringer using the total number of posterior nodes.
    index_larguerillos_anterior = size(nodos_posterior, 2) * ones(1, numero_larguerillos_total);
    
    % For each stringer beyond the rib-based domain, find the last node in the anterior edge
    % that is less than or equal to the stringer’s endpoint.
    for i = numero_larguerillos_costilla_final+1 : numero_larguerillos_total
        endpoint = squeeze(larguerillos(i, :, end))';  % [x, y] endpoint of the stringer
        indices = find(nodos_anterior(1, :) <= endpoint(1) & nodos_anterior(2, :) <= endpoint(2));
        if ~isempty(indices)
            index_larguerillos_anterior(i) = max(indices);
        else
            index_larguerillos_anterior(i) = -1; % No valid connection found.
        end
    end
    
    % Compute the posterior stringer slope and its perpendicular.
    % (We assume these are not directly provided; so derive from the geometry.)
    x_local_ala = avion.coordenadas.x_local_ala;
    linea_larg_posterior = avion.geometria.linea_larg_posterior; % assumed available
    Lw = avion.geometria.Lw;
    pendiente_larguero_posterior = (linea_larg_posterior(end) - linea_larg_posterior(1)) / Lw;
    tol = 1e-8;
    if abs(pendiente_larguero_posterior) < tol
        pendiente_perpendicular_larguero_posterior = Inf;
    else
        pendiente_perpendicular_larguero_posterior = -1 / pendiente_larguero_posterior;
    end
    
    % Compute intersections between the stringers (using their first slice) and the rib
    % connection endpoints (first two columns of costilla_costilla_medio).
    intersecciones_costillas_larguerillos = cortes_de_dos_funciones_lineales_v3( ...
        squeeze(larguerillos(:,:,1)), pendiente_larguero_posterior, ...
        costilla_costilla_medio(:,1:2), pendiente_perpendicular_larguero_posterior);
    
    % Define the x-coordinate of the front spar end.
    % Here we assume the anterior spar is defined by the x-coordinates in x_local_ala.
    front_spar_x_end = max(x_local_ala);
    
    % For each stringer, count the intersections that are out-of-bound.
    % An intersection is considered out-of-bound if its x-coordinate is
    %   (a) less than Lf (i.e. to the left of the fuselage) OR
    %   (b) greater than the front spar end.
    index_counter_quitar_nodos_larguerillos_menor_Lf = zeros(numero_larguerillos_total, 1);
    
    for i = 1:numero_larguerillos_total
        counter = 0;
        for j = 1:numero_costillas
            x_int = intersecciones_costillas_larguerillos(i, j, 1);
            if x_int < Lf || x_int > front_spar_x_end
                counter = counter + 1;
            end
        end
        index_counter_quitar_nodos_larguerillos_menor_Lf(i) = counter;
    end
end

