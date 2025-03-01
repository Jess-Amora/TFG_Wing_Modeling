% addpath('./5. FEA validation');
addpath('./4. Generate FEA Structure');
addpath('./4. Generate FEA Structure/Method5');
%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

avion = TFG_Amora.aviones.Airbus_A380_Structural_parameters_A350;
ala = avion.ala;

Lf = avion.geometria.Lf;
Lw = avion.geometria.Lw;
c1 = avion.geometria.c1;
c2 = avion.geometria.c2;
b = avion.geometria.b;
tolerance = 1e-6;

y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;

combined_nodes = avion.elements.nodes;
combined_nodes_3D = generate_3D_nodes(combined_nodes, [], ...
    avion.perfil.airfoil, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, false);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);
quad_rear = avion.elements.quad.quad_rear;
%% Materiales
% % Example: Material Information
% material_info = struct();
% material_info.material_id = 1; % Material ID (MID)
% material_info.E = 69000;      % Young's modulus in MPa
% material_info.nu = 0.33;      % Poisson's ratio
% material_info.rho = 2.7e-9;   % Density in tonne/mm³ (optional)

% % Example: Material Information
% material_info = struct();
% material_info.material_id = 1; % Material ID (MID)
% material_info.E = 69000;      % Young's modulus in MPa
% material_info.nu = 0.33;      % Poisson's ratio
% material_info.rho = 2.7e-9;   % Density in tonne/mm³ (optional)
% 
% % Compute and add Shear Modulus G
% material_info.G = material_info.E / (2 * (1 + material_info.nu)); 

% % Example: Complete Material Information
% material_info = struct();
% material_info.material_id = 1;   % Material ID (MID)
% material_info.E = 69000;         % Young's modulus in MPa
% material_info.nu = 0.33;         % Poisson's ratio
% material_info.rho = 2.7e-9;      % Density in tonne/mm³ (optional)
% 
% % Compute and add Shear Modulus G
% material_info.G = material_info.E / (2 * (1 + material_info.nu)); 
% 
% % Add missing fields with filler values
% material_info.alpha = 2.3e-5;     % Thermal Expansion Coefficient (1/°C), placeholder value
% material_info.temperature = 20.0; % Reference Temperature (°C), placeholder value
% material_info.damping = 0.005;    % Structural Damping Coefficient, placeholder value
% 
% Define Material Properties in Proper Order
material_info = struct();
material_info.material_id = 1;  % Material ID (MID)
material_info.E = 69000;        % Young's modulus (MPa or N/mm²)
material_info.G = material_info.E / (2 * (1 + 0.33));  % Shear modulus (MPa)
material_info.nu = 0.33;        % Poisson's ratio
material_info.rho = 2.7e-9;     % Density (tonne/mm³)
material_info.alpha = 2.3e-5;   % Thermal expansion coefficient (1/°C)
material_info.tref = 20;        % Reference temperature (°C)
material_info.ge = 0.0;         % Structural damping coefficient (default 0)

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
%% Read material data from CSV
% % Open file for writing
% fileID = fopen('wing_structure.bdf', 'w');
% 
% % Write Material Card (MAT1) including G
% fprintf(fileID, 'MAT1    %d  %.2e  %.2f   %.2e  %.2e  %.2e\n', ...
%     pshell_info.material_id, mat.E, mat.nu, mat.rho, mat.sigma_lim, mat.G);
% 
% % Write Property Card (PSHELL)
% fprintf(fileID, 'PSHELL  %d  %d  %.3f  %d  %.2f  %d  %d  %d\n', ...
%     pshell_info.property_id, pshell_info.material_id, pshell_info.thickness, ...
%     pshell_info.bending_id, pshell_info.t_shear, ...
%     pshell_info.material_mid2, pshell_info.tension_mid3, pshell_info.material_mid4);
% 
% % Close file
% fclose(fileID);
% disp('Exported PSHELL & MAT1 to wing_structure.bdf!');

material_data = readtable(fullfile(database_computer, 'Data','materials.csv'), 'Format', '%s%f%f%f%f%f%f%f%s');


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

% Example: Select a material for a PSHELL (change dynamically)
chosen_material = 'Aluminum_7075_T6'; % Example selection
mat = materials.(chosen_material); % Get the material properties

% Define PSHELL properties, integrating material properties
pshell_info = struct( ...
    'property_id', 1, ...      % Unique PSHELL ID
    'material_id', 1, ...      % Corresponding MAT1 ID
    'thickness', 2.1, ...      % Shell thickness in mm or meters
    'bending_id', 1, ...       % Bending stiffness (uses MID)
    't_shear', 1.0, ...        % Shear thickness factor (T)
    'material_mid2', 0, ...    % Secondary material (for composites)
    'tension_mid3', 0, ...     % Tension material (not used here)
    'material_mid4', 0, ...    % Additional material property
    'E', mat.E, ...            % Young's modulus
    'nu', mat.nu, ...          % Poisson's ratio
    'G', mat.G, ...            % Shear modulus
    'rho', mat.rho, ...        % Density
    'sigma_lim', mat.sigma_lim, ...  % Limit stress
    'sigma_rot', mat.sigma_rot, ...  % Rotation stress
    'sigma_cort', mat.sigma_cort, ... % Shear stress
    'type_material', mat.type_material ... % Material type (metal, composite)
);

%% quads

% quads_all = [quad_rear_spar_wing; quad_irregular_wing; quad_surfaces_regular; quad_rectangular_regular; OnlyQuads_Fuselaje; quad_root; quad_root_stringer; quad_spars];


quad_rear_3D = preprocess_3D_quads(quad_rear);
quad_rear_3D_processed = process_quads(combined_nodes_3D_processed,[quad_rear_3D]);
write_bdf_quads(fullfile(avion.folder.data,"\quads_test.bdf"), quad_rear_3D_processed, [], pshell_info, material_info);
% 
