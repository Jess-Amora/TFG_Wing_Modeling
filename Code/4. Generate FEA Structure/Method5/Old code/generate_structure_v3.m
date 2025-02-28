%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
name = "Airbus_A380_Structural_parameters_A350";
avion = TFG_Amora.aviones.(name);

% predim = avion.
% 
% function results = generate_structure(avion)
% close all
    
% H = 1;
% generar_estructura_v1(avion,datosEstructural,ala,fuselaje,H)

datosEstructural = avion.datosEstructural;
ala = avion.ala;
fuselaje = avion.fuselaje;

% function generar_estructura_v1(avion,datosEstructural,ala,fuselaje,H)
% Extraer parámetros
% Geometría
Lf = avion.geometria.Lf;
Lw = avion.geometria.Lw;
c1 = avion.geometria.c1;
c2 = avion.geometria.c2;
b = avion.geometria.b;

y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
flecha_radianes = avion.geometria.flecha_radian;

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
% num_stringers_last_rib = ala.num_stringers_last_rib;
% nodos_larguerillos = ala.mesh.nodos_larguerillos;

% Fuselaje
numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);
costillas_fuselaje = fuselaje.costillas_fuselaje;
larguerillos_fuselaje = fuselaje.larguerillos_fuselaje;

% % Folders
% % Check if the folder exists
% folder_method = fullfile(avion.folder.data,"\methodtest");
% folder_parts = fullfile(folder_method,"\parts");
% 
% if ~exist(folder_method, 'dir')
%     mkdir(folder_method); % Create the folder if it does not exist
%     fprintf('Folder "%s" created successfully.\n', folder_method);
% end
% if ~exist(folder_parts, 'dir')
%     mkdir(folder_parts); % Create the folder if it does not exist
%     fprintf('Folder "%s" created successfully.\n', folder_parts);
% end


%% Mesh ALA
intersecciones_costillas_larguerillos_ala = ala.mesh.intersecciones_costillas_larguerillos;
Numero_nodos_elementos_ala = ala.mesh.Numero_nodos_elementos_ala;
id_nodo_local_larguerillo_costilla = ala.mesh.id_nodo_local_larguerillo_costilla; % dim (id_local, Lf + index_costilla, index_larguerillo)
index_counter_quitar_nodos_larguerillos_menor_Lf = ala.mesh.index_counter_quitar_nodos_larguerillos_menor_Lf; 
index_larguerillos_anterior = ala.mesh.index_larguerillos_anterior;
inserted_nodes = ala.mesh.inserted_nodes;
% nodos
index_larguerillos_anterior_ala = ala.mesh.index_larguerillos_anterior; % Número de intersección que hace el larguerillo con la costillas y su punto medio (Punto medio entre costillas).
nodos_posterior_ala = ala.mesh.nodos_posterior'; % Los nodos en el larguero posterior.
nodos_anterior_ala = ala.mesh.nodos_anterior'; % Los nodos en el larguero posterior.


%% Mesh 
combined_nodes = ala.mesh.combined_nodes;   
combined_nodes_fuselaje = fuselaje.mesh.combined_nodes;
% combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, avion.perfil.airfoil, 0.2, true);
% combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, avion.perfil.airfoil, Lf, Lw,  y_global_punta_ala_borde_ataque );

% Temporary
%% Materiales
% Example: Material Information
material_info = struct();
material_info.material_id = 1; % Material ID (MID)
material_info.E = 69000;      % Young's modulus in MPa
material_info.nu = 0.33;      % Poisson's ratio
material_info.rho = 2.7e-9;   % Density in tonne/mm³ (optional)

% Example: Property Information
property_info = struct();
property_info.property_id = 1;   % Property ID (PID)
property_info.material_id = 1;   % Associated Material ID (MID)
property_info.A = 0.01;          % Cross-sectional area in m²

% Sample pshell
pshell_info = struct( ...
    'property_id', 1, ...      % PSHELL ID (PID) in the .bdf file
    'material_id', 1, ...      % Associated Material ID (MID)
    'thickness', 2.1, ...      % Shell thickness (in mm or meters, depending on the model)
    'bending_id', 1, ...       % Bending stiffness (usually same as MID)
    't_shear', 1.0, ...        % Transverse shear thickness factor (T)
    'material_mid2', 0, ...    % Second material for composite layups (if applicable)
    'tension_mid3', 0, ...     % Tension-only material (usually not used)
    'material_mid4', 0);       % Fourth material property (for advanced applications)

% combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H);
% [nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
% write_bdf_points_v2(fullfile(folder_parts,"\nodes.bdf"), nodes);
%% PARAMETROS NUEVOS
threshold_distance = distancia_entre_costillas * 0.07;

% Call the function
[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes);

quad_rear_spar_wing = []; % Rear Spar Horizontal Panels


%% 📐 Create Horizontal Stiffening Panels (Rear Spar Surfaces)
% Purpose: Create stiffening surfaces adjacent to the rear spar within a specific rib range.

% Handle Rear Spar Surfaces
quad_rear_spar_wing = create_rear_spar_surfaces(...
    combined_nodes);

% 
% quad_rear_spar_wing_3D = preprocess_3D_quads(quad_rear_spar_wing);
% quad_rear_spar_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quad_rear_spar_wing_3D]);
% write_bdf_quads_v1(fullfile(folder_parts,"\test.bdf"), quad_rear_spar_wing_3D_processed, [], pshell_info, material_info);
% disp('until here')
% plottitle = 'Verification Plot for rear spar surface Region';
% plotfilename = '../Results/Figures/plot_rear_spar_surfaces_generate_structure_v6_rear_spar_ala12_TFG';
% plot_rear_spar_surfaces(combined_nodes, quad_rear_spar_wing, plottitle, plotfilename);


%% 📐 Create Horizontal Stiffening Panels (stringers surfaces)
% 📊 Stringer Surface Region Division: Regular and Irregular Parts

% Define rib indices for stringer surface regions:
% Regular Region: Stringers end at the last rib.
% Irregular Region: Stringers end at the front spar with non-standard geometry.

quad_surfaces_regular = quad_initialize();
warnings = {};

% Loop through stringers in the regular zones
for stringer_index = 1:num_stringers_last_rib - 1

    % Call the function to create surfaces
    [quad_surfaces, warn] = create_surfaces_for_stringer_regular_v3(...
        combined_nodes, stringer_index);

    % Append the created surfaces and warnings
    quad_surfaces_regular = [quad_surfaces_regular; quad_surfaces];
    warnings = [warnings; warn(:)];
end

plottitle = strcat('Verification Plot for Regular Region');
plotfilename = strcat('../Results/Figures/plot_stringer_regular_surfaces_v3_generate_structure_v6_ala12_TFG_Amora_aviones_a350_1000_datos_estructual');
% plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular,plottitle, plotfilename);

% quad_surfaces_regular_3D = preprocess_3D_quads(quad_surfaces_regular);
% quad_surfaces_regular_3D_processed = process_quads(combined_nodes_3D_processed,[quad_surfaces_regular_3D]);
% write_bdf_quads_v1(fullfile(folder_parts,"\test_regular.bdf"), quad_surfaces_regular_3D_processed, [], pshell_info, material_info);
% disp('until here')
%% 🛡️ Loop Through Stringers in the Irregular Zones
% Loop through stringers in the stinger irregular zones
quad_irregular_wing = quad_initialize();
quad_rectangular_regular = quad_initialize();
tri_surfaces = [];
penta_surfaces = [];

