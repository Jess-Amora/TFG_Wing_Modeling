clear all;
addpath('./3. Strength Analysis');
% addpath('./shared'); % Ensure shared functions (like `naca6series.m`) are accessible

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

%% 🔹 Step 2: User Selects Aircraft for Strength Analysis
disp('----------------------------------------');
disp('🛩 Select an Aircraft for Strength Analysis:');
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
    return;
end

% ✅ If user selects the last option, return to `main_menu.m`
if avionIndex == length(avionNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m'); % Calls `main_menu.m`
    return;
end

% ✅ Load selected aircraft
name = avionNames{avionIndex}; % Selected aircraft name
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Define Airfoil for Strength Analysis (Optional)
disp('----------------------------------------');
disp('✈️  Airfoil Selection for Strength Analysis');
disp('1) Create a NACA 6-Series Airfoil');
disp('2) Skip (Use Existing Airfoil Data)');
disp('3) 🔙 Return to Main Menu');

airfoilChoice = input('Select an option: ', 's');
airfoilIndex = str2double(airfoilChoice);

if isnan(airfoilIndex) || airfoilIndex < 1 || airfoilIndex > 3
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

% ✅ If user selects option 3, return to `main_menu.m`
if airfoilIndex == 3
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

% ✅ Check if airfoil data already exists
if airfoilIndex == 2
    if isfield(TFG_Amora.aviones.(name), 'perfil')
        disp('✅ Existing airfoil data found. Skipping airfoil creation.');
    else
        disp('⚠️ No airfoil data available. Please create an airfoil first.');
        return;
    end
else
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
end


%% 🔹 Step 4: Check if Forces Exist
if ~isfield(avion, 'forces') || isempty(avion.forces)
    disp('⚠️ No aerodynamic & structural forces detected for this aircraft.');
    disp('2️⃣  Generate Wing Geometry & Compute Forces');
    disp('Returning to main menu...');
    return;
end

%% 🔹 Step 5: User Selects a Material for Pre-Dimensioning
disp('----------------------------------------');
disp('🔩 Select a Material for Pre-Dimensioning:');
materialNames = fieldnames(TFG_Amora.materials);

if isempty(materialNames)
    disp('⚠️ No material data available. Please add materials first.');
    return;
end

% ✅ Display available materials
for i = 1:length(materialNames)
    fprintf('%d) %s\n', i, materialNames{i});
end
fprintf('%d) 🔙 Return to Main Menu\n', length(materialNames) + 1);

% ✅ User selects a material
materialChoice = input('Select a material: ', 's');
materialIndex = str2double(materialChoice);

if isnan(materialIndex) || materialIndex < 1 || materialIndex > (length(materialNames) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

% ✅ If user selects the last option, return to `main_menu.m`
if materialIndex == length(materialNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

% ✅ Load selected material
materialName = materialNames{materialIndex};
disp(['✅ Selected Material: ', materialName]);
material = TFG_Amora.materials.(materialName);

%% 🔹 Step 6: Run Pre-Dimensioning
disp('⚙️ Running Pre-Dimensioning for Selected Aircraft and Material...');

% ✅ Use the structural reference axis as the spanwise position
x = avion.forces.R_i.eje(:,1);  % Spanwise positions from the structural reference axis
My = avion.forces.My;  % Bending moment about y-axis
Vy = avion.forces.V.rear + avion.forces.V.front;  % Total shear force
T = avion.forces.T;  % Torsional moment
geom = avion.geometria;
datosEstructural = avion.datosEstructural;

% ✅ Fetch Safety Factor from `datosEstructural`
SF = avion.datosEstructural.SF;

% ✅ Run pre-dimensioning with SF
structure = pre_dimensioning_graph(My, Vy, T, x, material, SF, geom, datosEstructural);

% ✅ Save the computed structural parameters
TFG_Amora.aviones.(name).structure = structure;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

disp('✅ Structural Pre-Dimensioning Completed and Saved.');
