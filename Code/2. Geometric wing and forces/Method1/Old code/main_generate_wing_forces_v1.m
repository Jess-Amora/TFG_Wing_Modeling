clear all;
addpath('./3. Strength Analysis');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_amora.mat'), 'TFG_Amora');

%% 🔹 Step 2: User Selects Aircraft Structural Data or Returns to Main Menu
disp('----------------------------------------');
disp('🛩 Select an Aircraft-Structural Data to Process:');
avionNames = fieldnames(TFG_Amora.aviones);

if isempty(avionNames)
    disp('⚠️ No aircraft-structural data available. Please add data first.');
    return;
end

% ✅ Display available aircraft-structural data
for i = 1:length(avionNames)
    fprintf('%d) %s\n', i, avionNames{i});
end
fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);

% ✅ User selects an option
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

% ✅ Load selected aircraft-structural data
name = avionNames{avionIndex}; % Selected aircraft name
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Compute Aerodynamic Forces (Cargas)
disp('⚖️  Computing aerodynamic forces using Schrenk method...');
cargas = schrenk_1(avion);
TFG_Amora.aviones.(name).cargas = cargas;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
disp('✅ Cargas computed and saved.');

%% 🔹 Step 4: Construct Wing Geometry (`ala`)
disp('✈️  Constructing Wing Geometry...');
ala = construirAla(avion, avion.datosEstructural, cargas);
TFG_Amora.aviones.(name).ala = ala;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
disp('✅ Wing construction completed and saved.');

%% 🔹 Step 5: Construct Fuselage
disp('🚀 Constructing Fuselage...');
fuselaje = construir_fuselaje(avion, avion.datosEstructural, ala);
TFG_Amora.aviones.(name).fuselaje = fuselaje;
save(data_path, 'TFG_Amora');
disp('✅ Fuselage construction completed and saved.');

%% 🔹 Step 6: Compute Final Forces & Adjust `k_sust`
disp('🛠 Adjusting k_sust for Final Forces...');
[avion, cargas, results_k] = adjust_k_sust_final_forces(ala, avion);

% ✅ Store updated structural data
TFG_Amora.aviones.(name).forces = results_k;  % Store all computed forces
TFG_Amora.aviones.(name).datosEstructural.k_sust_a350_1000 = avion.datosEstructural.k_sust_a350_1000;
TFG_Amora.aviones.(name).cargas = cargas;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
% save(data_path, 'TFG_Amora');
disp('✅ Final force calculations saved.');
