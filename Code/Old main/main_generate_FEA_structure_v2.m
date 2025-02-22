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

% ✅ Display available aircraft
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
    run('main_menu.m');
    return;
end

% ✅ Load selected aircraft
name = avionNames{avionIndex}; % Selected aircraft name
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: User Selects Pre-Dimensioned Configuration
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

% ✅ If user selects the last option, return to `main_menu.m`
if predimIndex == length(predimNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

% ✅ Load the selected pre-dimensioned case
selectedPredim = predimNames{predimIndex}; % Selected pre-dimensioning
disp(['✅ Selected Pre-Dimensioned Case: ', selectedPredim]);
predimData = avion.predimensionado.(selectedPredim);

%% 🔹 Step 4: Select a Structure Generation Method Folder
disp('🏗  Select Structure Generation Method Folder:');

% ✅ Define the base directory for FEA structure generation
baseFolder = fullfile(database_computer, "Code", "4. Generate FEA Structure");

% ✅ Get the list of available method folders
methodFolders = dir(baseFolder);
methodFolders = methodFolders([methodFolders.isdir]); % Keep only directories
methodFolders = methodFolders(~ismember({methodFolders.name}, {'.', '..'})); % Remove system folders

% ✅ Display available folders
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

% ✅ If user selects the last option, return to `main_menu.m`
if folderIndex == length(methodFolders) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

% ✅ Get the selected folder path
selectedFolder = fullfile(baseFolder, methodFolders(folderIndex).name);
disp(['🛠 Using structure generation methods from folder: ', methodFolders(folderIndex).name]);

% ✅ Add the selected folder to MATLAB's path
addpath(selectedFolder);

%% 🔹 Step 5: Find and Execute `generate_structure.m`
generateStructurePath = fullfile(selectedFolder, 'generate_structure.m');

if exist(generateStructurePath, 'file')
    disp(['🚀 Running generate_structure from ', methodFolders(folderIndex).name, '...']);
    
    % ✅ Call the function with required inputs
    structureData = generate_structure(avion, predimData);
    
    % ✅ Save structure results
    TFG_Amora.aviones.(name).estructura = structureData;
    save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
    disp(['✅ Structure generation completed using ', methodFolders(folderIndex).name, ' and saved.']);
else
    disp('❌ Error: generate_structure.m not found in the selected folder.');
end

% ✅ Remove folder from path after execution to avoid conflicts
rmpath(selectedFolder);