for stringer_index = num_stringers_last_rib:max_stringer_index - 1

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
    if any(next_rib_indices == -100) % Updated root rib index
        % Remove -100 temporarily to find the second-to-last rib
        valid_ribs = next_rib_indices(next_rib_indices ~= -100);

        if ~isempty(valid_ribs)
            % Safely select the maximum valid rib
            second_to_last_rib = max(valid_ribs);
        else
            % Fallback if no valid ribs exist
            warning('No valid ribs found besides -100. Using fallback rib index.');
            second_to_last_rib = -99; % Updated default to front spar rib
        end
    else
        % If -100 does not exist, use the maximum rib
        second_to_last_rib = max(next_rib_indices);
    end

    % Define end_rib dynamically
    end_rib = second_to_last_rib;

    %% ✅ Process Up to the Second-to-Last Rib (Regular-like Behavior)
    [quad_regular_stringer, warn] = create_surfaces_for_stringer_regular_v3( ...
        combined_nodes, stringer_index, end_rib);

    % Append the results
    quad_rectangular_regular = [quad_rectangular_regular; quad_regular_stringer];
    warnings = [warnings; warn(:)];

    %% 🔄 Updating the next_stringer_nodes with Front Spar Nodes
    % Extract nodes for the next stringer
    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1, :);

    % Extract front spar nodes from combined_nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    % Find the last rib index in the next stringer
    if ~isempty(next_stringer_nodes)
        last_rib_index = max(next_stringer_nodes.rib_index); % Maximum rib index of the next stringer
    else
        last_rib_index = -Inf; % Placeholder if next_stringer_nodes is empty
    end

    % Select front spar nodes corresponding to ribs >= the last rib index
    additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);

    % Combine the original next stringer nodes and the front spar nodes
    next_stringer_nodes = [next_stringer_nodes; additional_nodes];

    % Debug: Check the updated next_stringer_nodes
    if isempty(next_stringer_nodes)
        warning('Next stringer nodes are empty after including front spar nodes.');
    end
    start_rib_irregular = end_rib;
    %% ✅ Process Up to the Second-to-Last Rib (Regular-like Behavior)
    [quad_irregular_wing_stringer,tri_surfaces_stringer, warn, combined_nodes] = create_surfaces_for_stringer_irregular_v7( ...
        combined_nodes, stringer_index, start_rib_irregular, ala.geometria,datosEstructural);

    % Append the results
    quad_irregular_wing = [quad_irregular_wing; quad_irregular_wing_stringer];
    tri_surfaces = [tri_surfaces; tri_surfaces_stringer];
    warnings = [warnings; warn(:)];
end

% combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H);
% [nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
% write_bdf_points_v2(fullfile(folder_parts,"\nodes.bdf"), nodes);
% 
% quad_rectangular_regular_3D = preprocess_3D_quads(quad_rectangular_regular);
% quad_rectangular_regular_3D_processed = process_quads(combined_nodes_3D_processed,[quad_rectangular_regular_3D]);
% write_bdf_quads_v1(fullfile(folder_parts,"\test_regular_irregular.bdf"), quad_rectangular_regular_3D_processed, [], pshell_info, material_info);
% % disp('until here')
% 
% quad_irregular_wing_3D = preprocess_3D_quads(quad_irregular_wing);
% quad_irregular_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quad_irregular_wing_3D]);
% write_bdf_quads_v1(fullfile(folder_parts,"\test_irregular.bdf"), quad_irregular_wing_3D_processed, [], pshell_info, material_info);
% disp('until here')
% 
% 
% % tri_all = [tri_surfaces; tri_root; tri_root_stringer];
% tri_surfaces_3D = preprocess_3D_tris(tri_surfaces);
% tri_surfaces_3D_processed = process_tri(combined_nodes_3D_processed, tri_surfaces_3D);
% write_bdf_tris_v1(fullfile(folder_parts,"\tri.bdf"), tri_surfaces_3D_processed, pshell_info, material_info);
% disp('until here')

%% Construyendo nuevas costillas
P1=combined_nodes(combined_nodes.rib_index==1 & combined_nodes.tag =='rear spars',:);
P1.y=P1.y - (distancia_entre_costillas/2/sin(ala.geometria.alfa_larguero_posterior_radianes));
point_1_x = P1.x;
point_1_y = P1.y;
point_1 = [point_1_x point_1_y];
point_2 = find_point_on_front_spar(point_1_x, point_1_y, ala,avion,datosEstructural);

