% %% 🔹 Step 1: Load Database
% database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
% data_path = fullfile(database_computer, "Data");
% load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
% name = "Airbus_A380_Structural_parameters_A350";
% avion = TFG_Amora.aviones.(name);



function results = generate_structure(avion)
% close all
    
H = 1;
% generar_estructura_v1(avion,datosEstructural,ala,fuselaje,H)


% Geometría
datosEstructural = avion.datosEstructural;
ala = avion.ala;
fuselaje = avion.fuselaje;

Lf = avion.geometria.Lf;
c1 = avion.geometria.c1;
b = avion.geometria.b;
Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
index_counter_quitar_nodos_larguerillos_menor_Lf = ala.mesh.index_counter_quitar_nodos_larguerillos_menor_Lf; 
index_larguerillos_anterior_ala = ala.mesh.index_larguerillos_anterior; % Número de intersección que hace el larguerillo con la costillas y su punto medio (Punto medio entre costillas).
distancia_entre_costillas = datosEstructural.distancia_entre_costillas;

%% Mesh 
combined_nodes = ala.mesh.combined_nodes;   
combined_nodes_fuselaje = fuselaje.mesh.combined_nodes;

%% PARAMETROS NUEVOS
threshold_distance = distancia_entre_costillas * 0.07;

% Call the function
[num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data_v5(combined_nodes);

quad_rear_spar_wing = []; % Rear Spar Horizontal Panels


%% 📐 Create Horizontal Stiffening Panels (Rear Spar Surfaces)
% Purpose: Create stiffening surfaces adjacent to the rear spar within a specific rib range.

% Define rib range
start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(1) + 1;
end_rib = index_larguerillos_anterior_ala(1) - 1;

% Handle Rear Spar Surfaces
quad_rear_spar_wing = create_rear_spar_surfaces_v4(...
    combined_nodes, start_rib, end_rib);

% Optional: Plot verification
plottitle = 'Verification Plot for rear spar surface Region';
plotfilename = '../Results/Figures/plot_rear_spar_surfaces_generate_structure_v6_rear_spar_ala12_TFG';
% plot_rear_spar_surfaces(combined_nodes, quad_rear_spar_wing, plottitle, plotfilename);


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
for stringer_index = 1:num_stringers_last_rib - 1
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
plotfilename = strcat('../Results/Figures/plot_stringer_regular_surfaces_v3_generate_structure_v6_ala12_TFG_Amora_aviones_a350_1000_datos_estructual');
% plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular,plottitle, plotfilename);

%% 🛡️ Loop Through Stringers in the Irregular Zones
% Loop through stringers in the stinger irregular zones
quad_irregular_wing = [];
quad_rectangular_regular=[];
tri_surfaces = [];
penta_surfaces = [];

for stringer_index = num_stringers_last_rib:max_stringer - 1

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
        combined_nodes, stringer_index, start_rib, end_rib, threshold_distance);

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
    % end_rib
    %% ✅ Process Up to the Second-to-Last Rib (Regular-like Behavior)
    [quad_irregular_wing_stringer,tri_surfaces_stringer, warn, combined_nodes] = create_surfaces_for_stringer_irregular_v7( ...
        combined_nodes, stringer_index, end_rib, ala.geometria,datosEstructural);

    % Append the results
    quad_irregular_wing = [quad_irregular_wing; quad_irregular_wing_stringer];
    tri_surfaces = [tri_surfaces; tri_surfaces_stringer];
    % penta_surfaces = [penta_surfaces; penta_surfaces_stringer];
    warnings = [warnings; warn(:)];
end

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

tri_root = [];
quad_root = [];
penta_root = [];

% Guardar la primera superficie: stringer_index = 1, 
[tri_surfaces_stringer, warn] = create_first_surface_root(combined_nodes);
tri_root =[tri_root; tri_surfaces_stringer];
warnings = [warnings; warn(:)];



for index_larguerillo = 1:max_stringer
    [tri_surfaces_stringer, quad_surfaces_stringer, warn, combined_nodes] = create_surfaces_root_v4(combined_nodes, index_larguerillo,ala.geometria, datosEstructural);
    
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

for index_larguerillo = 1:max_stringer-1

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
OnlyQuads = [quad_surfaces_regular;quad_rectangular_regular;quad_irregular_wing;quad_root];
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
H = 1;
combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H);

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


%% Trinagulo test test


%  quad_irregular_wing tri_surfaces

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
% Check if the folder exists

folder_method = fullfile(avion.folder.data,"\method2")
if ~exist(folder_method, 'dir')
    mkdir(folder_method); % Create the folder if it does not exist
    fprintf('Folder "%s" created successfully.\n', folder_method);
else
    fprintf('Folder "%s" already exists.\n', folder_parts);
end
folder_parts = fullfile(folder_method,"\parts");
if ~exist(folder_parts, 'dir')
    mkdir(folder_parts); % Create the folder if it does not exist
    fprintf('Folder "%s" created successfully.\n', folder_parts);
else
    fprintf('Folder "%s" already exists.\n', folder_parts);
end

