clear all;
addpath('./3. Strength Analysis');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

while true  % 🔁 Keep the menu active until the user exits

    %% 🔹 Step 2: User Selects Aircraft
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

    %% 🔹 Step 3: Select Mode (Analysis, Create Parts, or View Parts)
    while true  % 🔁 Keep the mode selection loop active
        disp('----------------------------------------');
        disp('🔍 Strength Analysis & Structural Parts');
        disp('1) Analysis (Pre-Dimensioning & Strength Analysis)');
        disp('2) Create Parts (Cajón, Larguerillo, Cordon, NACA Wing)');
        disp('3) View Available Structural Parts');
        disp('4) 🔙 Return to Aircraft Selection');

        modeChoice = input('Select an option: ', 's');
        modeIndex = str2double(modeChoice);

        if isnan(modeIndex) || modeIndex < 1 || modeIndex > 4
            disp('❌ Invalid selection. Try again.');
            continue;
        end

        if modeIndex == 4
            break;  % 🔙 Return to aircraft selection
        end

        %% 🔹 Step 4: Execute Selected Mode
        if modeIndex == 1
            % ✅ Run Analysis (Pre-Dimensioning & Strength Analysis)
            run('strength_analysis.m');

        elseif modeIndex == 2
            % ✅ Run Create Parts Menu
            while true  % 🔁 Keep Create Parts menu active
                disp('----------------------------------------');
                disp('🛠  Structural Parts Creation');
                disp('1) Create Cordon');
                disp('2) Create Larguerillo');
                disp('3) Create Cajón');
                disp('4) Create NACA Wing');
                disp('5) 🔙 Return');
                
                partChoice = input('Select an option: ', 's');
                partIndex = str2double(partChoice);

                if isnan(partIndex) || partIndex < 1 || partIndex > 5
                    disp('❌ Invalid selection. Try again.');
                    continue;
                end

                if partIndex == 5
                    break;
                end

                add_structural_parts(partIndex, database_computer, avion);
                save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
                disp('✅ Structural part creation completed and saved.');
            end
        
        elseif modeIndex == 3
            % ✅ View Available Structural Parts
            disp('----------------------------------------');
            disp('📊 Available Structural Components for This Aircraft:');

            % ✅ Check for existing Cordon
            if isfield(TFG_Amora.parts, 'cordon') && ~isempty(fieldnames(TFG_Amora.parts.cordon))
                disp('🔹 Available Cordones:');
                cordonNames = fieldnames(TFG_Amora.parts.cordon);
                for i = 1:length(cordonNames)
                    fprintf('%d) %s\n', i, cordonNames{i});
                end
            else
                disp('❌ No Cordones available.');
            end

            % ✅ Check for existing Larguerillo
            if isfield(TFG_Amora.parts, 'larguerillo') && ~isempty(fieldnames(TFG_Amora.parts.larguerillo))
                disp('🔹 Available Larguerillos:');
                larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
                for i = 1:length(larguerilloNames)
                    fprintf('%d) %s\n', i, larguerilloNames{i});
                end
            else
                disp('❌ No Larguerillos available.');
            end

            % ✅ Check for existing Cajón
            if isfield(TFG_Amora.parts, 'cajon') && ~isempty(fieldnames(TFG_Amora.parts.cajon))
                disp('🔹 Available Cajóns:');
                cajonNames = fieldnames(TFG_Amora.parts.cajon);
                for i = 1:length(cajonNames)
                    fprintf('%d) %s\n', i, cajonNames{i});
                end
            else
                disp('❌ No Cajóns available.');
            end

            disp('----------------------------------------');
            input('Press Enter to return to the main menu...');
        end
    end
end
