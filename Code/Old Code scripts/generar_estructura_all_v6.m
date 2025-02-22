clear all
% close all
    
addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

loadedData = load('../Data/TFG_amora.mat');
TFG_Amora = loadedData.TFG_Amora;
avion = TFG_Amora.aviones.a350_1000;
datosEstructural = TFG_Amora.datosEstructural;
cargas = TFG_Amora.aviones.a350_1000.cargas;
ala = TFG_Amora.aviones.a350_1000.ala12;
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
% nodos_larguerillos = ala.mesh.nodos_larguerillos;

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
index_larguerillos_anterior_ala = ala.mesh.index_larguerillos_anterior; % Número de intersección que hace el larguerillo con la costillas y su punto medio (Punto medio entre costillas).
nodos_posterior_ala = ala.mesh.nodos_posterior'; % Los nodos en el larguero posterior.
nodos_anterior_ala = ala.mesh.nodos_anterior'; % Los nodos en el larguero posterior.
% nodos_ala_global = ala.mesh.nodos_ala_global; % Los nodos en el larguero posterior.
% barras

barras_ala_larguero_anterior = ala.mesh.barras_ala_larguero_anterior;
barras_ala_larguero_posterior = ala.mesh.barras_ala_larguero_posterior;
barras_ala_larguerillos = ala.mesh.barras_ala_larguerillos;
% barras_ala_global = ala.mesh.barras_ala_global ;

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



%% Standardization
% Convert nodes to tables
nodos_larguerillos = squeeze(ala.mesh.nodos_larguerillos);
nodos_larguerillos(:, [3, 4]) = nodos_larguerillos(:, [4, 3]); % Swap rib/stringer if needed
nodos_larguerillos_table = convert_nodes_to_table_v2(nodos_larguerillos);

nodos_anterior_ala_table = convert_nodes_front_spars_to_table_v2(nodos_anterior_ala);
nodos_posterior_ala_table = convert_nodes_rear_spars_to_table_v2(nodos_posterior_ala);

% Create the Combined Node Table
combined_nodes = create_combined_node_table_v2(nodos_larguerillos_table, nodos_anterior_ala_table, nodos_posterior_ala_table);


%% PARAMETROS NUEVOS
threshold_distance = distancia_entre_costillas * 0.07;
[max_rib, max_stringer] = get_max_indices(nodos_larguerillos);
%% Cálculos previos

%% TEMPORARY ID SYSTEM DOCUMENTATION 
% The nodos_larguerillos vector integrates local node data with Local IDs in the 5th column.
% This script will use nodos_larguerillos for defining:
% 1. Transverse line elements (Rear Spar ↔ First Stringer, Last Stringer ↔ Front Spar)
% 2. Horizontal stiffening panels (superficies)

%% 🛠️ Initialize Constants
TEMP_ID_BASE_larguero_posterior = -1 * 10e5; % Temporary ID for Rear Spar
TEMP_ID_BASE_larguero_anterior = -2 * 10e5; % Temporary ID for Front Spar

%% 🧱 Initialize Element Matrices
barras_costillas_ala = [];                % Transverse Bar Elements
superficie_horizontal_larguero_posterior = []; % Rear Spar Horizontal Panels
superficie_horizontal_larguerillo = [];   % Stringer Horizontal Panels

%% 📊 Sort and Group Nodes by Rib Index
% % Ensure nodos_larguerillos includes Local IDs in column 5
% if size(nodos_larguerillos, 2) < 5
%     nodos_larguerillos(:, 5) = (1:size(nodos_larguerillos, 1))';
% end
% 
% % Sort by Rib (3rd col) and Stringer (4th col) while preserving Local IDs
% nodos_transversales = sortrows(nodos_larguerillos, [3, 4]);
% rib_indices = unique(nodos_transversales(:, 3)); % Unique Rib Indices

% %% 📐 Create Transverse Line Elements
% % Empezando desde el encastre hasta la punta y desde el larguero posterior
% % al larguero anterior.
% for i = 1:length(rib_indices)
%     current_rib = rib_indices(i);
%     rib_nodes = nodos_transversales(nodos_transversales(:, 3) == current_rib, :);
% 
%     % Ensure sufficient nodes in the rib
%     if size(rib_nodes, 1) < 2
%         continue;
%     end
% 
%     % Rear Spar Connection (Using Local ID)
%     barras_costillas_ala = [barras_costillas_ala; TEMP_ID_BASE_larguero_posterior + current_rib, rib_nodes(1, 5)];
% 
%     % Transverse Connections Between Consecutive Nodes (Using Local ID)
%     for j = 1:size(rib_nodes, 1) - 1
%         nodo_inicio = rib_nodes(j, 5); % Local ID of start node
%         nodo_fin = rib_nodes(j + 1, 5); % Local ID of end node
%         barras_costillas_ala = [barras_costillas_ala; nodo_inicio, nodo_fin];
%     end
% 
%     % Front Spar Connection (Using Local ID)
%     barras_costillas_ala = [barras_costillas_ala; nodo_fin, TEMP_ID_BASE_larguero_anterior + current_rib];
% end

