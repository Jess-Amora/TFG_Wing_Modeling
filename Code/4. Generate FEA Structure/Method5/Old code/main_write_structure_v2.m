%% 🔹 Step 1: Load Database
addpath('./4. Generate FEA Structure');
addpath('./4. Generate FEA Structure/Method5');
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
name = "Airbus_A380_Structural_parameters_A350";
avion = TFG_Amora.aviones.(name);
name_predim = "test_2_27";
predim = avion.predimensionado.(name_predim);
name_larguerillo = predim.larguerillo;
name_cordon = predim.cordon;
name_cajon = predim.cajon;
larguerillo_parts = TFG_Amora.parts.larguerillo.(name_larguerillo);
cordon_parts = TFG_Amora.parts.cordon.(name_cordon);
% cajon_parts = TFG_Amora.parts.larguerillo.(name_cajon);


% function main_write_structure(avion,predimData)


ala = avion.ala;
% predim = avion.predimensionado.(predimData);

Lf = avion.geometria.Lf;
Lw = avion.geometria.Lw;
c1 = avion.geometria.c1;
c2 = avion.geometria.c2;
b = avion.geometria.b;
tolerance = 1e-6;

y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;

%% Loading materials

material_data = readtable(fullfile(database_computer, 'Data','materials.csv'), 'Format', '%s%f%f%f%f%f%f%f%s');

% Crod
% Example: Property Information
property_info = struct();
property_info.property_id = 1;   % Property ID (PID)
property_info.material_id = 1;   % Associated Material ID (MID)
property_info.A = 0.01;          % Cross-sectional area in m²
property_info_cordon = property_info;
property_info_cordon.A = cordon_parts.A_cordon;
property_info_larguerillo = property_info;
property_info_larguerillo.A = larguerillo_parts.A_larguerillo;

% Extract material properties into a structured format
materials = struct();
for i = 1:height(material_data)
    mat_name = material_data.name{i}; % Material name as key
    materials.(mat_name) = struct( ...
        'E', material_data.E(i), ...
        'nu', material_data.nu(i), ...
        'rho', material_data.rho(i), ...
        'G', material_data.G(i), ...  % Shear modulus now included
        'sigma_lim', material_data.sigma_lim(i), ...
        'sigma_rot', material_data.sigma_rot(i), ...
        'sigma_cort', material_data.sigma_cort(i), ...
        'type_material', material_data.type_material{i} ...
    );
end

% Define PSHELL properties, integrating material properties
pshell_info = struct( ...
    'property_id', 1, ...      % Unique PSHELL ID
    'material_id', 1, ...      % Corresponding MAT1 ID
    'thickness', 2.1, ...      % Shell thickness in mm or meters
    'bending_id', 1, ...       % Bending stiffness (uses MID)
    't_shear', 1.0, ...        % Shear thickness factor (T)
    'material_mid2', 0, ...    % Secondary material (for composites)
    'tension_mid3', 0, ...     % Tension material (not used here)
    'material_mid4', 0 ...    % Additional material property
);

% % Define PSHELL properties, integrating material properties
% pshell_info = struct( ...
%     'property_id', 1, ...      % Unique PSHELL ID
%     'material_id', 1, ...      % Corresponding MAT1 ID
%     'thickness', 2.1, ...      % Shell thickness in mm or meters
%     'bending_id', 1, ...       % Bending stiffness (uses MID)
%     't_shear', 1.0, ...        % Shear thickness factor (T)
%     'material_mid2', 0, ...    % Secondary material (for composites)
%     'tension_mid3', 0, ...     % Tension material (not used here)
%     'material_mid4', 0, ...    % Additional material property
%     'E', mat.E, ...            % Young's modulus
%     'nu', mat.nu, ...          % Poisson's ratio
%     'G', mat.G, ...            % Shear modulus
%     'rho', mat.rho, ...        % Density
%     'sigma_lim', mat.sigma_lim, ...  % Limit stress
%     'sigma_rot', mat.sigma_rot, ...  % Rotation stress
%     'sigma_cort', mat.sigma_cort, ... % Shear stress
%     'type_material', mat.type_material ... % Material type (metal, composite)
% );

