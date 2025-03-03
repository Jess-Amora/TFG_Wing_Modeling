clear all;
addpath('./4. Generate FEA Structure');

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

avionChoice = input('Select an option: ', 's');
avionIndex = str2double(avionChoice);

if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if avionIndex == length(avionNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main.m');
    return;
end

name = avionNames{avionIndex}; 
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Check if `avion.perfil` Exists (Airfoil Definition)
if ~isfield(avion, 'perfil')
    disp('⚠️ This aircraft does not have an airfoil defined.');
    disp('➡️ Please return to Stage 3 to create your wing airfoil.');
    return;
end
disp('✅ Airfoil profile found. Proceeding to next step...');

%% 🔹 Step 4: Select Processing Mode (Generate Structure or Write BDF)
disp('----------------------------------------');
disp('📌 Select an Action:');
disp('1) 🏗 Generate Full Structure (Takes Time)');
disp('2) 📄 Write Only BDF Files (Faster, if structure exists)');
disp('3) 🔙 Return to Main Menu');

actionChoice = input('Select an option: ', 's');
actionIndex = str2double(actionChoice);

if isnan(actionIndex) || actionIndex < 1 || actionIndex > 3
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if actionIndex == 3
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end



%% 🔹 Step 6: Extract Required Inputs for `generate_structure`
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

%% 🔹 Step 7: Handle User's Choice (Generate Structure or Write BDF)
if actionIndex == 1
    %% 🏗 Generate Structure
    disp('🚀 Starting Full Structure Generation...');
    
    % ✅ Select Structure Generation Method Folder
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

    folderChoice = input('Select a structure generation method folder: ', 's');
    folderIndex = str2double(folderChoice);

    if isnan(folderIndex) || folderIndex < 1 || folderIndex > (length(methodFolders) + 1)
        disp('❌ Invalid selection. Returning to menu.');
        return;
    end

    if folderIndex == length(methodFolders) + 1
        disp('🔙 Returning to Main Menu...');
        run('main.m');
        return;
    end

    selectedFolder = fullfile(baseFolder, methodFolders(folderIndex).name);
    disp(['🛠 Using structure generation methods from folder: ', methodFolders(folderIndex).name]);
    addpath(selectedFolder);

    generateStructurePath = fullfile(selectedFolder, 'generate_structure.m');

    if exist(generateStructurePath, 'file')
        disp(['🚀 Running generate_structure from ', methodFolders(folderIndex).name, '...']);
        elements = generate_structure(avion);
        TFG_Amora.aviones.(name).elements = elements;
        save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
        disp(['✅ Structure generation completed using ', methodFolders(folderIndex).name, ' and saved.']);
    else
        disp('❌ Error: generate_structure.m not found in the selected folder.');
    end
    
    rmpath(selectedFolder);

else
    %% 🔹 Step 5: User Selects Pre-Dimensioned Configuration
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
        
        % ✅ Select Structure Generation Method Folder
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
    
        folderChoice = input('Select a structure generation method folder: ', 's');
        folderIndex = str2double(folderChoice);
    
        if isnan(folderIndex) || folderIndex < 1 || folderIndex > (length(methodFolders) + 1)
            disp('❌ Invalid selection. Returning to menu.');
            return;
        end
    
        if folderIndex == length(methodFolders) + 1
            disp('🔙 Returning to Main Menu...');
            run('main.m');
            return;
        end
    
        selectedFolder = fullfile(baseFolder, methodFolders(folderIndex).name);
        disp(['🛠 Using structure generation methods from folder: ', methodFolders(folderIndex).name]);
        addpath(selectedFolder);
    
        generateStructurePath = fullfile(selectedFolder, 'main_write_structure.m');
    
        if exist(generateStructurePath, 'file')
            disp(['🚀 Running generate_structure from ', methodFolders(folderIndex).name, '...']);

            main_write_structure(avion,selectedPredim,database_computer);
            save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
            disp(['✅ Structure generation completed using ', methodFolders(folderIndex).name, ' and saved.']);
        else
            disp('❌ Error: main_write_structure.m not found in the selected folder.');
        end
        
        

        %% 📄 Write BDF Files
        disp('✅ Writing BDF files...');
        
    
        rmpath(selectedFolder);
    disp('✅ BDF files successfully written.');
end