% Create the first new node
new_nodes_1 = table(NaN, point_1(1), point_1(2), 0, -2, "rear spars", ...
    'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

% Create the second new node
new_nodes_2 = table(NaN, point_2(1), point_2(2), 0, -1, "front spars", ...
    'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

combined_nodes = add_nodes_to_combined_nodes_v2(combined_nodes, new_nodes_1);
combined_nodes = add_nodes_to_combined_nodes_v2(combined_nodes, new_nodes_2);
combined_nodes = add_singular_rib(combined_nodes, point_1, point_2,0,"stringer");

%% Superficies cercanas al encastre

tri_root = tri_initialize();
quad_root = quad_initialize();
penta_root = [];

% Guardar la primera superficie: stringer_index = 1, 
[tri_surfaces_stringer, warn] = create_first_surface_root(combined_nodes);
tri_root =[tri_root; tri_surfaces_stringer];
warnings = [warnings; warn(:)];



for index_larguerillo = 1:max_stringer_index
    [tri_surfaces_stringer, quad_surfaces_stringer, warn, combined_nodes] = create_surfaces_root_v3(combined_nodes, index_larguerillo,ala.geometria, datosEstructural);
    
    tri_root = [tri_root; tri_surfaces_stringer];
    quad_root = [quad_root; quad_surfaces_stringer];
    % penta_root = [penta_root; penta_surfaces_stringer];


    warnings = [warnings; warn(:)];
end

%% Superficies en la esquina encastre-larguero anterior
% Create the master node
OnlyNode1 = table(1, Lf, c1 * Distancia_larguero_anterior_cuerda_porcentaje, 1e5, -1, "front spars", ...
    'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
combined_nodes = add_nodes_to_combined_nodes_v2(combined_nodes, OnlyNode1);


% OnlyNode1 = table(1, Lf, c1 * Distancia_larguero_anterior_cuerda_porcentaje, 1e5, 1e5, "OnlyNode", ...
%     'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});


[tri_root_stringer, quad_root_stringer, warnings] = OnlyCornerRootFront_v1(combined_nodes);
warnings = [warnings; warn(:)];

%% Crear superficies en fuselaje
quad_fuselaje = [];
start_rib = rib_ranges(1,2);
[quad_rear_root_fuselaje, warnings] = create_surfaces_rear_spar_fuselaje_v1(combined_nodes_fuselaje, combined_nodes, start_rib);
warnings = [warnings; warn(:)];

for index_larguerillo = 1:max_stringer_index-1

    [quad_surfaces_stringer, warning] = create_surfaces_stringer_fuselaje_v1(combined_nodes_fuselaje, combined_nodes, index_larguerillo);

    quad_fuselaje = [quad_fuselaje; quad_surfaces_stringer];
    warnings = [warnings; warn(:)];

end

[quad_front_root_fuselaje, warnings] = create_surfaces_front_spar_fuselaje_v1(combined_nodes_fuselaje, combined_nodes);
warnings = [warnings; warn(:)];

quad_fuselaje = [quad_rear_root_fuselaje; quad_fuselaje; quad_front_root_fuselaje];

%% Plot Fuselaje


OnlyTri = [tri_surfaces; tri_root; tri_root_stringer];

% OnlyQuads = [quad_surfaces_regular;quad_rectangular_regular;quad_irregular_wing;quad_root;quad_root_stringer];
% OnlyQuads = [quad_surfaces_regular;quad_rectangular_regular;quad_irregular_wing;quad_root];
OnlyPenta = [penta_root; penta_surfaces];
OnlyRear = [quad_rear_spar_wing];
OnlyQuads_Fuselaje = [quad_rear_root_fuselaje; quad_fuselaje; quad_front_root_fuselaje];

% All quad regular/irregular, tri, penta
plottitle = strcat('Verification OnlyPlot');
plotfilename = strcat('../Results/Figures/OnlyPlotSurface_v4_test1_generate_structure_v14_ala14_fuselaje5_a350_1000_datos_estructual');

% OnlyPlotSurface_v6(combined_nodes, combined_nodes_fuselaje, ...
%     [OnlyQuads; OnlyQuads_Fuselaje], [OnlyTri],[OnlyRear], plottitle, plotfilename,avion,datosEstructural);



% OnlyPlotFuselaje_v1(combined_nodes_fuselaje, plottitle, plotfilename,avion,datosEstructural);

%% 3D
% Thickness
% H = 1;

m = avion.perfil.airfoil.m;
p = avion.perfil.airfoil.p;
t = avion.perfil.airfoil.t;
num_points = avion.perfil.airfoil.num_points;
combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, ...
    m, p, t, num_points, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, false);

%% Saving all of the results
% 
% model_data = struct();
% model_data.Nodes = combined_nodes_3D; % Node coordinates
% model_data.Elements.Lines = [horizontal_stringers;vertical_stringers]; % Line connectivity
% lines = [horizontal_stringers;vertical_stringers];
% % model_data.Elements.Quads = Quads_matrix; % Quad connectivity
% % model_data.Elements.Triangles = Triangles_matrix; % Triangle connectivity
% % model_data.Elements.Pentas = Pentas_matrix; % Pentahedral connectivity
% % model_data.Metadata.Materials = Material_properties;
% % model_data.Metadata.BoundaryConditions = BCs;
% 
% save('output\model_data.mat', 'model_data');

%% Materiales
% Example: Material Information
material_info = struct();
material_info.material_id = 1; % Material ID (MID)
material_info.E = 69000;      % Young's modulus in MPa
material_info.nu = 0.33;      % Poisson's ratio
material_info.rho = 2.7e-9;   % Density in tonne/mm³ (optional)

% Example: Property Information
property_info = struct();
property_info.property_id = 1;   % Property ID (PID)
property_info.material_id = 1;   % Associated Material ID (MID)
property_info.A = 0.01;          % Cross-sectional area in m²

% Sample pshell
pshell_info = struct( ...
    'property_id', 1, ...      % PSHELL ID (PID) in the .bdf file
    'material_id', 1, ...      % Associated Material ID (MID)
    'thickness', 2.1, ...      % Shell thickness (in mm or meters, depending on the model)
    'bending_id', 1, ...       % Bending stiffness (usually same as MID)
    't_shear', 1.0, ...        % Transverse shear thickness factor (T)
    'material_mid2', 0, ...    % Second material for composite layups (if applicable)
    'tension_mid3', 0, ...     % Tension-only material (usually not used)
    'material_mid4', 0);       % Fourth material property (for advanced applications)



%% Vertical surfaces in the spar

% Creación de los largueros
[quad_rear, warnings_i] = create_surfaces_vertical_rear_spar_wing_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_front, warnings_i] = create_surfaces_vertical_front_spar_wing_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_rear_fuselaje, warnings_i] = create_surfaces_vertical_rear_spar_fuselaje_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_front_fuselaje, warnings_i] = create_surfaces_vertical_front_spar_fuselaje_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];