%% Loading nodes
combined_nodes = avion.elements.nodes.combined_nodes; 
combined_nodes_fuselaje = avion.elements.nodes.combined_nodes_fuselaje; 

combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, ...
    avion.perfil.airfoil, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, false);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);

%% Loading Elements Quads

% Vertical spars
quad_rear = avion.elements.quad.quad_rear ;
quad_front = avion.elements.quad_front ;
quad_rear_fuselaje = avion.elements.quad.quad_rear_fuselaje ;
quad_front_fuselaje = avion.elements.quad.quad_front_fuselaje ;

% Vertical spars
quad_surfaces_vertical_rib_ala = avion.elements.quad.quad_surfaces_vertical_rib_ala;
quad_surfaces_vertical_rib_fuselaje = avion.elements.quad.quad_surfaces_vertical_rib_fuselaje ;

% Horizontal Wing
quad_rear_spar_wing = avion.elements.quad.quad_rear_spar_wing ;
quad_irregular_wing = avion.elements.quad.quad_irregular_wing;
quads_regular_wing = avion.elements.quad.quads_regular_wing ;
quad_root = avion.elements.quad.quad_root;
quad_root_stringer = avion.elements.quad.quad_root_stringer ;

% Horizontal fuselaje
quad_rear_root_fuselaje = avion.elements.quad.quad_rear_root_fuselaje;
quad_front_root_fuselaje = avion.elements.quad.quad_front_root_fuselaje ;
quad_fuselaje = avion.elements.quad.quad_fuselaje ;

% Triangulo
tri_surfaces = avion.elements.tri.tri_surfaces ;
tri_root = avion.elements.tri.tri_root;
tri_root_stringer = avion.elements.tri.tri_root_stringer;

% lineas
lines = avion.elements.lines;

%% Crod
% lines extrados
lines_extrados = lines(lines.h == 'extrados',:);
lines_extrados_cordones_wing = lines_extrados(lines_extrados.tag == 'rear spar' | lines_extrados.tag == 'front spar',:);
lines_extrados_largerillo_wing = lines_extrados(lines_extrados.tag == 'stringer'| lines_extrados.tag == 'ribs',:);
lines_extrados_cordones_fuselaje = lines_extrados(lines_extrados.tag == 'rear spar fuselaje' | lines_extrados.tag == 'front spar fuselaje',:);
lines_extrados_largerillo_fuselaje = lines_extrados(lines_extrados.tag == 'stringer fuselaje'| lines_extrados.tag == 'ribs fuselaje',:);

% lines intrados
lines_intrados = lines(lines.h == 'intrados',:);
lines_intrados_cordones_wing = lines_intrados(lines_intrados.tag == 'rear spar' | lines_intrados.tag == 'front spar',:);
lines_intrados_largerillo_wing = lines_intrados(lines_intrados.tag == 'stringer'| lines_intrados.tag == 'ribs',:);
lines_intrados_cordones_fuselaje = lines_intrados(lines_intrados.tag == 'rear spar fuselaje' | lines_intrados.tag == 'front spar fuselaje',:);
lines_intrados_largerillo_fuselaje = lines_intrados(lines_intrados.tag == 'stringer fuselaje'| lines_intrados.tag == 'ribs fuselaje',:);

% lines verticales
lines_vertical = lines(lines.h == 'vertical',:);

%% Wing Horizontal

% Larguero posterior
quad_rear_spar_wing_3D = preprocess_3D_quads(quad_rear_spar_wing);
quad_rear_spar_wing_extrados = quad_rear_spar_wing_3D(quad_rear_spar_wing_3D.h == 'extrados',:);
quad_rear_spar_wing_intrados = quad_rear_spar_wing_3D(quad_rear_spar_wing_3D.h == 'intrados',:);

