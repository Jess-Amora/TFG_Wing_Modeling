addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

%% Añadir Information
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
% data_path = fullfile(database_computer,"Data");

%% Load or Create Database
databasePath = fullfile(database_computer, 'Data', 'TFG_Amora.mat');

if isfile(databasePath)
    load(databasePath, 'TFG_Amora');
    disp('✅ Database loaded.');
else
    TFG_Amora = struct('datosEstructural', struct(), 'aircraft_data', struct(), 'aviones', struct());
    disp('⚠️ No database found. Creating a new one.');
end
%% 🔹 Menu System for Database Management
while true
    clc;
    disp('----------------------------------------');
    disp('📊 MAIN DATABASE MENU');
    disp('----------------------------------------');
    disp('1️⃣ Add Structural Parameters (`datosEstructural`)');
    disp('2️⃣ Add Aircraft Data');
    disp('3️⃣ Construct Aircraft (Select from `datosEstructural` & `aircraft_data`)');
    disp('4️⃣ Exit to Main System');
    
    choice = input('Select an option (1-4): ', 's');

if strcmp(choice, '1')
%% 🔹 Step 1: Structural Parameters Selection
disp('----------------------------------------');
disp('🔧 Structural Parameters Selection');
disp('----------------------------------------');

% List available structural parameters
structNames = fieldnames(TFG_Amora.datosEstructural);
if isempty(structNames)
    disp('⚠️ No structural parameters found.');
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
        'projectRoot', database_computer ...
    );
else
    structIndex = str2double(structChoice);
    if isnan(structIndex) || structIndex < 1 || structIndex > length(structNames)
        error('❌ Invalid selection.');
    end
    name_structural_parameters = structNames{structIndex};
end

datosEstructural = TFG_Amora.datosEstructural.(name_structural_parameters);
disp(['✅ Selected Structural Parameters: ', name_structural_parameters]);
save(databasePath, 'TFG_Amora');
disp('✅ Database updated.');
disp('🚀 System is now ready for calculations!');
elseif strcmp(choice, '2')
%% 🔹 Step 2: Aircraft Selection from Database or New Input
disp('----------------------------------------');
disp('🛩 Aircraft Selection');
disp('----------------------------------------');

% List available aircraft
aircraftNames = fieldnames(TFG_Amora.aircraft_data);
if isempty(aircraftNames)
    disp('⚠️ No aircraft found in the database.');
    aircraftChoice = 'new';
else
    disp('Available Aircraft Data:');
    for i = 1:length(aircraftNames)
        fprintf('%d) %s\n', i, aircraftNames{i});
    end
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

    % Store in aircraft_data
    TFG_Amora.aircraft_data.(name_plane) = struct( ...
        'MTOW', MTOW, ...
        'superficie', Superficie, ...
        'geometria', struct( ...
            'flecha_radian', flecha_radian, ...
            'b', b, ...
            'Lf', Lf, ...
            'c1', c1, ...
            'c2', c2, ...
            'Lw', b / 2 - (Lf / 2) ...
        ) ...
    );
else
    aircraftIndex = str2double(aircraftChoice);
    if isnan(aircraftIndex) || aircraftIndex < 1 || aircraftIndex > length(aircraftNames)
        error('❌ Invalid selection.');
    end
    name_plane = aircraftNames{aircraftIndex};
end

aircraftData = TFG_Amora.aircraft_data.(name_plane);
disp(['✅ Selected Aircraft Data: ', name_plane]);
save(databasePath, 'TFG_Amora');
disp('✅ Database updated.');
disp('🚀 System is now ready for calculations!');
elseif strcmp(choice, '3')
%% 🔹 Step 3: Create Final Aircraft in `aviones`
%% 🔹 Step 1: Structural Parameters Selection
disp('----------------------------------------');
disp('🔧 Structural Parameters Selection');
disp('----------------------------------------');

% List available structural parameters
structNames = fieldnames(TFG_Amora.datosEstructural);
if isempty(structNames)
    disp('⚠️ No structural parameters found.');
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
        'projectRoot', database_computer ...
    );
else
    structIndex = str2double(structChoice);
    if isnan(structIndex) || structIndex < 1 || structIndex > length(structNames)
        error('❌ Invalid selection.');
    end
    name_structural_parameters = structNames{structIndex};
end

datosEstructural = TFG_Amora.datosEstructural.(name_structural_parameters);
%% 🔹 Step 2: Aircraft Selection from Database or New Input
disp('----------------------------------------');
disp('🛩 Aircraft Selection');
disp('----------------------------------------');

% List available aircraft
aircraftNames = fieldnames(TFG_Amora.aircraft_data);
if isempty(aircraftNames)
    disp('⚠️ No aircraft found in the database.');
    aircraftChoice = 'new';
else
    disp('Available Aircraft Data:');
    for i = 1:length(aircraftNames)
        fprintf('%d) %s\n', i, aircraftNames{i});
    end
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

    % Store in aircraft_data
    TFG_Amora.aircraft_data.(name_plane) = struct( ...
        'MTOW', MTOW, ...
        'superficie', Superficie, ...
        'geometria', struct( ...
            'flecha_radian', flecha_radian, ...
            'b', b, ...
            'Lf', Lf, ...
            'c1', c1, ...
            'c2', c2, ...
            'Lw', b / 2 - (Lf / 2) ...
        ) ...
    );
else
    aircraftIndex = str2double(aircraftChoice);
    if isnan(aircraftIndex) || aircraftIndex < 1 || aircraftIndex > length(aircraftNames)
        error('❌ Invalid selection.');
    end
    name_plane = aircraftNames{aircraftIndex};
end

aircraftData = TFG_Amora.aircraft_data.(name_plane);
fullAircraftName = strcat(name_plane, '_', name_structural_parameters);

% Call addAircraftData to create the final aircraft entry with calculations
TFG_Amora = addAircraftData(name_plane, ...
    aircraftData.MTOW, ...  % MTOW (kg)
    aircraftData.superficie, ... % Wing Area (m²)
    aircraftData.geometria.flecha_radian, ... % Sweep Angle (radian)
    aircraftData.geometria.b, ... % Wingspan (m)
    aircraftData.geometria.Lf, ... % Half fuselage length (Lf)
    aircraftData.geometria.c1, ... % Root chord length (c1)
    aircraftData.geometria.c2, ... % Tip chord length (c2)
    name_structural_parameters, datosEstructural);

disp(['✅ Aircraft "', fullAircraftName, '" has been created and linked to structural parameters.']);

%% 🔹 Step 4: Save Database
save(databasePath, 'TFG_Amora');
disp('✅ Database updated.');
disp('🚀 System is now ready for calculations!');
elseif strcmp(choice, '4')
        %% 🚪 Exit the Menu
        disp('🔙 Returning to Main System...');
        pause(1);
        break;

    else
        disp('❌ Invalid choice. Please select 1-4.');
        pause(2);
end
end

