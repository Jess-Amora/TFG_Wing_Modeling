clear all;
addpath('./3. Strength Analysis');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

%% 🔹 Step 2: User Selects Aircraft
disp('----------------------------------------');
disp('🛩 Select an Aircraft to Process:');
avionNames = fieldnames(TFG_Amora.aviones);

if isempty(avionNames)
    disp('⚠️ No aircraft available. Please add data first.');
    return;
end

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

if avionIndex == length(avionNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

name = avionNames{avionIndex}; 
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Load Pre-Dimensioned Configuration
if ~isfield(avion, 'predimensionado') || isempty(fieldnames(avion.predimensionado))
    disp('⚠️ No pre-dimensioned configurations found for this aircraft.');
    return;
end

disp('📐 Select a Pre-Dimensioned Configuration:');
predimNames = fieldnames(avion.predimensionado);

for i = 1:length(predimNames)
    fprintf('%d) %s\n', i, predimNames{i});
end
fprintf('%d) 🔙 Return to Main Menu\n', length(predimNames) + 1);

% ✅ User selects a pre-dimensioned case
predimChoice = input('Select an option: ', 's');
predimIndex = str2double(predimChoice);

if isnan(predimIndex) || predimIndex < 1 || predimIndex > (length(predimNames) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if predimIndex == length(predimNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

selectedPredim = predimNames{predimIndex}; 
disp(['✅ Selected Pre-Dimensioned Case: ', selectedPredim]);
predimData = avion.predimensionado.(selectedPredim);

%% 🔹 Step 4: Extract Required Inputs for `generate_structure`
if isfield(avion, 'datosEstructural')
    datosEstructural = avion.datosEstructural;
else
    disp('⚠️ datosEstructural missing for this aircraft.');
    return;
end

if isfield(avion, 'cargas')
    cargas = avion.cargas;
else
    disp('⚠️ cargas missing for this aircraft.');
    return;
end

if isfield(avion, 'ala')
    ala = avion.ala;
else
    disp('⚠️ ala missing for this aircraft.');
    return;
end

if isfield(avion, 'fuselaje')
    fuselaje = avion.fuselaje;
else
    disp('⚠️ fuselaje missing for this aircraft.');
    return;
end

%% 🔹 Step 5: Select a Structure Generation Method Folder
disp('🏗  Select Structure Generation Method Folder:');

baseFolder = fullfile(database_computer, "Code", "4. Generate FEA Structure");
methodFolders = dir(baseFolder);
methodFolders = methodFolders([methodFolders.isdir]); 
methodFolders = methodFolders(~ismember({methodFolders.name}, {'.', '..'})); 

if isempty(methodFolders)
    disp('⚠️ No structure generation methods available.');
    return;
end

for i = 1:length(methodFolders)
    fprintf('%d) %s\n', i, methodFolders(i).name);
end
fprintf('%d) 🔙 Return to Main Menu\n', length(methodFolders) + 1);

% ✅ User selects a folder
folderChoice = input('Select a structure generation method folder: ', 's');
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
disp(['🛠 Using structure generation methods from folder: ', methodFolders(folderIndex).name]);

% ✅ Add the selected folder to MATLAB's path
addpath(selectedFolder);

%% 🔹 Step 6: Find and Execute `generate_structure.m`
generateStructurePath = fullfile(selectedFolder, 'generate_structure.m');

if exist(generateStructurePath, 'file')
    disp(['🚀 Running generate_structure from ', methodFolders(folderIndex).name, '...']);
    
    % ✅ Call the function with required inputs
    generate_structure(avion, datosEstructural, cargas, ala, fuselaje);
    
    % ✅ Save structure results
    % TFG_Amora.aviones.(name).estructura = structureData;
    % save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    disp(['✅ Structure generation completed using ', methodFolders(folderIndex).name, ' and saved.']);
else
    disp('❌ Error: generate_structure.m not found in the selected folder.');
end

% ✅ Remove folder from path after execution to avoid conflicts
rmpath(selectedFolder);
