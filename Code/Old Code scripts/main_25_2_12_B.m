% %% 🔹 Step 1: Ask for the Project Folder Path
% clc; clear;
% disp('----------------------------------------');
% disp('📂 Select or Create a Project Folder');
% disp('----------------------------------------');
% 
% projectRoot = input('Enter the folder path where data will be saved: ', 's');
% 
% % Create folder if it does not exist
% if ~isfolder(projectRoot)
%     mkdir(projectRoot);
%     disp(['✅ Created project folder: ', projectRoot]);
% else
%     disp(['ℹ️ Using existing project folder: ', projectRoot]);
% end




addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

%% Añadir Information
name_structural_parameters = "Structural_parameters_a350_1";
name_plane = "Boeing_737";
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer,"Data");
% databasePath  = fullfile(database_computer,"Data");
databasePath = fullfile(database_computer, 'Data', 'TFG_Amora.mat');

% Load database if it exists
if isfile(databasePath)
    load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    disp('✅ Database loaded.');
else
    TFG_Amora = struct('datosEstructural', struct(), 'aviones', struct());
    disp('⚠️ No database found. Creating a new one.');
end

%% 🔹 Step 2: Structural Parameters Selection
disp('----------------------------------------');
disp('🔧 Structural Parameters Selection');
disp('----------------------------------------');

% List available structural parameters
structNames = fieldnames(TFG_Amora.datosEstructural);
if isempty(structNames)
    disp('⚠️ No structural parameters found in the database.');
    structChoice = 'new';
else
    disp('Available Structural Parameters:');
    for i = 1:length(structNames)
        fprintf('%d) %s\n', i, structNames{i});
    end
    structChoice = input('Enter the number to select, or type "new" to create: ', 's');
end

if strcmp(structChoice, 'new')
    name_structural_parameters = input('Enter a name for the new structural parameters: ', 's');
    
    % Ask user for input values
    distancia_anterior = input('Enter distance for anterior stringer (% of chord): ');
    distancia_posterior = input('Enter distance for posterior stringer (% of chord): ');
    n = input('Enter load factor: ');
    factor_material = input('Enter material factor: ');
    espesor = input('Enter thickness: ');
    carga_maxima = input('Enter max load: ');
    
    % Store in database
    TFG_Amora.datosEstructural.(name_structural_parameters) = struct( ...
        'distancia_larguero_anterior_cuerda_porcentaje', distancia_anterior, ...
        'distancia_larguero_posterior_cuerda_porcentaje', distancia_posterior, ...
        'n', n, ...
        'factor_material', factor_material, ...
        'espesor', espesor, ...
        'carga_maxima', carga_maxima, ...
        'projectRoot', projectRoot ...
    );
else
    % User selects an existing parameter
    structIndex = str2double(structChoice);
    if isnan(structIndex) || structIndex < 1 || structIndex > length(structNames)
        error('❌ Invalid selection.');
    end
    name_structural_parameters = structNames{structIndex};
end

% Save selection
datosEstructural = TFG_Amora.datosEstructural.(name_structural_parameters);
disp(['✅ Selected Structural Parameters: ', name_structural_parameters]);

%% 🔹 Step 3: Aircraft Selection
disp('----------------------------------------');
disp('🛩 Aircraft Selection');
disp('----------------------------------------');

% List available aircraft
aircraftNames = fieldnames(TFG_Amora.aviones);
availableAircraft = {};
count = 0;

for i = 1:length(aircraftNames)
    if strcmp(TFG_Amora.aviones.(aircraftNames{i}).datosEstructural_name, name_structural_parameters)
        count = count + 1;
        availableAircraft{count} = aircraftNames{i};
        fprintf('%d) %s\n', count, availableAircraft{count});
    end
end

if count == 0
    disp('⚠️ No aircraft found using these structural parameters.');
    aircraftChoice = 'new';
else
    aircraftChoice = input('Enter the number to select, or type "new" to create: ', 's');
end

if strcmp(aircraftChoice, 'new')
    name_plane = input('Enter a name for the new aircraft: ', 's');
    
    % Ask user for aircraft details
    MTOW = input('Enter Maximum Take-Off Weight (kg): ');
    Superficie = input('Enter Wing Area (m²): ');
    flecha_radian = input('Enter Sweep Angle (radians): ');
    b = input('Enter Wingspan (meters): ');
    Lf = input('Enter Half Fuselage Length (meters): ');
    c1 = input('Enter Root Chord (meters): ');
    c2 = input('Enter Tip Chord (meters): ');

    % Store in database
    TFG_Amora.aviones.(name_plane) = struct( ...
        'MTOW', MTOW, ...
        'superficie', Superficie, ...
        'geometria', struct( ...
            'flecha_radian', flecha_radian, ...
            'b', b, ...
            'Lf', Lf, ...
            'c1', c1, ...
            'c2', c2, ...
            'Lw', b / 2 - (Lf / 2) ...
        ), ...
        'datosEstructural_name', name_structural_parameters, ...
        'datosEstructural', datosEstructural ...
    );
else
    % User selects an existing aircraft
    aircraftIndex = str2double(aircraftChoice);
    if isnan(aircraftIndex) || aircraftIndex < 1 || aircraftIndex > count
        error('❌ Invalid selection.');
    end
    name_plane = availableAircraft{aircraftIndex};
end

% Save selection
avion = TFG_Amora.aviones.(name_plane);
disp(['✅ Selected Aircraft: ', name_plane]);

%% 🔹 Step 4: Save Everything and Proceed
save(databasePath, 'TFG_Amora');
disp('✅ Database updated.');
disp('🚀 System is now ready for calculations!');