%% Preparar .bdf
% 
% Nodes
% combined_nodes_3D = model_data.Nodes;
% combined_nodes_3D = sort_combined_nodes(combined_nodes_3D);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
% combined_nodes_3D_processed = combined_nodes_3D_processed(~(combined_nodes_3D_processed.tag == "stringer fuselaje" & ...
%                                                             combined_nodes_3D_processed.rib_index == 9), :);
write_bdf_points_v2(fullfile(folder_method,"\nodes.bdf"), nodes);

% %% Lines
% % lines
% % lines = model_data.Elements.Lines;
% % [longest_lines, stats, top_10_longest] = analyze_line_lengths_v2(lines_table, threshold_factor)
% 
lines_updated = process_lines_v8(combined_nodes_3D_processed, lines);
write_bdf_lines_v3(fullfile(folder_method,"\lines.bdf"), lines_updated, material_info, property_info);

%% Quad 

quads_all = [quad_rear_spar_wing; quad_irregular_wing; quad_surfaces_regular; quad_rectangular_regular; OnlyQuads_Fuselaje; quad_root; quad_root_stringer; quad_spars];
quads_all_3D = preprocess_3D_quads(quads_all);
quads_all_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quads_all_3D; quad_surfaces_vertical_rib]);
write_bdf_quads_v1(fullfile(folder_method,"\quads.bdf"), quads_all_3D_processed, [], pshell_info, material_info);


%% Tri

tri_all = [tri_surfaces; tri_root; tri_root_stringer];
tri_all_3D = preprocess_3D_tris(tri_all);
tri_all_3D_processed = process_tri(combined_nodes_3D_processed, tri_all_3D);
write_bdf_tris_v1(fullfile(folder_method,"\tri.bdf"), tri_all_3D_processed, pshell_info, material_info);

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

generate_boundary_conditions_bdf(fullfile(folder_method,"\BC.bdf"), root_nodes, root_front_spar_intrados, root_rear_spar_intrados, rib_fuselage_nodes);

%% Forces
L_total = avion.MTOW;
rear_spar_extrados= combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars' & combined_nodes_3D_processed.rib_index >= rib_ranges(1,2),:);
front_spar_extrados = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'front spars',:);

forces_front = generate_schrenk_forces_v4(front_spar_extrados, b, L_total);
forces_rear = generate_schrenk_forces_v4(rear_spar_extrados, b, L_total);

export_forces_to_csv(fullfile(folder_method,"\forces.csv"), [forces_front;forces_rear] );

% generate_forces_bdf_v3('..\Results\Nastran\F_v1.bdf', [forces_rear; forces_front], [rear_spar_extrados; front_spar_extrados]);
%% Quads por partes




quad_rear_spar_wing_3D = preprocess_3D_quads(quad_rear_spar_wing);
quad_rear_spar_wing_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_rear_spar_wing_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\rear_spar_wing_horizontal.bdf"), quad_rear_spar_wing_3D_processed, [], pshell_info, material_info);


quad_irregular_wing_3D = preprocess_3D_quads(quad_irregular_wing);
quad_irregular_wing_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_irregular_wing_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_irregular_wing_wing_horizontal.bdf"), quad_irregular_wing_3D_processed, [], pshell_info, material_info);

quad_surfaces_regular_3D = preprocess_3D_quads(quad_surfaces_regular);
quad_surfaces_regular_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_surfaces_regular_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_regular_wing_first_part_horizontal.bdf"), quad_surfaces_regular_3D_processed, [], pshell_info, material_info);

quad_rectangular_regular_3D = preprocess_3D_quads(quad_rectangular_regular);
quad_rectangular_regular_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_rectangular_regular_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_regular_wing_second_part_horizontal.bdf"), quad_rectangular_regular_3D_processed, [], pshell_info, material_info);

OnlyQuads_Fuselaje_3D = preprocess_3D_quads(OnlyQuads_Fuselaje);
OnlyQuads_Fuselaje_3D_processed = process_quads_v1(combined_nodes_3D_processed,[OnlyQuads_Fuselaje_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_fuselaje_horizontal.bdf"), OnlyQuads_Fuselaje_3D_processed, [], pshell_info, material_info);

quad_root_3D = preprocess_3D_quads(quad_root);
quad_root_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_root_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_root_wing_horizontal.bdf"), quad_root_3D_processed, [], pshell_info, material_info);

quad_root_stringer_3D = preprocess_3D_quads(quad_root_stringer);
quad_root_stringer_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_root_stringer_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_root_stringer_wing_horizontal.bdf"), quad_root_stringer_3D_processed, [], pshell_info, material_info);

quad_spars_3D = preprocess_3D_quads(quad_spars);
quad_spars_3D_processed = process_quads_v1(combined_nodes_3D_processed,[quad_spars_3D]);
write_bdf_quads_v1(fullfile(folder_parts,"\quad_spars_vertical.bdf"), quad_spars_3D_processed, [], pshell_info, material_info);

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
results.quad.quad_surfaces_regular = quad_surfaces_regular;
results.quad.quad_rectangular_regular = quad_rectangular_regular;
results.quad.quad_root = quad_root;
results.quad.quad_root_stringer = quad_root_stringer;

results.nodes = combined_nodes;

results.tri.tri_surfaces = tri_surfaces;
results.tri.tri_root = tri_root;
results.tri.tri_root_stringer = tri_root_stringer;
end