%% 📐 Create Horizontal Stiffening Panels (Rear Spar Surfaces)
% Purpose: Create stiffening surfaces adjacent to the rear spar within a specific rib range.

% Define rib range
start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(1) + 1;
end_rib = index_larguerillos_anterior_ala(1) - 1;

% Handle Rear Spar Surfaces
superficie_horizontal_larguero_posterior = create_rear_spar_surfaces_v4(...
    combined_nodes, start_rib, end_rib);

% Optional: Plot verification
plottitle = 'Verification Plot for rear spar surface Region';
plotfilename = '../Results/Figures/plot_rear_spar_surfaces_generate_structure_v6_rear_spar_ala12_TFG';
% plot_rear_spar_surfaces(combined_nodes, superficie_horizontal_larguero_posterior, plottitle, plotfilename);


%% 📐 Create Horizontal Stiffening Panels (stringers surfaces)
% 📊 Stringer Surface Region Division: Regular and Irregular Parts

% Define rib indices for stringer surface regions:
% Regular Region: Stringers end at the last rib.
% Irregular Region: Stringers end at the front spar with non-standard geometry.

quad_surfaces_regular = table([], [], [], [], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                      'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                      'area', 'aspect_ratio'});
warnings = {};

% Loop through stringers in the regular zones
for stringer_index = 1:numero_larguerillos_costilla_final - 1
    % Define rib range from wing geometry
    start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(stringer_index) + 1;
    end_rib = max_rib;

    % Call the function to create surfaces
    [quad_surfaces, warn] = create_surfaces_for_stringer_regular_v3(...
        combined_nodes, stringer_index, start_rib, end_rib, threshold_distance);

    % Append the created surfaces and warnings
    quad_surfaces_regular = [quad_surfaces_regular; quad_surfaces];
    warnings = [warnings; warn(:)];
end

plottitle = strcat('Verification Plot for Regular Region');
plotfilename = strcat('../Results/Figures/plot_stringer_regular_surfaces_generate_structure_v6_ala12_TFG_Amora_aviones_a350_1000_datos_estructual');
plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular,plottitle, plotfilename);

% Loop through stringers in the stinger irregular zones
quad_irregular = [];
quad_rectangular_regular=[];
tri_surfaces = [];
%% 🛡️ Loop Through Stringers in the Irregular Zones
for stringer_index = numero_larguerillos_costilla_final:max_stringer - 1
    % Define start rib as usual
    start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(stringer_index) + 1;

    % Extract nodes for current and next stringers from combined_nodes
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index & ...
        combined_nodes.rib_index >= start_rib, :);

    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1 & ...
        combined_nodes.rib_index >= start_rib, :);

    % Identify unique rib indices in the next stringer
    next_rib_indices = unique(next_stringer_nodes.rib_index); % Extract unique rib indices

    % Handle irregular end rib logic
    if any(next_rib_indices == -2)
        % Remove -2 temporarily to find second-to-last rib
        valid_ribs = next_rib_indices(next_rib_indices ~= -2);

        if ~isempty(valid_ribs)
            % Safely select the maximum valid rib
            second_to_last_rib = max(valid_ribs);
        else
            % Fallback if no valid ribs exist
            warning('No valid ribs found besides -2. Using fallback rib index.');
            second_to_last_rib = -1; % Default to root rib
        end
    else
        % If -2 does not exist, use the maximum rib
        second_to_last_rib = max(next_rib_indices);
    end

    % Define end_rib dynamically
    end_rib = second_to_last_rib;

    %% ✅ Process Up to the Second-to-Last Rib (Regular-like Behavior)
    [quad_regular_stringer, warn] = create_surfaces_for_stringer_regular_v3( ...
        combined_nodes, stringer_index, start_rib, end_rib, threshold_distance);

    % Append the results
    quad_rectangular_regular = [quad_rectangular_regular; quad_regular_stringer];
    warnings = [warnings; warn(:)];
end

plottitle = strcat('Verification Plot for Irregular Region with regular rectangular surfaces');
plotfilename = strcat('../Results/Figures/plot_stringer_regular_surfaces_front_spars_generate_structure_v6_ala12_a350_1000_datos_estructual');
% plot_stringer_regular_surfaces_front_spars(combined_nodes, quad_rectangular_regular,plottitle, plotfilename);

