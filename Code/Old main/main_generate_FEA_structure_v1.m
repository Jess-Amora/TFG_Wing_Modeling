clear all;
addpath('./4. Generate FEA Structure');  % Make sure the correct path is set

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

while true  % 🔁 Keep the menu active until the user exits

    %% 🔹 Step 2: User Selects Aircraft
    disp('----------------------------------------');
    disp('🛩 Select an Aircraft for FEA Structure Generation:');
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
        run('main_menu.m');
        return;
    end

    % ✅ Load selected aircraft
    name = avionNames{avionIndex};
    disp(['✅ Selected Aircraft: ', name]);
    avion = TFG_Amora.aviones.(name);

    %% 🔹 Step 3: Select a Pre-Dimensioning Case
    disp('----------------------------------------');
    disp('📊 Select a Pre-Dimensioning Case:');
    
    % ✅ Check if any `predimensionado` cases exist
    if ~isfield(avion, 'predimensionado') || isempty(fieldnames(avion.predimensionado))
        disp('⚠️ No pre-dimensioning data found for this aircraft.');
        disp('🔹 Please run a Strength Analysis first.');
        input('Press Enter to return...');
        continue; % Go back to the aircraft selection menu
    end

    % ✅ Display available pre-dimensioning cases
    predimNames = fieldnames(avion.predimensionado);
    for i = 1:length(predimNames)
        fprintf('%d) %s\n', i, predimNames{i});
    end
    fprintf('%d) 🔙 Return to Aircraft Selection\n', length(predimNames) + 1);

    % ✅ User selects a pre-dimensioning case
    predimChoice = input('Select a Pre-Dimensioning case: ', 's');
    predimIndex = str2double(predimChoice);

    if isnan(predimIndex) || predimIndex < 1 || predimIndex > (length(predimNames) + 1)
        disp('❌ Invalid selection. Returning to menu.');
        continue;
    end

    if predimIndex == length(predimNames) + 1
        continue; % Return to aircraft selection
    end

    % ✅ Load selected pre-dimensioning case
    predim_name = predimNames{predimIndex};
    disp(['✅ Selected Pre-Dimensioning Case: ', predim_name]);

    %% 🔹 Step 4: Select Structure Type
    disp('----------------------------------------');
    disp('📦 Select Structure Type:');
    disp('1) Bare Structure (No Zones)');
    disp('2) Structured with 5 Zones');
    
    structTypeChoice = input('Select a Structure Type: ', 's');
    structTypeIndex = str2double(structTypeChoice);

    if isnan(structTypeIndex) || structTypeIndex < 1 || structTypeIndex > 2
        disp('❌ Invalid selection. Returning to menu.');
        continue;
    end

    if structTypeIndex == 1
        struct_type = 'bare';
        struct_function = @generate_structure_bare;
    else
        struct_type = '5_zone';
        struct_function = @generate_structure_5_zone;
    end

    disp(['✅ Selected Structure Type: ', struct_type]);

    %% 🔹 Step 5: Generate Structure Data
    disp('----------------------------------------');
    generate_data_choice = input('🔹 Do you want to generate the structure data? (y/n): ', 's');

    if strcmpi(generate_data_choice, 'y')
        % ✅ Generate structure data & store in `generate_structure_configuration_xxx`
        struct_name = ['generate_structure_configuration_', datestr(now, 'yyyymmdd_HHMMSS')];

        % ✅ Ensure `generate_structure` field exists
        if ~isfield(avion.predimensionado.(predim_name), 'generate_structure')
            avion.predimensionado.(predim_name).generate_structure = struct();
        end

        % ✅ Compute structure data & save it
        structure_data = struct_function(avion.predimensionado.(predim_name));  % Call appropriate function
        avion.predimensionado.(predim_name).generate_structure.(struct_name) = structure_data;
        
        % ✅ Save database
        TFG_Amora.aviones.(name) = avion;
        save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

        disp(['✅ Structure data "', struct_name, '" generated and saved.']);
    else
        disp('❌ Structure data NOT generated.');
    end

    %% 🔹 Step 6: Export to `.bdf` file
    disp('----------------------------------------');
    export_bdf_choice = input('🔹 Do you want to export the structure to a `.bdf` file? (y/n): ', 's');

    if strcmpi(export_bdf_choice, 'y')
        % ✅ Ask user which structure data to use
        structNames = fieldnames(avion.predimensionado.(predim_name).generate_structure);
        
        if isempty(structNames)
            disp('⚠️ No generated structure data found. Please generate data first.');
            continue;
        end

        disp('📁 Available Structure Configurations:');
        for i = 1:length(structNames)
            fprintf('%d) %s\n', i, structNames{i});
        end
        structIndex = input('Select a Structure Configuration to export: ', 's');
        structIndex = str2double(structIndex);

        if isnan(structIndex) || structIndex < 1 || structIndex > length(structNames)
            disp('❌ Invalid selection. Returning to menu.');
            continue;
        end

        selected_structure = structNames{structIndex};
        disp(['✅ Selected Structure Configuration: ', selected_structure]);

        % ✅ Export to `.bdf`
        structure_data = avion.predimensionado.(predim_name).generate_structure.(selected_structure);
        export_to_bdf(structure_data, database_computer);  % Call function to write `.bdf`
        
        disp(['✅ Structure exported to `.bdf` file.']);
    else
        disp('❌ Export to `.bdf` skipped.');
    end

    % ✅ Return to main menu
    disp('----------------------------------------');
    input('Press Enter to return to Main Menu...');
    run('main_menu.m');
end
