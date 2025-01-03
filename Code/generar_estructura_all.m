clear all
close all
    
loadedData = load('../Data/TFG_amora.mat');
TFG_Amora = loadedData.TFG_Amora;
avion = TFG_Amora.aviones.a350_1000;
datosEstructural = TFG_Amora.datosEstructural;
cargas = TFG_Amora.aviones.a350_1000.cargas;
ala = TFG_Amora.aviones.a350_1000.ala9;
fuselaje = TFG_Amora.aviones.a350_1000.fuselaje4;
H = 1;
% generar_estructura_v1(avion,datosEstructural,ala,fuselaje,H)

% function generar_estructura_v1(avion,datosEstructural,ala,fuselaje,H)
    % Extraer parámetros
    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha.radian;

    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;

    % Coordenadas
    x_local_ala = avion.coordenadas.x_local_ala;
    y = avion.coordenadas.y;
    x = avion.coordenadas.y;
    
    % Ala 
    numero_larguerillos_total = ala.numero_larguerillos_total;
    linea_larguero_anterior = ala.geometria.linea_larguero_anterior;
    linea_larguero_posterior = ala.geometria.linea_larguero_posterior;
    numero_costillas = ala.numero_costillas;
    numero_costillas_triangulo = ala.numero_costillas_triangulo;
    numero_larguerillos_costilla_final = ala.numero_larguerillos_costilla_final;

    % Fuselaje
    numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);
    costillas_fuselaje = fuselaje.costillas_fuselaje;
    larguerillos_fuselaje = fuselaje.larguerillos_fuselaje;

    %% Mesh ALA
    intersecciones_costillas_larguerillos_ala = ala.mesh.intersecciones_costillas_larguerillos;
    Numero_nodos_elementos_ala = ala.mesh.Numero_nodos_elementos_ala;
    id_nodo_local_larguerillo_costilla = ala.mesh.id_nodo_local_larguerillo_costilla; % dim (id_local, Lf + index_costilla, index_larguerillo)
    index_counter_quitar_nodos_larguerillos_menor_Lf = ala.mesh.index_counter_quitar_nodos_larguerillos_menor_Lf; 
    index_larguerillos_anterior = ala.mesh.index_larguerillos_anterior;

    % nodos

    nodos_larguerillos = squeeze(ala.mesh.nodos_larguerillos); % larguerillos
    index_larguerillos_anterior_ala = ala.mesh.index_larguerillos_anterior; % Número de intersección que hace el larguerillo con la costillas y su punto medio (Punto medio entre costillas).
    nodos_posterior_ala = ala.mesh.nodos_posterior'; % Los nodos en el larguero posterior.
    nodos_anterior_ala = ala.mesh.nodos_anterior'; % Los nodos en el larguero posterior.
    nodos_ala_global = ala.mesh.nodos_ala_global; % Los nodos en el larguero posterior.
    % barras

    barras_ala_larguero_anterior = ala.mesh.barras_ala_larguero_anterior;
    barras_ala_larguero_posterior = ala.mesh.barras_ala_larguero_posterior;
    barras_ala_larguerillos = ala.mesh.barras_ala_larguerillos;
    barras_ala_global = ala.mesh.barras_ala_global ;

    %% Mesh FUSELAJE
    larguerillos_fuselaje = fuselaje.larguerillos_fuselaje;
    costillas_fuselaje = fuselaje.costillas_fuselaje;
    numero_costillas_fuselaje = fuselaje.numero_costillas_fuselaje;
    
    % nodos
    
    nodos_larguerillos_fuselaje = fuselaje.mesh.nodos_larguerillos_fuselaje; % larguerillos
    nodos_posterior_fuselaje = fuselaje.mesh.nodos_posterior_fuselaje; % Los nodos en el larguero posterior.
    nodos_anterior_fuselaje = fuselaje.mesh.nodos_anterior_fuselaje; % Los nodos en el larguero posterior.
    
    % barras
    
    barras_fuselaje_larguero_posterior = fuselaje.mesh.barras_fuselaje_larguero_posterior;
    barras_fuselaje_larguero_anterior = fuselaje.mesh.barras_fuselaje_larguero_anterior;
    barras_fuselaje_larguerillos  = fuselaje.mesh.barras_fuselaje_larguerillos;

    %% 

    %% TEMPORARY ID SYSTEM DOCUMENTATION
    % 📚 Purpose
    % The Temporary ID System is designed to address missing connections between structural nodes in the wing structure model. Specifically:
    % 
    % Rear Spar → First Stringer
    % Last Stringer → Front Spar
    % These connections are crucial for completing the structural geometry but may not always be directly available in the initial local node datasets.
    % 
    % The Temporary IDs serve as placeholders to ensure:
    % 
    % Continuity: Every rib has consistent connections.
    % Modularity: Calculations can proceed without waiting for final global node assignments.
    % Traceability: Temporary connections are easily identifiable for later updates to global node IDs.
    % 🛠️ Implementation Workflow
    % Identify Missing Connections:
    % 
    % Check if nodes between rear spar → first stringer and last stringer → front spar are missing for each rib.
    % Assign Temporary IDs:
    % 
    % A unique numerical Temporary ID is assigned to each missing connection:
    % Rear Spar → First Stringer: TEMP_ID_BASE + (Rib Index * 100) + 1
    % Last Stringer → Front Spar: TEMP_ID_BASE + (Rib Index * 100) + 2
    % Perform Local Calculations:
    % 
    % Use these Temporary IDs in the connection matrix.
    % Convert to Global IDs:
    % 
    % In the final step, Temporary IDs are replaced with their corresponding Global Node IDs.
    % 📊 Temporary ID Format
    % Base ID: -100000
    % ID Formula: TEMP_ID_BASE + (Rib Index * 100) + Offset
    % Offset 1: Rear Spar → First Stringer
    % Offset 2: Last Stringer → Front Spar
    % Example: For the 25th rib:
    % 
    % Rear Spar → First Stringer: -102501
    % Last Stringer → Front Spar: -102502
    % Initialize temporary IDs

    TEMP_ID_BASE_larguero_posterior = -1 * 10e5;  % Es la base de la id provisional
    TEMP_ID_BASE_larguero_anterior = -2 * 10e5;  % Es la base de la id provisional

    %% Creando Los elementos en los larguerillos en la dirección transversal larguero posterior-anterior
    % Inicializar matriz de barras para costillas
    barras_costillas_ala = [];
    
    % Ordenar nodos por costilla (columna 2)
    nodos_transversales = sortrows(id_nodo_local_larguerillo_costilla, 2);
    % max_costilla_costilla_media = max(id_nodo_local_larguerillo_costilla(:,2);

    % Recorrer cada larguerillo (elemento en columna 3)
    for index_costilla = 1:max(id_nodo_local_larguerillo_costilla(:,2))
        % Extraer nodos pertenecientes al larguerillo actual
        nodos_actuales = nodos_transversales(nodos_transversales(:,2) == index_costilla, :);
        
        % Comprobar si hay suficientes nodos en el larguerillo
        if size(nodos_actuales,1) < 2
            continue; % No hay suficientes nodos para crear barras
        end
        
        % Mitiendo el nodo en el larguero posterior
        barras_costillas_ala = [barras_costillas_ala; TEMP_ID_BASE_larguero_posterior - index_costilla, nodos_actuales(1,1)];


        % Crear conexiones entre costillas (nodos consecutivos)
        for i = 1:size(nodos_actuales,1)-1
            nodo_inicio = nodos_actuales(i,1);
            nodo_fin = nodos_actuales(i+1,1);
            

            barras_costillas_ala = [barras_costillas_ala; nodo_inicio, nodo_fin];

        end

        % Mitiendo el nodo en el larguero anterior
        barras_costillas_ala = [barras_costillas_ala; nodo_fin, TEMP_ID_BASE_larguero_anterior - index_costilla];


    end

    %% Paneles rigidizadores horizontales
    % Disclaimer: I want to simplify everything. There are many cases that
    % could happend when you change the structural parameters. I am
    % limiting those structural parameters by not changing a lot most of
    % them, specially, the geometric parameters.
    % In the first surface, which is in the corner rear_spar-root, I do not
    % know, if I need to do some previous calculations, but the data
    % suggest not necesarry.

    
    superficie_horizontal_larguero_pasterior = [];
    superficie_horizontal_larguerillo = [];
    
    for index_costilla = index_counter_quitar_nodos_larguerillos_menor_Lf(1) + 1 : index_larguerillos_anterior_ala(1)-1
        target_ribs = [index_costilla, index_costilla + 1];         % Specific ribs
        target_stringers = [1];  % Specific stringers

        % Logical indexing with pair matching
        matching_rows = (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
                        (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) ;

        % Extract Node IDs
        node_ids = id_nodo_local_larguerillo_costilla(matching_rows, 1);
        
        % Guardando las superficies 
        superficie_horizontal_larguero_pasterior = [superficie_horizontal_larguero_pasterior; TEMP_ID_BASE_larguero_posterior-index_costilla, TEMP_ID_BASE_larguero_posterior-index_costilla-1, node_ids(1),node_ids(2) ];
    end

    for index_larguerillo = 1: numero_larguerillos_costilla_final

        for index_costilla = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo) + 1 : index_larguerillos_anterior_ala(index_larguerillo)-1

            % Specific rib and stringer criteria
            target_ribs = [index_costilla, index_costilla + 1];         % Specific ribs
            target_stringers = [index_larguerillo, index_larguerillo + 1];  % Specific stringers
    
            % Logical indexing with pair matching
            matching_rows = (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2));
    
            % Extract Node IDs
            node_ids = id_nodo_local_larguerillo_costilla(matching_rows, 1);
            size(node_ids)
            % Guardando las superficies 
            superficie_horizontal_larguerillo = [superficie_horizontal_larguerillo; node_ids(1), node_ids(3), node_ids(2),node_ids(4) ];
        end
    end
    
    for index_larguerillo = numero_larguerillos_costilla_final+1: numero_larguerillos_total

        for index_costilla = index_counter_quitar_nodos_larguerillos_menor_Lf(index_larguerillo) + 1 : index_larguerillos_anterior_ala(index_larguerillo)-1

            % Specific rib and stringer criteria
            target_ribs = [index_costilla, index_costilla + 1];         % Specific ribs
            target_stringers = [index_larguerillo, index_larguerillo + 1];  % Specific stringers
    
            % Logical indexing with pair matching
            matching_rows = (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
                            (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2));
    
            % Extract Node IDs
            node_ids = id_nodo_local_larguerillo_costilla(matching_rows, 1);
    
            % Guardando las superficies 
            superficie_horizontal_larguerillo = [superficie_horizontal_larguerillo; node_ids(1), node_ids(3), node_ids(2),node_ids(4) ];
        end
    end




    



    % % Larguerillo (Dentro de la "superficie alar")
    % for i = 1: size(nodos_largueros_posterior,1)
    % 
    %     % Specific rib and stringer criteria
    %     target_ribs = [5, 6];         % Specific ribs
    %     target_stringers = [10, 11];  % Specific stringers
    % 
    %     % Logical indexing with pair matching
    %     matching_rows = (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
    %                     (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(1) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2)) | ...
    %                     (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(1)) | ...
    %                     (id_nodo_local_larguerillo_costilla(:,2) == target_ribs(2) & id_nodo_local_larguerillo_costilla(:,3) == target_stringers(2));
    % 
    %     % Extract Node IDs
    %     node_ids = id_nodo_local_larguerillo_costilla(matching_rows, 1);
    % 
    % end

    





    % %% ============================================================
    % %                   📖 3D WING STRUCTURE DOCUMENTATION 📖
    % % ============================================================
    % % **Objective:**
    % % Transform the current 2D wing node structure into a 3D representation.
    % % This section focuses on generating nodes and elements for:
    % %   - Ribs (Costillas)
    % %   - Spars (Largueros)
    % %   - Stringers (Larguerillos)
    % % A simplified constant z-coordinate will be applied for initial geometry.
    % 
    % % **Key Goals:**
    % % 1. Transform existing 2D nodes into 3D space using a fixed z-value.
    % % 2. Generate vertical surfaces for ribs and spars.
    % % 3. Validate the structural connectivity between nodes.
    % % 4. Prepare the model for FEM analysis.
    % 
    % % **Inputs:**
    % % - nodos_larguerillos (Nx2 matrix): Nodes for stringers
    % % - nodos_posterior_ala (Nx2 matrix): Nodes for rear spar
    % % - nodos_anterior_ala (Nx2 matrix): Nodes for front spar
    % % - numero_costillas: Number of ribs along the wing span
    % % - distancia_entre_costillas: Rib spacing along the wing span
    % 
    % % **Outputs:**
    % % - nodos_3D: 3D coordinates for all wing nodes
    % % - barras_3D: Connectivity matrix for ribs, spars, and stringers
    % % - Visualization plots for validation
    % 
    % % ============================================================
    % %                      🛠️ STEP 1: Coordinate Transformation
    % % ============================================================
    % 
    % % Apply a fixed z-value to create 3D nodes from the existing 2D structure
    % z_value_extra = 0.25; % Placeholder for Z-axis (can be updated later)
    % z_value_intra = -0.25; % Placeholder for Z-axis (can be updated later)
    % 
    % % Voy a considerar que todos los nodos hechos hasta ahora son de
    % % extrados.
    % 
    % nodos_posterior_ala_extra = [nodos_posterior_ala, z_value_extra * ones(size(nodos_posterior_ala, 1), 1)];
    % nodos_anterior_ala_extra = [nodos_anterior_ala, z_value_extra * ones(size(nodos_anterior_ala, 1), 1)];
    % nodos_larguerillos_extra = [nodos_larguerillos, z_value_extra * ones(size(nodos_larguerillos, 1), 1)];
    % 
    % nodos_posterior_ala_intra = [nodos_posterior_ala, z_value_intra * ones(size(nodos_posterior_ala, 1), 1)];
    % nodos_anterior_ala_intra = [nodos_anterior_ala, z_value_intra * ones(size(nodos_anterior_ala, 1), 1)];
    % nodos_larguerillos_intra = [nodos_larguerillos, z_value_intra * ones(size(nodos_larguerillos, 1), 1)];

    % Combine all nodes into a single matrix
    % nodos_3D = [nodos_posterior_ala_3D; nodos_anterior_ala_3D; nodos_larguerillos_3D];
    % 
    % % ============================================================
    % %               🛠️ STEP 2: Generate Rib and Spar Surfaces
    % % ============================================================
    % 
    % % Create vertical ribs at each rib location
    % for i = 1:numero_costillas
    %     rib_nodes = [nodos_posterior_ala_3D(i,:); nodos_anterior_ala_3D(i,:)];
    %     patch(rib_nodes(:,1), rib_nodes(:,2), rib_nodes(:,3), 'b'); % Visualize rib surface
    %     hold on;
    % end
    % 
    % % Create spar lines (anterior and posterior)
    % plot3(nodos_posterior_ala_3D(:,1), nodos_posterior_ala_3D(:,2), nodos_posterior_ala_3D(:,3), '-o');
    % plot3(nodos_anterior_ala_3D(:,1), nodos_anterior_ala_3D(:,2), nodos_anterior_ala_3D(:,3), '-o');
    % 
    % % ============================================================
    % %                🛠️ STEP 3: Temporary ID Assignment
    % % ============================================================
    % 
    % % Assign temporary IDs for nodes and elements
    % [TEMP_ID_BASE_larguero_posterior, TEMP_ID_BASE_larguero_anterior] = deal(-1e5, -2e5);
    % barras_costillas_ala = [];
    % 
    % for index_costilla = 1:numero_costillas
    %     nodos_actuales = nodos_larguerillos_3D(index_costilla, :);
    % 
    %     if size(nodos_actuales, 1) < 2
    %         continue;
    %     end
    % 
    %     % Connection between rear spar and first stringer
    %     barras_costillas_ala = [barras_costillas_ala; TEMP_ID_BASE_larguero_posterior - index_costilla, nodos_actuales(1,1)];
    % 
    %     % Connections between stringers
    %     for i = 1:size(nodos_actuales,1)-1
    %         nodo_inicio = nodos_actuales(i,1);
    %         nodo_fin = nodos_actuales(i+1,1);
    %         barras_costillas_ala = [barras_costillas_ala; nodo_inicio, nodo_fin];
    %     end
    % 
    %     % Connection between last stringer and front spar
    %     barras_costillas_ala = [barras_costillas_ala; nodo_fin, TEMP_ID_BASE_larguero_anterior - index_costilla];
    % end
    % 
    % % ============================================================
    % %                   🛠️ STEP 4: Validation Plot
    % % ============================================================
    % 
    % figure;
    % hold on;
    % scatter3(nodos_3D(:,1), nodos_3D(:,2), nodos_3D(:,3), 50, 'filled');
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % zlabel('Z-axis');
    % grid on;
    % axis equal;
    % title('3D Wing Node Representation');
    % hold off;
    % 
    % % ============================================================
    % %                   📊 Outputs Summary
    % % ============================================================
    % % nodos_3D: Combined 3D nodes matrix
    % % barras_costillas_ala: Connectivity between ribs, spars, and stringers
    % 
    % % ============================================================
    % %              ✅ NEXT STEPS AND REMINDERS
    % % ============================================================
    % % 1. Refine Z-coordinate variation based on theoretical NACA profile.
    % % 2. Validate connectivity matrices.
    % % 3. Export data for Nastran/Patran FEM analysis.
    % % 4. Document and ensure code clarity.
    % 
    % % ============================================================
    % %           🤝 Collaboration is our Superpower!
    % % ============================================================
    % % Remember: If anything feels unclear or challenging, just let me know!
    % % We're in this together. 🚀✨




