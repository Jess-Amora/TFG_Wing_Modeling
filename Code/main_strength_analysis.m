clear all;
addpath('./3. Strength Analysis');

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

%% 🔹 Step 3: Check if Forces Exist
if ~isfield(avion, 'forces') || isempty(avion.forces)
    disp('⚠️ No aerodynamic & structural forces detected for this aircraft.');
    disp('2️⃣  Generate Wing Geometry & Compute Forces');
    disp('Returning to main menu...');
    return;
end

%% 🔹 Step 4: User Selects a Material for Pre-Dimensioning
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

%% 🔹 Step 5: Run Pre-Dimensioning
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
% structure = pre_dimensioning(My, Vy, T, x, material, SF, geom);
structure = pre_dimensioning_graph(My, Vy, T, x, material, SF, geom,datosEstructural);

% ✅ Save the computed structural parameters
TFG_Amora.aviones.(name).structure = structure;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

disp('✅ Structural Pre-Dimensioning Completed and Saved.');