quad_spars = [quad_rear; quad_front; quad_rear_fuselaje; quad_front_fuselaje];

%% Creación de ribs
[quad_ribs, warnings_i] = create_surfaces_vertical_ribs_wing_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_ribs_fuselaje, warnings_i] = create_surfaces_vertical_ribs_fuselaje_v1(combined_nodes_3D);
warnings = [warnings; warnings_i];


[quad_surfaces_vertical_rib_ala, quad_surfaces_vertical_rib_fuselaje, warnings_i] = create_surfaces_ribs_vertical(combined_nodes_3D);
quad_surfaces_vertical_rib = [quad_surfaces_vertical_rib_ala; quad_surfaces_vertical_rib_fuselaje];
warnings = [warnings; warnings_i];

%% Creación de líneas para barras (cRod)
% [horizontal_stringers,vertical_stringers] = create_stringers(combined_nodes_3D);
% [horizontal_stringers,vertical_stringers] = create_stringers_v4(combined_nodes_3D);


[horizontal_stringers, vertical_stringers, line_spars] = create_stringers_v6(combined_nodes_3D);
lines = [horizontal_stringers; vertical_stringers; line_spars];



%% Organizando los elementos
% OnlyQuad = []


%% Preparar .bdf
% 
% Nodes
% combined_nodes_3D = model_data.Nodes;
% combined_nodes_3D = sort_combined_nodes(combined_nodes_3D);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
% combined_nodes_3D_processed = combined_nodes_3D_processed(~(combined_nodes_3D_processed.tag == "stringer fuselaje" & ...
%                                                             combined_nodes_3D_processed.rib_index == 9), :);
write_bdf_points_v2(fullfile(avion.folder.data,"\nodes.bdf"), nodes);

% %% Lines
% % lines
% % lines = model_data.Elements.Lines;
% % [longest_lines, stats, top_10_longest] = analyze_line_lengths_v2(lines_table, threshold_factor)
% 
lines_updated = process_lines_v8(combined_nodes_3D_processed, lines);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines.bdf"), lines_updated, material_info, property_info);

%% Quad 

