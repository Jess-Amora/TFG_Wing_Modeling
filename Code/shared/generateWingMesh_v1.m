function mesh = generateWingMesh_v1(geom, costillas, datosEstructural, avion)
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
    
    %% Filtrar intersecciones fuera del ala
    counter_quitar_nodos = 0;
    index_quitar_nodos = zeros(numero_larguerillos_total,1);
    
    for i = 1:numero_larguerillos_total
        counter_quitar_nodos = 0;
        for j = 1:size(intersecciones, 2)
            x_intersect = intersecciones(i, j, 1);
            y_intersect = intersecciones(i, j, 2);
            
            % Condición para eliminar nodos fuera de los límites
            if x_intersect < Lf || x_intersect > max(nodos_anterior(1,:)) 
                counter_quitar_nodos = counter_quitar_nodos + 1;
            end
        end
        index_quitar_nodos(i) = counter_quitar_nodos;
    end
    
    % Eliminar los nodos que no cumplan los límites
    for i = 1:numero_larguerillos_total
        larguerillos(i,:,1:index_quitar_nodos(i)) = [];  % Elimina nodos fuera del dominio
    end

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