% 
% %% 🛡️ Loop Through Stringers in the Irregular Zones
% for stringer_index = numero_larguerillos_costilla_final:max_stringer-1
%     % Define start rib as usual
%     start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(stringer_index) + 1;
% 
%     % Extract nodes for current and next stringers
%     current_stringer_nodes = nodos_larguerillos(nodos_larguerillos(:, 4) == stringer_index, :);
%     next_stringer_nodes = nodos_larguerillos(nodos_larguerillos(:, 4) == stringer_index + 1, :);
% 
%     % Identify unique rib indices in the next stringer
%     next_rib_indices = unique(next_stringer_nodes(:, 3)); % Extract unique rib indices
% 
%     % Handle irregular end rib logic
%     if any(next_rib_indices == -2)
%         % Remove -2 temporarily to find second-to-last rib
%         valid_ribs = next_rib_indices(next_rib_indices ~= -2);
% 
%         if ~isempty(valid_ribs)
%             % Safely select the maximum valid rib
%             second_to_last_rib = max(valid_ribs);
%         else
%             % Fallback if no valid ribs exist
%             warning('No valid ribs found besides -2. Using fallback rib index.');
%             second_to_last_rib = -1; % Default to root rib
%         end
%     else
%         % If -2 does not exist, use the maximum rib
%         second_to_last_rib = max(next_rib_indices);
%     end
% 
%     % Define end_rib dynamically
%     end_rib = second_to_last_rib;
% 
%     %% ✅ Process Up to the Second-to-Last Rib (Regular-like Behavior)
%     [quad_regular_stringer, warn] = create_surfaces_for_stringer_regular_v2(...
%         current_stringer_nodes, next_stringer_nodes, threshold_distance, start_rib, end_rib);
% 
%     quad_regular = [quad_regular; quad_regular_stringer];
%     warnings = [warnings; warn];
%     %% Updating the next_stringer
%     % Extract the current next stringer nodes
%     next_stringer_nodes = nodos_larguerillos(nodos_larguerillos(:, 4) == stringer_index + 1, :);
% 
%     % Find and add corresponding front spar nodes
%     % Extract front spar nodes from combined_nodes
%     front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);
% 
%     % Find front spar nodes corresponding to ribs >= the last rib in next_stringer_nodes
%     if ~isempty(next_stringer_nodes)
%         last_rib_index = next_stringer_nodes(end, 3); % Rib index of the last node in next_stringer_nodes
%     else
%         last_rib_index = -Inf; % If next_stringer_nodes is empty, use a placeholder
%     end
% 
%     % Select front spar nodes for ribs >= last_rib_index
%     additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);
% 
%     % Convert additional_nodes back to numeric format if needed
%     if ~isempty(additional_nodes)
%         additional_nodes_numeric = [additional_nodes.local_id, additional_nodes.x, additional_nodes.y, ...
%                                      additional_nodes.rib_index, NaN(size(additional_nodes, 1), 1)];
%     else
%         additional_nodes_numeric = [];
%     end
% 
%     % Append front spar nodes to the next stringer nodes
%     next_stringer_nodes = [next_stringer_nodes; additional_nodes_numeric];
% 
% 
%     %% 🛡️ Loop Through Stringers in the Irregular Zones
%     % Extract nodes for current and next stringers
% 
%     % Process irregular surfaces
%     % % Ensure next_stringer_nodes is a table
%     % if ~istable(next_stringer_nodes)
%     %     % Convert next_stringer_nodes to a table
%     %     variable_names = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
%     %     next_stringer_nodes = array2table(next_stringer_nodes, 'VariableNames', variable_names);
%     % end
%     % 
%     % % Ensure combined_nodes is also a table (if not already)
%     % if ~istable(combined_nodes)
%     %     variable_names = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
%     %     combined_nodes = array2table(combined_nodes, 'VariableNames', variable_names);
%     % end
%     % 
%     % % Update next_stringer_nodes with front spar nodes
%     % next_stringer_nodes = add_front_spar_to_next_stringer(next_stringer_nodes, combined_nodes);
% 
%     % Process irregular surfaces
%     [quad_irregular_stringer, tri, warn] = create_surfaces_for_stringer_irregular_v2(...
%         current_stringer_nodes, next_stringer_nodes, threshold_distance, start_rib);
% 
% 
% 
%     % Append results
%     quad_irregular = [quad_irregular; quad_irregular_stringer];
%     % tri_surfaces_irregular = [tri_surfaces_irregular; tri];
%     warnings = [warnings; warn];
% 
% end
% 
% 
% 
% % plottitle = strcat('Verification Plot for Irregular Region');
% % plotfilename = strcat('../Results/Figures/plot_surfaces_verification_v2_irregular_ala12_TFG_Amora_aviones_a350_1000_datos_estructual');
% % plot_surfaces_verification_v5(nodos_larguerillos_table, quad_irregular, [],nodos_anterior_ala_table,nodos_posterior_ala_table, ...
% %     'irrregular',plottitle, plotfilename);
% 
% %% ✅ Display Results
% disp('✅ Transverse Bars (barras_costillas_ala) created successfully.');
% disp('✅ Rear Spar Surfaces (superficie_horizontal_larguero_posterior) created successfully.');
% disp('✅ Stringer Surfaces (superficie_horizontal_larguerillo) created successfully.');

