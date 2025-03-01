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
    disp('5️⃣ create naca');
    disp('6️⃣ Read Database (Load structural & aircraft data from CSV)');
    disp('7 Exit to Main System');

    
    choice = input('Select an option (1-5): ', 's');

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
         % ✅ NACA Wing Creation or View
            while true
                disp('----------------------------------------');
                    disp('🛩 Select an Aircraft for Naca:');
                    avionNames = fieldnames(TFG_Amora.aviones);
                
                    if isempty(avionNames)
                        disp('⚠️ No aircraft data available. Please add data first.');
                        return;
                    end
                
                    % ✅ Display available aircraft options
                    for i = 1:length(avionNames)
                        fprintf('%d) %s\n', i, avionNames{i});
                    end
                    fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);
                
                    % ✅ User selects an aircraft
                    avionChoice = input('Select an option: ', 's');
                    avionIndex = str2double(avionChoice);
                
                    if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
                        disp('❌ Invalid selection. Returning to menu.');
                        continue;
                    end
                
                    if avionIndex == length(avionNames) + 1
                        disp('🔙 Returning to Main Menu...');
                        run('main.m');
                        return;
                    end
                
                    % ✅ Load selected aircraft
                    name = avionNames{avionIndex};
                    disp(['✅ Selected Aircraft: ', name]);
                    avion = TFG_Amora.aviones.(name);
                    
                disp('----------------------------------------');
                disp('✈️  NACA Wing Management');
                disp('1) Create or Overwrite NACA Wing');
                disp('2) View Existing NACA Wing');
                disp('3) 🔙 Return');

                nacaChoice = input('Select an option: ', 's');
                nacaIndex = str2double(nacaChoice);

                if isnan(nacaIndex) || nacaIndex < 1 || nacaIndex > 3
                    disp('❌ Invalid selection. Try again.');
                    continue;
                end

                if nacaIndex == 3
                    break;
                end

                if nacaIndex == 1
                    % ✅ User chooses to create a NACA 6-Series airfoil
                    disp('📌 Creating a NACA 6-Series Airfoil...');
                    
                    % Explain the parameters
                    disp('- m: Maximum camber (fraction of chord, e.g., 0.02 for 2%)');
                    disp('- p: Position of maximum camber (fraction of chord, e.g., 0.4 for 40%)');
                    disp('- t: Maximum thickness (fraction of chord, e.g., 0.12 for 12%)');
                    disp('- c: Chord length (m)');
                
                    % Ask for user input (or use default values)
                    m = input('Enter maximum camber (default 0.02): ');
                    if isempty(m), m = 0.02; end
                
                    p = input('Enter position of maximum camber (default 0.4): ');
                    if isempty(p), p = 0.4; end
                
                    t = input('Enter maximum thickness (default 0.12): ');
                    if isempty(t), t = 0.12; end
                
                    c = input('Enter chord length (default 1.0 m): ');
                    if isempty(c), c = 1.0; end
                
                    num_points = 100; % Fixed number of points for smooth airfoil curve
                    show_graph = true; % Display the airfoil plot
                
                    % 🔹 Generate airfoil struct
                    airfoil = naca6series(m, p, t, c, num_points, show_graph);
                    
                    % ✅ Retrieve wing geometry data
                    wing_geom = avion.ala.geometria;
                    
                    % ✅ Extract x-coordinates (spanwise locations)
                    x_span = avion.coordenadas.x_local_ala; % Spanwise positions
                    
                    % ✅ Compute chord distribution using front and rear spar lines
                    y_front = wing_geom.linea_larguero_anterior; % y-coordinates of front spar
                    y_rear = wing_geom.linea_larguero_posterior; % y-coordinates of rear spar
                    
                    % ✅ Chord length at each spanwise position
                    chord_distribution = abs(y_rear - y_front); % Compute chord length as difference
                
                
                    % 🔹 Compute wing box height along the span
                    h_values = compute_wingbox_height(airfoil, chord_distribution);
                    
                    % 🔹 Store in aircraft struct
                    TFG_Amora.aviones.(name).perfil.h_values = h_values;
                    TFG_Amora.aviones.(name).perfil.airfoil = airfoil; % Save full airfoil struct
                    save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
                    
                    disp('✅ Wing box height stored successfully.');
                elseif nacaIndex == 2
                    if isfield(TFG_Amora.aviones.(name), 'perfil')
                        disp('✅ Existing NACA Wing Found:');
                        disp(TFG_Amora.aviones.(name).perfil);
                    else
                        disp('❌ No NACA Wing available. Please create one first.');
                    end
                    input('Press Enter to return...');
                end
            end

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
