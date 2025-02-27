function generate_structure(avion,datosEstructural,cargas,ala,fuselaje)

% Geometría
Lf = avion.geometria.Lf;
c1 = avion.geometria.c1;
% b = avion.geometria.b;
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
[num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data(combined_nodes);


%% 📐 Create Horizontal Stiffening Panels (Rear Spar Surfaces)
% Purpose: Create stiffening surfaces adjacent to the rear spar within a specific rib range.

% Define rib range
start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(1) + 1;
end_rib = index_larguerillos_anterior_ala(1) - 1;

% Handle Rear Spar Surfaces
quad_rear_spar_wing = create_rear_spar_surfaces(...
    combined_nodes, start_rib, end_rib);

%% 📐 Create Horizontal Stiffening Panels (stringers surfaces)
% 📊 Stringer Surface Region Division: Regular and Irregular Parts

% Define rib indices for stringer surface regions:
% Regular Region: Stringers end at the last rib.
% Irregular Region: Stringers end at the front spar with non-standard geometry.

quad_surfaces_regular_wing = quad_initialize();
warnings = {};

% Loop through stringers in the regular zones
for stringer_index = 1:num_stringers_last_rib - 1
    % Define rib range from wing geometry
    start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(stringer_index) + 1;
    end_rib = max_rib;

    % Call the function to create surfaces
    [quad_surfaces, warnings_i] = create_surfaces_for_stringer_regular(...
        combined_nodes, stringer_index, start_rib, end_rib);

    % Append the created surfaces and warnings
    quad_surfaces_regular_wing = [quad_surfaces_regular_wing; quad_surfaces];
    warnings = [warnings; warnings_i(:)];
end

%% 🛡️ Loop Through Stringers in the Irregular Zones
quad_irregular_wing = quad_initialize();
quad_surfaces_regular_wing = quad_initialize();
tri_surfaces = tri_initialize(); % Use a standardized initialization for triangles
warnings = {}; % Initialize warnings array

for stringer_index = num_stringers_last_rib:max_stringer - 1

    % ✅ Determine the Start and End Rib Dynamically
    start_rib = index_counter_quitar_nodos_larguerillos_menor_Lf(stringer_index) + 1;
    end_rib = determine_end_rib(combined_nodes, stringer_index); % New helper function

    % ✅ Process Regular-Like Surfaces (Up to Second-to-Last Rib)
    [quad_regular_stringer, warnings_i] = create_surfaces_for_stringer_regular( ...
        combined_nodes, stringer_index, start_rib, end_rib);
    
    quad_surfaces_regular_wing = [quad_surfaces_regular_wing; quad_regular_stringer];
    warnings = [warnings; warnings_i(:)];

    % ✅ Update Next Stringer Nodes with Front Spar Nodes
    next_stringer_nodes = update_next_stringer_with_front_spar(combined_nodes, stringer_index);

    % ✅ Process Irregular Stringer Surfaces
    [quad_irregular_stringer, tri_surfaces_stringer, warnings_i, combined_nodes] = ...
        create_surfaces_for_stringer_irregular(combined_nodes, stringer_index, end_rib, ala.geometria, datosEstructural);
    
    quad_irregular_wing = [quad_irregular_wing; quad_irregular_stringer];
    tri_surfaces = [tri_surfaces; tri_surfaces_stringer];
    warnings = [warnings; warnings_i(:)];
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

combined_nodes = add_nodes_to_combined_nodes(combined_nodes, new_nodes_1);
combined_nodes = add_nodes_to_combined_nodes(combined_nodes, new_nodes_2);
combined_nodes = add_singular_rib(combined_nodes, point_1, point_2,0,"stringer");

%% Superficies cercanas al encastre

tri_root = [];
quad_root_wing = quad_initialize();


% Guardar la primera superficie: stringer_index = 1, 
[tri_surfaces_stringer, warnings_i] = create_first_surface_root(combined_nodes);
tri_root =[tri_root; tri_surfaces_stringer];
warnings = [warnings; warnings_i(:)];

for index_larguerillo = 1:max_stringer
    [tri_surfaces_stringer, quad_surfaces_stringer, warnings_i, combined_nodes] = create_surfaces_root(combined_nodes, index_larguerillo,ala.geometria, datosEstructural);
    tri_root = [tri_root; tri_surfaces_stringer];
    quad_root_wing = [quad_root_wing; quad_surfaces_stringer];
    warnings = [warnings; warnings_i(:)];
end

%% Superficies en la esquina encastre-larguero anterior
% Create the master node
OnlyNode1 = table(1, Lf, c1 * Distancia_larguero_anterior_cuerda_porcentaje, 1e5, -1, "front spars", ...
    'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
combined_nodes = add_nodes_to_combined_nodes(combined_nodes, OnlyNode1);


% OnlyNode1 = table(1, Lf, c1 * Distancia_larguero_anterior_cuerda_porcentaje, 1e5, 1e5, "OnlyNode", ...
%     'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});


[tri_root_stringer, quad_root_stringer_wing, warnings_i] = OnlyCornerRootFront(combined_nodes);
warnings = [warnings; warnings_i(:)];

%% Crear superficies en fuselaje
quad_fuselaje = quad_initialize();
start_rib = rib_ranges(1,2);
[quad_rear_root_fuselaje, warnings_i] = create_surfaces_rear_spar_fuselaje(combined_nodes_fuselaje, combined_nodes, start_rib);
warnings = [warnings; warnings_i(:)];

for index_larguerillo = 1:max_stringer-1

    [quad_surfaces_stringer, warning] = create_surfaces_stringer_fuselaje(combined_nodes_fuselaje, combined_nodes, index_larguerillo);

    quad_fuselaje = [quad_fuselaje; quad_surfaces_stringer];
    warnings = [warnings; warnings_i(:)];

end

[quad_front_root_fuselaje, warnings] = create_surfaces_front_spar_fuselaje(combined_nodes_fuselaje, combined_nodes);
warnings = [warnings; warnings_i(:)];


%% 3D
% Thickness
H = 1;
combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H);

%% Vertical surfaces in the spar

% Creación de los largueros
[quad_rear, warnings_i] = create_surfaces_vertical_rear_spar_wing(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_front, warnings_i] = create_surfaces_vertical_front_spar_wing(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_rear_fuselaje, warnings_i] = create_surfaces_vertical_rear_spar_fuselaje(combined_nodes_3D);
warnings = [warnings; warnings_i];

[quad_front_fuselaje, warnings_i] = create_surfaces_vertical_front_spar_fuselaje(combined_nodes_3D);
warnings = [warnings; warnings_i];

%% Creación de ribs

% Estas dos funciones create_surfaces_vertical_ribs_wing y
% create_surfaces_vertical_ribs_fuselaje son las funciones en donde se
% crean una superficie sola en una costilla sin barra vertical.
[quad_ribs, warnings_i] = create_surfaces_vertical_ribs_wing(combined_nodes_3D);
warnings = [warnings; warnings_i];
[quad_ribs_fuselaje, warnings_i] = create_surfaces_vertical_ribs_fuselaje(combined_nodes_3D);
warnings = [warnings; warnings_i];


[quad_surfaces_vertical_rib_ala, quad_surfaces_vertical_rib_fuselaje, warnings_i] = create_surfaces_ribs_vertical(combined_nodes_3D);

warnings = [warnings; warnings_i];

%% Creación de líneas para barras (cRod)
[horizontal_stringers, vertical_stringers, line_spars] = create_stringers(combined_nodes_3D);
lines = [horizontal_stringers; vertical_stringers; line_spars];



%% Preparar .bdf
[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
% combined_nodes_3D_processed = combined_nodes_3D_processed(~(combined_nodes_3D_processed.tag == "stringer fuselaje" & ...
%                                                             combined_nodes_3D_processed.rib_index == 9), :);
write_bdf_points(fullfile(avion.folder.data,"\nodes.bdf"), nodes);

%% Lines
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
% [longest_lines, stats, top_10_longest] = analyze_line_lengths_v2(lines_table, threshold_factor)

lines_updated = process_lines(combined_nodes_3D_processed, lines);
write_bdf_lines(fullfile(avion.folder.data,"\lines.bdf"), lines_updated, material_info, property_info);

%% Quad 
% quad_surfaces_vertical_rib = [quad_surfaces_vertical_rib_ala; quad_surfaces_vertical_rib_fuselaje];
% quad_fuselaje = [quad_rear_root_fuselaje; quad_fuselaje; quad_front_root_fuselaje];
% quad_spars_all = [quad_rear; quad_front; quad_rear_fuselaje; quad_front_fuselaje];
% quads_wing = [quad_rear_spar_wing; quad_irregular_wing; quad_surfaces_regular_wing; quad_root_wing; quad_root_stringer_wing];
% quads_all = [quads_wing, quad_fuselaje, quad_spars_all, quad_surfaces_vertical_rib];
% 
% quads_all_3D = preprocess_3D_quads(quads_all);
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_all_3D; quad_surfaces_vertical_rib]);
% write_bdf_quads(fullfile(avion.folder.data,"\quad.bdf"), quads_all_3D_processed, [], pshell_info, material_info);

quad_surfaces_vertical_rib = [quad_surfaces_vertical_rib_ala; quad_surfaces_vertical_rib_fuselaje]; % Está bien
quad_fuselaje = [quad_rear_root_fuselaje; quad_fuselaje; quad_front_root_fuselaje];% Está bien
quad_spars_all = [quad_rear; quad_front; quad_rear_fuselaje; quad_front_fuselaje];
quads_wing = [quad_rear_spar_wing; quad_irregular_wing; quad_surfaces_regular_wing; quad_root_wing; quad_root_stringer_wing];
quads_horizontal =[quads_wing; quad_fuselaje; quad_spars_all];

assignin('base', 'quad_surfaces_vertical_rib', quad_surfaces_vertical_rib);
assignin('base', 'quad_fuselaje', quad_fuselaje);
assignin('base', 'quad_spars_all', quad_spars_all);
assignin('base', 'quad_rear', quad_rear);
assignin('base', 'quad_front', quad_front);
assignin('base', 'quad_rear_fuselaje', quad_rear_fuselaje);
assignin('base', 'quad_front_fuselaje', quad_front_fuselaje);
assignin('base', 'quads_wing', quads_wing);
assignin('base', 'quad_rear_spar_wing', quad_rear_spar_wing);
assignin('base', 'quad_irregular_wing', quad_irregular_wing);
assignin('base', 'quad_surfaces_regular_wing', quad_surfaces_regular_wing);
assignin('base', 'quad_root_wing', quad_root_wing);
assignin('base', 'quad_root_stringer_wing', quad_root_stringer_wing);
assignin('base', 'combined_nodes_3D_processed', combined_nodes_3D_processed);
assignin('base', 'combined_nodes_3D', combined_nodes_3D);
size(quad_surfaces_vertical_rib)
size(quad_fuselaje)
size(quad_spars_all)
size(quad_fuselaje)
size(quads_wing)
size(quad_rear)
size(quad_front)
size(quad_rear_fuselaje)
size(quad_front_fuselaje)
size(quad_rear_spar_wing);
size( quad_irregular_wing);
size( quad_surfaces_regular_wing);
size( quad_root_wing);
size( quad_root_stringer_wing);
unique(quad_rear.tag)
unique(quad_front.tag)
% 
% quads_all_3D = preprocess_3D_quads([quads_wing; quad_fuselaje; quad_spars_all]);
% quads_test = preprocess_3D_quads(quad_rear_root_fuselaje);
% quads_test1 = preprocess_3D_quads(quad_fuselaje);
% quads_test2 = preprocess_3D_quads(quad_front_root_fuselaje);
% quads_test3 = preprocess_3D_quads(quad_rear);
% quads_test_quad_rear_test = preprocess_3D_quads(quad_rear_test);
% quads_test4 = preprocess_3D_quads(quad_front);
% quads_test5 = preprocess_3D_quads(quad_rear_fuselaje);% Está bien
% quads_test6 = preprocess_3D_quads(quad_front_fuselaje);% Está bien
% quads_test7 = preprocess_3D_quads(quad_rear_spar_wing);
% quads_test8 = preprocess_3D_quads(quad_irregular_wing);
% quads_test9 = preprocess_3D_quads(quad_surfaces_regular_wing);
% quads_test10 = preprocess_3D_quads(quad_root_wing);
% quads_test11 = preprocess_3D_quads(quad_fuselaje);
% quads_test12 = preprocess_3D_quads(quad_spars_all);
% 
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_test_quad_rear_test]);
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quad_spars_all]);
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_test3]);
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_test4]);
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_test5]);% Está bien
% quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_test6]);% Está bien

% quad_all = [quads_wing; quad_fuselaje; quad_spars_all];
quads_all_3D = preprocess_3D_quads(quads_horizontal);
quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quads_all_3D; quad_surfaces_vertical_rib] );
write_bdf_quads(fullfile(avion.folder.data,"\quad.bdf"), quads_all_3D_processed, [], pshell_info, material_info);

%% Tri

tri_all = [tri_surfaces; tri_root; tri_root_stringer];
tri_all_3D = preprocess_3D_tris(tri_all);
tri_all_3D_processed = process_tri(combined_nodes_3D_processed, tri_all_3D);
write_bdf_tris(fullfile(avion.folder.data,"\tri.bdf"), tri_all_3D_processed, pshell_info, material_info);

%% BC / condición de contorno

% root_nodes = filter_root_nodes_v2(combined_nodes_3D_processed, Lf, rib_ranges);
root_nodes = filter_root_nodes(combined_nodes_3D_processed, rib_ranges);
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

end