% Quad regular
quads_regular_wing_3D = preprocess_3D_quads(quads_regular_wing);
quads_regular_wing_extrados = quads_regular_wing_3D(quads_regular_wing_3D.h == 'extrados',:);
quads_regular_wing_intrados = quads_regular_wing_3D(quads_regular_wing_3D.h == 'intrados',:);

% Quad irregular
quad_irregular_wing_3D = preprocess_3D_quads(quad_irregular_wing);
quad_irregular_wing_extrados = quad_irregular_wing_3D(quad_irregular_wing_3D.h == 'extrados',:);
quad_irregular_wing_intrados = quad_irregular_wing_3D(quad_irregular_wing_3D.h == 'intrados',:);

% Quad encastre
quad_root_3D = preprocess_3D_quads(quad_root);
quad_root_extrados = quad_root_3D(quad_root_3D.h == 'extrados',:);
quad_root_intrados = quad_root_3D(quad_root_3D.h == 'intrados',:);

% Quad corner root - larguero anterior
quad_root_stringer_3D = preprocess_3D_quads(quad_root_stringer);
quad_root_stringer_extrados = quad_root_stringer_3D(quad_root_stringer_3D.h == 'extrados',:);
quad_root_stringer_intrados = quad_root_stringer_3D(quad_root_stringer_3D.h == 'intrados',:);

% Triangulo en el larguero anterior
tri_surfaces_3D = preprocess_3D_tris(tri_surfaces);
tri_surfaces_extrados = tri_surfaces_3D(tri_surfaces_3D.h == 'extrados',:);
tri_surfaces_intrados = tri_surfaces_3D(tri_surfaces_3D.h == 'intrados',:);

% Triangulo en el encastre
tri_root_3D = preprocess_3D_tris(tri_root);
tri_root_extrados = tri_root_3D(tri_root_3D.h == 'extrados',:);
tri_root_intrados = tri_root_3D(tri_root_3D.h == 'intrados',:);

% Triangulo en la esquina encastre-larguero_anterior
tri_root_stringer_3D = preprocess_3D_tris(tri_root_stringer);
tri_root_stringer_extrados = tri_root_stringer_3D(tri_root_stringer_3D.h == 'extrados',:);
tri_root_stringer_intrados = tri_root_stringer_3D(tri_root_stringer_3D.h == 'intrados',:);

%% Fuselaje Horizontal

% Larguero posterior
quad_rear_root_fuselaje_3D = preprocess_3D_quads(quad_rear_root_fuselaje);
quad_rear_root_fuselaje_extrados = quad_rear_root_fuselaje_3D(quad_rear_root_fuselaje_3D.h == 'extrados',:);
quad_rear_root_fuselaje_intrados = quad_rear_root_fuselaje_3D(quad_rear_root_fuselaje_3D.h == 'intrados',:);

% Larguero anterior
quad_front_root_fuselaje_3D = preprocess_3D_quads(quad_front_root_fuselaje);
quad_front_root_fuselaje_extrados = quad_front_root_fuselaje_3D(quad_front_root_fuselaje_3D.h == 'extrados',:);
quad_front_root_fuselaje_intrados = quad_front_root_fuselaje_3D(quad_front_root_fuselaje_3D.h == 'intrados',:);

% Quad regular fuselaje
quad_fuselaje_3D = preprocess_3D_quads(quad_fuselaje);
quad_fuselaje_extrados = quad_fuselaje_3D(quad_fuselaje_3D.h == 'extrados',:);
quad_fuselaje_intrados = quad_fuselaje_3D(quad_fuselaje_3D.h == 'intrados',:);


