clc; clear;
% addpath('./shared');
% addpath('./wing_builder');
% addpath('./fuselage_builder');
addpath('./1. Database');
addpath('./2. Geometric wing and forces');
addpath('./3. Strength Analysis');

disp('----------------------------------------');
disp('✈️  Aircraft Structural Analysis System');
disp('----------------------------------------');

% ✅ Define the project root (Modify if needed)
projectRoot = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
databasePath = fullfile(projectRoot, 'Data', 'TFG_Amora.mat');

% ✅ Step 1: Load or Initialize Database
if isfile(databasePath)
    load(databasePath, 'TFG_Amora');
    disp('✅ Database loaded.');
else
    warning('⚠️ No existing database found. Creating a new one.');
    TFG_Amora = struct();
    TFG_Amora.datosEstructural = struct();
    TFG_Amora.aircraft_data = struct();
    TFG_Amora.aviones = struct();
end

% ✅ Step 2: Menu Selection
while true
    disp('----------------------------------------');
    disp('📌 **Main System Menu**');
    disp('1️⃣  Manage Database (Materials, Aircraft, Structural Data)');
    disp('2️⃣  Generate Wing Geometry & Compute Forces');
    disp('3️⃣  Strength Analysis (Validate Materials & Loads)');
    disp('4️⃣  Generate FEA Structure for Patran/Nastran');
    disp('5️⃣  Validate FEM Results');
    disp('6️⃣  Edit avion');
    disp('7  Exit');
    
    choice = input('Enter your choice (1-6): ', 's');

    switch choice
        case '1'  % 📂 **Manage Database**
            disp('🔄 Opening Database Management System...');
            main_database;  % Calls `main_database.m`

        case '2'  % 🛩 **Generate Wing & Compute Forces**
            disp('🛩 Generating Wing Geometry & Computing Forces...');
            main_generate_wing_forces;  % Calls `main_generate_wing_forces.m`

        case '3'  % ⚖️ **Strength Analysis**
            disp('⚖️ Running Strength Analysis...');
            main_strength_analysis;  % Calls `main_strength_analysis.m`

        case '4'  % 🏗 **Generate FEA Structure**
            disp('🏗 Generating FEA Structure...');
            main_generate_FEA_structure;  % Calls `main_generate_FEA_structure.m`

        case '5'  % ✅ **Validate FEM Results**
            disp('📊 Running FEM Validation...');
            main_validation;  % Calls `main_validation.m`
        case '6'  % ✏️ **Edit Aircraft Data**
            disp('✏️ Opening Aircraft Editing Menu...');
            save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');  % 💾 Ensure data is saved before editing
            run('main_edit.m');  % 🔁 Run the editing menu instead of exiting
        case '7'  % ❌ **Exit**
            disp('👋 Exiting the system. See you next time!');
            save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
            disp('💾 Database saved.');
            break;

        otherwise
            warning('❌ Invalid selection. Please enter a number between 1 and 6.');
    end
end