% %     % Visualization sólo nodos larguerillos sin los nodos en los
% largueros, es decir, los temp id_s
% % figure;
% % hold on;
% % grid on;
% % axis equal;
% % title('Validation Plot: Transversal Bars on Ribs');
% % 
% % % Plot nodes
% % scatter(nodos_larguerillos(:,1), nodos_larguerillos(:,2), 50, 'filled');
% % text(nodos_larguerillos(:,1), nodos_larguerillos(:,2), num2str((1:size(nodos_larguerillos,1))'), 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
% % 
% % % Plot bars
% % nodos_larguerillos = squeeze(nodos_larguerillos);
% % for i = 1:size(barras_costillas_ala,1)
% %     plot(nodos_larguerillos(barras_costillas_ala(i,:),1), ...
% %          nodos_larguerillos(barras_costillas_ala(i,:),2), '-o');
% % end
% 
% xlabel('X Coordinate');
% ylabel('Y Coordinate');
% legend('Nodes', 'Bars');
% hold off;




























    % 
    % nodos = {nodos_posterior_ala', nodos_anterior_ala', squeeze(nodos_larguerillos),nodos_posterior_fuselaje, nodos_anterior_fuselaje, squeeze(nodos_larguerillos_fuselaje) };
    % 
    % elementos = {barras_ala_larguero_posterior', barras_ala_larguero_anterior', barras_ala_larguerillos', barras_fuselaje_larguero_posterior',barras_fuselaje_larguero_anterior', barras_fuselaje_larguerillos' };
    % 
    % [globalNodes, localToGlobalMap] = assignNodeIDs(nodos_posterior_ala', nodos_anterior_ala', squeeze(nodos_larguerillos),nodos_posterior_fuselaje, nodos_anterior_fuselaje, squeeze(nodos_larguerillos_fuselaje) );
    % globalElements = mapLocalToGlobalElements(elementos, localToGlobalMap);
    % 
    % 




    % size(barras_ala_larguero_anterior')
    % size(localToGlobalMap)


    % elementsGlobal = localToGlobalMap{1}(barras_ala_larguero_anterior', 2); % Extraer IDs globales
    % size(localToGlobalMap)
    % globalElements = mapElementIDs(barras_ala_larguero_anterior, localToGlobalMap);
    % globalElements = mapLocalToGlobalElements(elementos, localToGlobalMap);







%     function globalElements = mapElementIDs(localElements, localToGlobalMap)
%     % Inputs:
%     % - localElements: Matriz de elementos con IDs de nodos locales (NxM)
%     % - localToGlobalMap: Mapeo local a global (matriz Nx2)
%     % Outputs:
%     % - globalElements: Matriz de elementos con IDs globales (NxM)
% 
%     globalElements = zeros(size(localElements)); % Preasignar matriz global
% 
%     for i = 1:size(localElements, 1)
%         for j = 1:size(localElements, 2)
%             % Buscar el ID global correspondiente al nodo local
%             globalID = localToGlobalMap(localElements(i, j), 2);
%             globalElements(i, j) = globalID;
%         end
%     end
% end


% end


% Apéndice

% size(nodos_posterior_ala') % Should return [N, 2]
% size(barras_ala_larguero_posterior') % Should return [N, 2]
% 
% size(nodos_anterior_ala')  % Should return [N, 2]
% size(barras_ala_larguero_anterior')  % Should return [N, 2]
% 
% size(squeeze(nodos_larguerillos))  % Should return [N, 2]
% size(barras_ala_larguerillos')  % Should return [N, 2]
% 
% size(nodos_posterior_fuselaje)
% size(barras_fuselaje_larguero_posterior')
% 
% size(nodos_anterior_fuselaje)
% size(barras_fuselaje_larguero_anterior')
% 
% size(squeeze(nodos_larguerillos_fuselaje))
% size(barras_fuselaje_larguerillos')