quads_all = [quad_rear_spar_wing; quad_irregular_wing; quad_surfaces_regular; quad_rectangular_regular; OnlyQuads_Fuselaje; quad_root; quad_root_stringer; quad_spars];
quads_all_3D = preprocess_3D_quads(quads_all);
quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_all_3D; quad_surfaces_vertical_rib]);
write_bdf_quads_v1(fullfile(avion.folder.data,"\quads.bdf"), quads_all_3D_processed, [], pshell_info, material_info);


%% Tri

tri_all = [tri_surfaces; tri_root; tri_root_stringer];
tri_all_3D = preprocess_3D_tris(tri_all);
tri_all_3D_processed = process_tri(combined_nodes_3D_processed, tri_all_3D);
write_bdf_tris_v1(fullfile(avion.folder.data,"\tri.bdf"), tri_all_3D_processed, pshell_info, material_info);

%% Post proceso de los nodos
% 
% size(quads_all_3D_processed)
% size(tri_all_3D_processed)
% size(lines_updated)
% nodes_processed = remove_unused_nodes(combined_nodes_3D_processed, quads_all_3D_processed, tri_all_3D_processed, lines_updated)
% [nodes,combined_nodes_3D_processed] = process_nodes(nodes_processed);
% write_bdf_points_v3('..\Results\Nastran\nodes_processed.bdf', nodes);

%% BC / condición de contorno

% root_nodes = filter_root_nodes_v2(combined_nodes_3D_processed, Lf, rib_ranges);
root_nodes = filter_root_nodes_v3(combined_nodes_3D_processed, rib_ranges);
root_front_spar_intrados = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'front spars' & combined_nodes_3D_processed.rib_index == 1e5 & combined_nodes_3D_processed.h == 'intrados',:);
root_rear_spar_intrados = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars' & combined_nodes_3D_processed.rib_index == rib_ranges(1,2) & combined_nodes_3D_processed.h == 'intrados',:);
% filtered_root_nodes = remove_spar_intrados(root_nodes, root_front_spar_intrados, root_rear_spar_intrados);

rib_fuselage_nodes_stringer = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'stringer fuselaje' & combined_nodes_3D_processed.rib_index == 1,:);
rib_fuselage_nodes_rear = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars fuselaje' & combined_nodes_3D_processed.rib_index == 1,:);
rib_fuselage_nodes_front = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'front spars fuselaje' & combined_nodes_3D_processed.rib_index == 1,:);
rib_fuselage_nodes = [rib_fuselage_nodes_stringer; rib_fuselage_nodes_rear; rib_fuselage_nodes_front];

generate_boundary_conditions_bdf(fullfile(avion.folder.data,"\BC.bdf"), root_nodes, root_front_spar_intrados, root_rear_spar_intrados, rib_fuselage_nodes);

%% Forces
L_total = avion.MTOW;
rear_spar_extrados= combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars' & combined_nodes_3D_processed.rib_index >= rib_ranges(1,2),:);
front_spar_extrados = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'front spars',:);

forces_front = generate_schrenk_forces_v4(front_spar_extrados, b, L_total);
forces_rear = generate_schrenk_forces_v4(rear_spar_extrados, b, L_total);

export_forces_to_csv(fullfile(avion.folder.data,"\forces.csv"), [forces_front;forces_rear] );

% generate_forces_bdf_v3('..\Results\Nastran\F_v1.bdf', [forces_rear; forces_front], [rear_spar_extrados; front_spar_extrados]);
%% Quads por partes

% % Folders
% % Check if the folder exists
% folder_method = fullfile(avion.folder.data,"\methodtest");
folder_parts = fullfile(avion.folder.data,"\parts");
% 
% if ~exist(folder_method, 'dir')
%     mkdir(folder_method); % Create the folder if it does not exist
%     fprintf('Folder "%s" created successfully.\n', folder_method);
% end
if ~exist(folder_parts, 'dir')
    mkdir(folder_parts); % Create the folder if it does not exist
    fprintf('Folder "%s" created successfully.\n', folder_parts);
end

quad_rear_spar_wing_3D = preprocess_3D_quads(quad_rear_spar_wing);
quad_rear_spar_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quad_rear_spar_wing_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\rear_spar_wing_horizontal.bdf"), quad_rear_spar_wing_3D_processed, [], pshell_info, material_info);