% %% Fuselaje vertical
% % Larguero posterior
% quad_rear_fuselaje_3D = preprocess_3D_quads(quad_rear_fuselaje);
% quad_rear_fuselaje_extrados = quad_rear_fuselaje_3D(quad_rear_fuselaje_3D.h == 'extrados',:);
% quad_rear_fuselaje_intrados = quad_rear_fuselaje_3D(quad_rear_fuselaje_3D.h == 'intrados',:);
% 
% % Larguero posterior
% quad_front_fuselaje_3D = preprocess_3D_quads(quad_front_fuselaje);
% quad_front_fuselaje_extrados = quad_front_fuselaje_3D(quad_front_fuselaje_3D.h == 'extrados',:);
% quad_front_fuselaje_intrados = quad_front_fuselaje_3D(quad_front_fuselaje_3D.h == 'intrados',:);
% 
% % Quad regular fuselaje
% quad_fuselaje_3D = preprocess_3D_quads(quad_fuselaje);
% quad_fuselaje_extrados = quad_fuselaje_3D(quad_fuselaje_3D.h == 'extrados',:);
% quad_fuselaje_intrados = quad_fuselaje_3D(quad_fuselaje_3D.h == 'intrados',:);


%% Elementos en extrados horizontales
% Materiales extrados
% Example: Select a material for a PSHELL (change dynamically)
chosen_material = 'Aluminum_7075_T6'; % Example selection
mat_extrados = materials.(chosen_material); % Get the material properties
mat_extrados.material_id = 1;
p_shell_extrados = pshell_info;
p_shell_extrados_thickness = predim.structure.tss;
p_shell_extrados.thickness = mean(p_shell_extrados_thickness);
% 
% % Example: Material Information
% material_info = struct();
% material_info.material_id = 1; % Material ID (MID)
% material_info.E = 69000;      % Young's modulus in MPa
% material_info.nu = 0.33;      % Poisson's ratio
% material_info.rho = 2.7e-9;   % Density in tonne/mm³ (optional)

% Crod
lines_extrados_cordones_updated = process_lines_v8(combined_nodes_3D_processed, [lines_extrados_cordones_wing; lines_extrados_cordones_fuselaje]);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines_extrados_cordon.bdf"), lines_extrados_cordones_updated, mat_extrados, property_info_cordon);

lines_extrados_larguerillo_updated = process_lines_v8(combined_nodes_3D_processed, [lines_extrados_largerillo_wing; lines_extrados_largerillo_fuselaje]);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines_extrados_larguerillo.bdf"), lines_extrados_larguerillo_updated, mat_extrados, property_info_larguerillo);

% % Wing
% quad_rear_spar_wing_extrados
% quads_regular_wing_extrados
% quad_irregular_wing_extrados
% quad_root_extrados
% quad_root_stringer_extrados

% %  Fuselaje
% quad_rear_root_fuselaje_extrados
% quad_front_root_fuselaje_extrados
% quad_fuselaje_extrados

quad_extrados_wing = [quad_rear_spar_wing_extrados; quads_regular_wing_extrados; quad_irregular_wing_extrados;...
                      quad_root_extrados; quad_root_stringer_extrados];
