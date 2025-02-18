addpath('./1. Database');

%% 🔹 Define Database Path
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
databasePath = fullfile(database_computer, 'Data', 'TFG_Amora.mat');

%% 🔹 Load or Create Database
if isfile(databasePath)
    load(databasePath, 'TFG_Amora');
    disp('✅ Database loaded.');
else
    TFG_Amora = struct('datosEstructural', struct(), 'aircraft_data', struct(), 'aviones', struct(), 'materials', struct());
    disp('⚠️ No database found. Creating a new one.');
end

%% 🔹 Database Management Menu
while true
    clc;
    disp('----------------------------------------');
    disp('📊 MAIN DATABASE MENU');
    disp('----------------------------------------');
    disp('1️⃣ Add Structural Parameters (`datosEstructural`)');
    disp('2️⃣ Add Aircraft Data');
    disp('3️⃣ Construct Aircraft (Select from `datosEstructural` & `aircraft_data`)');
    disp('4️⃣ Add Material Properties');
    disp('5️⃣ Add Structural Parts (Cordon, Larguerillo, Cajón)');
    disp('6️⃣ Read Database (Load structural & aircraft data from CSV)');
    disp('7️⃣ Exit to Main System');
    
    choice = input('Select an option (1-6): ', 's');

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

    elseif strcmp(choice, '3')
%% 🔹 Step 3: Create Final Aircraft in `aviones`
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

    elseif strcmp(choice, '4')
        %% 🔹 Step 4: Add or Select Material
        disp('----------------------------------------');
        disp('🛠 Material Database');
        disp('----------------------------------------');

        % ✅ List existing materials
        materialNames = fieldnames(TFG_Amora.materials);
        if isempty(materialNames)
            disp('⚠️ No materials found in the database.');
            materialChoice = 'new';
        else
            disp('Available Materials:');
            for i = 1:length(materialNames)
                fprintf('%d) %s\n', i, materialNames{i});
            end
            fprintf('%d) ➕ Create New Material\n', length(materialNames) + 1);
            materialChoice = input('Select a material by number or type "new": ', 's');
        end

        if strcmp(materialChoice, 'new') || str2double(materialChoice) == length(materialNames) + 1
            material_name = input('Enter material name: ', 's');

            % ✅ Ask for material properties
            E = input('Enter Young’s modulus (MPa): ');
            nu = input('Enter Poisson’s ratio: ');
            rho = input('Enter density (kg/m³): ');
            sigma_lim = input('Enter Esfuerzo límite (MPa): ');
            sigma_rot = input('Enter Esfuerzo rotura (MPa): ');
            sigma_cort = input('Enter Esfuerzo cortadura (MPa): ');

            % ✅ Store material in database
            TFG_Amora.materials.(material_name) = struct( ...
                'E', E*1e6, ...
                'nu', nu, ...
                'rho', rho, ...
                'sigma_lim', sigma_lim*1e6, ...  % Esfuerzo límite (Yield Strength)
                'sigma_rot', sigma_rot*1e6, ...  % Esfuerzo de rotura (Ultimate Strength)
                'sigma_cort', sigma_cort*1e6 ... % Esfuerzo de cortadura (Shear Strength)
            );

            % ✅ Save updated database
            save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
            disp(['✅ Material "', material_name, '" saved to database.']);
        else
            % ✅ User selects an existing material
            materialIndex = str2double(materialChoice);
            if isnan(materialIndex) || materialIndex < 1 || materialIndex > length(materialNames)
                error('❌ Invalid selection.');
            end
            material_name = materialNames{materialIndex};
            disp(['✅ Selected Material: ', material_name]);
        end

    elseif strcmp(choice, '5')
      %% 🔹 Step 5: Add Structural Parts
        disp('----------------------------------------');
        disp('🏗️ Structural Parts Database');
        disp('----------------------------------------');
        disp('1️⃣ Add Cordon');
        disp('2️⃣ Add Larguerillo');
        disp('3️⃣ Add Cajón (Requires Cordon & Larguerillo)');

        partChoice = input('Select an option (1-3): ', 's');

        if strcmp(partChoice, '1')
            % ✅ Add Cordon
            cordon_name = input('Enter name for the new Cordon: ', 's');
            material_name = input('Enter material name for the Cordon: ', 's');

            TFG_Amora.parts.cordon.(cordon_name) = struct( ...
                'material', material_name ...
            );
            disp(['✅ Cordon "', cordon_name, '" saved.']);

        elseif strcmp(partChoice, '2')
            % ✅ Add Larguerillo
            larguerillo_name = input('Enter name for the new Larguerillo: ', 's');
            material_name = input('Enter material name for the Larguerillo: ', 's');

            TFG_Amora.parts.larguerillo.(larguerillo_name) = struct( ...
                'material', material_name ...
            );
            disp(['✅ Larguerillo "', larguerillo_name, '" saved.']);

        elseif strcmp(partChoice, '3')
            % ✅ Add Cajón (Needs Cordon & Larguerillo)
            cajon_name = input('Enter name for the new Cajón: ', 's');

            % ✅ Select Cordon
            cordonNames = fieldnames(TFG_Amora.parts.cordon);
            disp('Available Cordons:');
            for i = 1:length(cordonNames)
                fprintf('%d) %s\n', i, cordonNames{i});
            end
            cordonIndex = input('Select a Cordon: ');
            selected_cordon = cordonNames{cordonIndex};

            % ✅ Select Larguerillo
            larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
            disp('Available Larguerillos:');
            for i = 1:length(larguerilloNames)
                fprintf('%d) %s\n', i, larguerilloNames{i});
            end
            larguerilloIndex = input('Select a Larguerillo: ');
            selected_larguerillo = larguerilloNames{larguerilloIndex};

            TFG_Amora.parts.cajon.(cajon_name) = struct( ...
                'cordon', selected_cordon, ...
                'larguerillo', selected_larguerillo ...
            );
            disp(['✅ Cajón "', cajon_name, '" saved.']);
        end

        % ✅ Save database
        save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

    elseif strcmp(choice, '6')
        %% 🔹 Step 6: Read Database
        disp('🔄 Reading database from CSV files...');
        read_database(database_computer);
        disp('✅ Database successfully updated.');

    elseif strcmp(choice, '7')
        %% 🚪 Exit to Main Menu
        disp('🔙 Returning to Main System...');
        pause(1);
        break;

    else
        disp('❌ Invalid choice. Please select 1-7.');
        pause(2);
    end
end


%% 🔹 Save Database
save(databasePath, 'TFG_Amora');
disp('💾 Database saved.');
