clear all;
addpath('./2. Geometric wing and forces');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

%% 🔹 Step 2: User Selects Aircraft Structural Data or Returns to Main Menu
disp('----------------------------------------');
disp('🛩 Select an Aircraft-Structural Data to Process:');
avionNames = fieldnames(TFG_Amora.aviones);

if isempty(avionNames)
    disp('⚠️ No aircraft-structural data available. Please add data first.');
    return;
end

for i = 1:length(avionNames)
    fprintf('%d) %s\n', i, avionNames{i});
end
fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);

avionChoice = input('Select an option: ', 's');
avionIndex = str2double(avionChoice);

if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if avionIndex == length(avionNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

name = avionNames{avionIndex}; 
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Compute Aerodynamic Forces (Cargas)
disp('⚖️  Computing aerodynamic forces using Schrenk method...');
cargas = schrenk_1(avion);
TFG_Amora.aviones.(name).cargas = cargas;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
disp('✅ Cargas computed and saved.');

%% 🔹 Step 4: Select a Wing & Fuselage Construction Method Folder (Only Once!)
disp('✈️  Select Wing & Fuselage Construction Method Folder:');

baseFolder = fullfile(database_computer, "Code", "2. Geometric wing and forces");
methodFolders = dir(baseFolder);
methodFolders = methodFolders([methodFolders.isdir]); 
methodFolders = methodFolders(~ismember({methodFolders.name}, {'.', '..'})); 

if isempty(methodFolders)
    disp('⚠️ No wing construction methods available.');
    return;
end

for i = 1:length(methodFolders)
    fprintf('%d) %s\n', i, methodFolders(i).name);
end
fprintf('%d) 🔙 Return to Main Menu\n', length(methodFolders) + 1);

folderChoice = input('Select a wing construction method folder: ', 's');
folderIndex = str2double(folderChoice);

if isnan(folderIndex) || folderIndex < 1 || folderIndex > (length(methodFolders) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if folderIndex == length(methodFolders) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

selectedFolder = fullfile(baseFolder, methodFolders(folderIndex).name);
disp(['🛠 Using methods from folder: ', methodFolders(folderIndex).name]);

addpath(selectedFolder);

%% 🔹 Step 5: Execute `construirAla.m` (Only Once)
construirAlaPath = fullfile(selectedFolder, 'construirAla.m');

if exist(construirAlaPath, 'file')
    disp(['🚀 Running construirAla from ', methodFolders(folderIndex).name, '...']);
    ala = construirAla(avion, avion.datosEstructural, cargas);
    
    TFG_Amora.aviones.(name).ala = ala;
    save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    disp(['✅ Wing construction completed using ', methodFolders(folderIndex).name, ' and saved.']);
else
    disp('❌ Error: construirAla.m not found in the selected folder.');
    ala = []; % Ensure we don't pass an undefined variable to fuselage construction
end

%% 🔹 Step 6: Execute `construir_fuselaje.m` (Uses the Same `selectedFolder`)
construirFuselajePath = fullfile(selectedFolder, 'construir_fuselaje.m');

if exist(construirFuselajePath, 'file') && ~isempty(ala)
    disp(['🚀 Running construir_fuselaje from ', methodFolders(folderIndex).name, '...']);
    fuselaje = construir_fuselaje(avion, avion.datosEstructural, ala);
    
    TFG_Amora.aviones.(name).fuselaje = fuselaje;
    save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    disp(['✅ Fuselage construction completed using ', methodFolders(folderIndex).name, ' and saved.']);
else
    disp('❌ Error: construir_fuselaje.m not found in the selected folder or wing construction failed.');
end

% ✅ Remove folder from path after execution to avoid conflicts


%% 🔹 Step 7: Compute Final Forces & Adjust `k_sust`
disp('🛠 Adjusting k_sust for Final Forces...');

rib_prop = generate_rib_properties(ala.mesh.nodos_anterior', ala.mesh.nodos_posterior', avion.perfil.airfoil);
avion.datosEstructural.k_i = 1;

% n = 1
n1 = 1;
[avion, cargas, results_k] = adjust_k_sust_final_forces(ala, avion, n1);

TFG_Amora.aviones.(name).forces_n1 = results_k;
TFG_Amora.aviones.(name).datosEstructural.k_n1 = 1;
TFG_Amora.aviones.(name).datosEstructural.k_n1 = avion.datosEstructural.k_i;
TFG_Amora.aviones.(name).cargas_n1 = cargas;

TFG_Amora.aviones.(name).weight_n1 = calculate_weight_wing_fuel(ala, avion, rib_prop,n1);

% n = n_lim
n_lim = avion.datosEstructural.n;
[avion, cargas, results_k] = adjust_k_sust_final_forces(ala, avion,n_lim );

TFG_Amora.aviones.(name).forces_n_lim = results_k;
TFG_Amora.aviones.(name).datosEstructural.k_n_lim = 1;
TFG_Amora.aviones.(name).datosEstructural.k_n_lim = avion.datosEstructural.k_i;
TFG_Amora.aviones.(name).cargas_n_lim = cargas;

TFG_Amora.aviones.(name).weight_n_lim = calculate_weight_wing_fuel(ala, avion, rib_prop,n_lim);

% n = n_ult
n_ult = 1.5 * avion.datosEstructural.n;
[avion, cargas, results_k] = adjust_k_sust_final_forces(ala, avion, n_ult);

TFG_Amora.aviones.(name).forces_n_ult = results_k;
TFG_Amora.aviones.(name).datosEstructural.k_n_ult = 1;
TFG_Amora.aviones.(name).datosEstructural.k_n_ult = avion.datosEstructural.k_i;
TFG_Amora.aviones.(name).cargas_n_ult = cargas;

TFG_Amora.aviones.(name).weight_n_ult = calculate_weight_wing_fuel(ala, avion, rib_prop, n_ult);

save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

rmpath(selectedFolder);
disp('✅ Final force calculations saved.');