quads_all_3D_processed = process_quads(combined_nodes_3D_processed,[quad_extrados_wing]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_wing_extrados.bdf"), quads_all_3D_processed, [], p_shell_extrados, mat_extrados);

% Triangulo
tri_extrados = [tri_surfaces_extrados; tri_root_extrados; tri_root_stringer_extrados];
tri_extrados_processed = process_tri(combined_nodes_3D_processed, tri_extrados);
write_bdf_tris_v1(fullfile(avion.folder.data,"\tri_extrados.bdf"), tri_extrados_processed, p_shell_extrados, mat_extrados);

% Fuselaje
quad_extrados_fuselaje = [quad_rear_root_fuselaje_extrados; quad_front_root_fuselaje_extrados;...
                          quad_fuselaje_extrados];
quad_extrados_fuselaje_processed = process_quads(combined_nodes_3D_processed,[quad_extrados_fuselaje]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_fuselaje_extrados.bdf"), quad_extrados_fuselaje_processed, [], p_shell_extrados, mat_extrados);

%% Elementos en intrados horizontales
% Materiales intrados
% Example: Select a material for a PSHELL (change dynamically)
chosen_material = 'Aluminum_2024_T3'; % Example selection
mat_intrados = materials.(chosen_material); % Get the material properties
mat_intrados.material_id = 2;
p_shell_intrados = pshell_info;
p_shell_intrados_thickness = predim.structure.tsi;
p_shell_intrados.thickness = mean(p_shell_intrados_thickness);

lines_intrados_cordones_updated = process_lines_v8(combined_nodes_3D_processed, [lines_intrados_cordones_wing; lines_intrados_cordones_fuselaje]);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines_intrados_cordon.bdf"), lines_intrados_cordones_updated, mat_intrados, property_info_cordon);

lines_intrados_larguerillo_updated = process_lines_v8(combined_nodes_3D_processed, [lines_intrados_largerillo_wing; lines_intrados_largerillo_fuselaje]);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines_intrados_larguerillo.bdf"), lines_intrados_larguerillo_updated, mat_intrados, property_info_larguerillo);

% Wing
quad_intrados_wing = [quad_rear_spar_wing_intrados; quads_regular_wing_intrados; quad_irregular_wing_intrados;...
                      quad_root_intrados; quad_root_stringer_intrados];
quad_intrados_wing_3D_processed = process_quads(combined_nodes_3D_processed,[quad_intrados_wing]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_wing_intrados.bdf"), quad_intrados_wing_3D_processed, [], p_shell_intrados, mat_intrados);

% Triangulo
tri_intrados = [tri_surfaces_intrados; tri_root_intrados; tri_root_stringer_intrados]
tri_intrados_processed = process_tri(combined_nodes_3D_processed, tri_intrados);
write_bdf_tris_v1(fullfile(avion.folder.data,"\tri_intrados.bdf"), tri_intrados_processed, p_shell_intrados, mat_intrados);

% Fuselaje
quad_intrados_fuselaje = [quad_rear_root_fuselaje_intrados; quad_front_root_fuselaje_intrados;...
                          quad_fuselaje_intrados];
quad_intrados_fuselaje_processed = process_quads(combined_nodes_3D_processed,[quad_intrados_fuselaje]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_fuselaje_intrados.bdf"), quad_intrados_fuselaje_processed, [], p_shell_intrados, mat_intrados);

%% Elementos verticales
% Materiales Vertical
% Example: Select a material for a PSHELL (change dynamically)
chosen_material = 'Aluminum_7075_T6'; % Example selection
mat_vertical = materials.(chosen_material); % Get the material properties
mat_vertical.material_id = 3;
p_shell_vertical = pshell_info;
p_shell_vertical_thickness = predim.structure.tl;
p_shell_vertical.thickness = mean(p_shell_vertical_thickness);

% Crod
lines_vertical_updated = process_lines_v8(combined_nodes_3D_processed, lines_vertical);
write_bdf_lines_v3(fullfile(avion.folder.data,"\lines_vertical.bdf"), lines_vertical_updated, mat_vertical, property_info_larguerillo);


%  Quad
quad_vertical = [quad_rear; quad_front; quad_rear_fuselaje; quad_front_fuselaje];
quad_vertical_3D_processed = process_quads(combined_nodes_3D_processed,[quad_vertical]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_vertical.bdf"), quad_vertical_3D_processed, [], p_shell_vertical, mat_vertical);


% Vertical ribs
% quad_surfaces_vertical_rib_ala
% quad_surfaces_vertical_rib_fuselaje
quad_vertical_ribs = [quad_surfaces_vertical_rib_ala; quad_surfaces_vertical_rib_fuselaje];
quad_vertical_ribs_3D_processed = process_quads(combined_nodes_3D_processed,[quad_vertical_ribs]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_vertical_ribs.bdf"), quad_vertical_ribs_3D_processed, [], p_shell_vertical, mat_vertical);