quad_irregular_wing_3D = preprocess_3D_quads(quad_irregular_wing);
quad_irregular_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quad_irregular_wing_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_irregular_wing_wing_horizontal.bdf"), quad_irregular_wing_3D_processed, [], pshell_info, material_info);

quads_regular_wing = [quad_surfaces_regular; quad_rectangular_regular];
quads_regular_wing_3D = preprocess_3D_quads(quads_regular_wing);
quads_regular_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quads_regular_wing_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_regular_wing_horizontal.bdf"), quads_regular_wing_3D_processed, [], pshell_info, material_info);

OnlyQuads_Fuselaje_3D = preprocess_3D_quads(OnlyQuads_Fuselaje);
OnlyQuads_Fuselaje_3D_processed = process_quads(combined_nodes_3D_processed,[OnlyQuads_Fuselaje_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_fuselaje_horizontal.bdf"), OnlyQuads_Fuselaje_3D_processed, [], pshell_info, material_info);

quad_root_3D = preprocess_3D_quads(quad_root);
quad_root_3D_processed = process_quads(combined_nodes_3D_processed,[quad_root_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_root_wing_horizontal.bdf"), quad_root_3D_processed, [], pshell_info, material_info);

quad_root_stringer_3D = preprocess_3D_quads(quad_root_stringer);
quad_root_stringer_3D_processed = process_quads(combined_nodes_3D_processed,[quad_root_stringer_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_root_stringer_wing_horizontal.bdf"), quad_root_stringer_3D_processed, [], pshell_info, material_info);

quad_spars_3D = preprocess_3D_quads(quad_spars);
quad_spars_3D_processed = process_quads(combined_nodes_3D_processed,[quad_spars_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_spars_vertical.bdf"), quad_spars_3D_processed, [], pshell_info, material_info);

% tri OnlyTri = [tri_surfaces; tri_root; tri_root_stringer];




% tri_all = [tri_surfaces; tri_root; tri_root_stringer];
tri_surfaces_3D = preprocess_3D_tris(tri_surfaces);
tri_surfaces_3D_processed = process_tri(combined_nodes_3D_processed, tri_surfaces_3D);
write_bdf_tris_v1(fullfile(folder_parts,"\tri_surfaces.bdf"), tri_surfaces_3D_processed, pshell_info, material_info);

tri_root_3D = preprocess_3D_tris(tri_root);
tri_root_3D_processed = process_tri(combined_nodes_3D_processed, tri_root_3D);
write_bdf_tris_v1(fullfile(folder_parts,"\tri_root.bdf"), tri_root_3D_processed, pshell_info, material_info);

tri_root_stringer_3D = preprocess_3D_tris(tri_root_stringer);
tri_root_stringer_3D_processed = process_tri(combined_nodes_3D_processed, tri_root_stringer_3D);
write_bdf_tris_v1(fullfile(folder_parts,"\tri_root_stringer.bdf"), tri_root_stringer_3D_processed, pshell_info, material_info);

%% Guardando los resultados
results.quad.quad_surfaces_vertical_rib_ala = quad_surfaces_vertical_rib_ala;
results.quad.quad_surfaces_vertical_rib_fuselaje = quad_surfaces_vertical_rib_fuselaje;
results.quad.quad_rear_root_fuselaje = quad_rear_root_fuselaje;
results.quad.quad_fuselaje = quad_fuselaje;
results.quad.quad_front_root_fuselaje = quad_front_root_fuselaje;
results.quad.quad_rear = quad_rear;
results.quad_front = quad_front;
results.quad.quad_rear_fuselaje = quad_rear_fuselaje;
results.quad.quad_front_fuselaje = quad_front_fuselaje;
results.quad.quad_surfaces_vertical_rib_ala = quad_surfaces_vertical_rib_ala;
results.quad.quad_rear_spar_wing = quad_rear_spar_wing;
results.quad.quad_irregular_wing = quad_irregular_wing;
results.quad.quads_regular_wing = quads_regular_wing;
results.quad.quad_root = quad_root;
results.quad.quad_root_stringer = quad_root_stringer;

results.nodes = combined_nodes;

results.tri.tri_surfaces = tri_surfaces;
results.tri.tri_root = tri_root;
results.tri.tri_root_stringer = tri_root_stringer;
% end