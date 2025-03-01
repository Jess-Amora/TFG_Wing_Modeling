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
        run('main.m');
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
        disp('2) Create Structural Parts (Cajón, Larguerillo, Cordon)');
        disp('3) Create or View NACA Wing');
        disp('4) View Available Structural Parts');
        disp('5) 🔙 Return to Aircraft Selection');

        modeChoice = input('Select an option: ', 's');
        modeIndex = str2double(modeChoice);

        if isnan(modeIndex) || modeIndex < 1 || modeIndex > 5
            disp('❌ Invalid selection. Try again.');
            continue;
        end

        if modeIndex == 5
            break;  % 🔙 Return to aircraft selection
        end

        %% 🔹 Step 4: Execute Selected Mode
        if modeIndex == 1
            % ✅ Run Analysis (Pre-Dimensioning & Strength Analysis)
            disp('----------------------------------------');
            disp('🔩 Select a Material for Pre-Dimensioning:');
            materialNames = fieldnames(TFG_Amora.materials);
            
            if isempty(materialNames)
                disp('⚠️ No material data available. Please add materials first.');
                continue;
            end
            
            % ✅ Display available materials
            for i = 1:length(materialNames)
                fprintf('%d) %s\n', i, materialNames{i});
            end
            fprintf('%d) 🔙 Return to Strength Menu\n', length(materialNames) + 1);
            
            % ✅ User selects a material
            materialChoice = input('Select a material: ', 's');
            materialIndex = str2double(materialChoice);
            
            if isnan(materialIndex) || materialIndex < 1 || materialIndex > (length(materialNames) + 1)
                disp('❌ Invalid selection. Try again.');
                continue;
            end
            
            if materialIndex == length(materialNames) + 1
                continue;
            end
            
            % ✅ Load selected material
            materialName = materialNames{materialIndex};
            disp(['✅ Selected Material: ', materialName]);
            material = TFG_Amora.materials.(materialName);
            
            %% 🔹 Step 6: Ensure Structural Parts Exist Before Running Analysis
            disp('----------------------------------------');
            disp('🛠  Verifying Structural Parts Selection');
            
            % ✅ Select Larguerillo
            larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
            if isempty(larguerilloNames)
                disp('❌ No Larguerillos available. Please create one first.');
                continue;
            end
            
            disp('Available Larguerillos:');
            for i = 1:length(larguerilloNames)
                fprintf('%d) %s\n', i, larguerilloNames{i});
            end
            larguerilloIndex = input('Select a Larguerillo: ');
            if isnan(larguerilloIndex) || larguerilloIndex < 1 || larguerilloIndex > length(larguerilloNames)
                disp('❌ Invalid selection.');
                continue;
            end
            selected_larguerillo = larguerilloNames{larguerilloIndex};
            disp(['✅ Selected Larguerillo: ', selected_larguerillo]);
            
            % ✅ Select Cordon
            cordonNames = fieldnames(TFG_Amora.parts.cordon);
            if isempty(cordonNames)
                disp('❌ No Cordons available. Please create one first.');
                continue;
            end
            
            disp('Available Cordons:');
            for i = 1:length(cordonNames)
                fprintf('%d) %s\n', i, cordonNames{i});
            end
            cordonIndex = input('Select a Cordon: ');
            if isnan(cordonIndex) || cordonIndex < 1 || cordonIndex > length(cordonNames)
                disp('❌ Invalid selection.');
                continue;
            end
            selected_cordon = cordonNames{cordonIndex};
            disp(['✅ Selected Cordon: ', selected_cordon]);
            
            % ✅ Select Cajón
            cajonNames = fieldnames(TFG_Amora.parts.cajon);
            if isempty(cajonNames)
                disp('❌ No Cajón available. Please create one first.');
                continue;
            end
            
            disp('Available Cajóns:');
            for i = 1:length(cajonNames)
                fprintf('%d) %s\n', i, cajonNames{i});
            end
            cajonIndex = input('Select a Cajón: ');
            if isnan(cajonIndex) || cajonIndex < 1 || cajonIndex > length(cajonNames)
                disp('❌ Invalid selection.');
                continue;
            end
            selected_cajon = cajonNames{cajonIndex};
            disp(['✅ Selected Cajón: ', selected_cajon]);
            
            % ✅ Retrieve selected Cajón dimensions correctly
            if isfield(TFG_Amora.parts.cajon, selected_cajon)
                cajon_dims = TFG_Amora.parts.cajon.(selected_cajon);
            else
                error('❌ Selected Cajón "%s" does not exist in the database.', selected_cajon);
            end
            
            %% 🔹 Step 7: Run Pre-Dimensioning
            x = avion.forces.R_i.eje(:,1);  % Spanwise positions
            My = avion.forces.My;  
            Vy = avion.forces.V.rear + avion.forces.V.front;  
            T = avion.forces.T;  
            geom = avion.geometria;
            datosEstructural = avion.datosEstructural;
            naca_wing = avion.perfil;
            SF = avion.datosEstructural.SF;
            
            disp('⚙️ Running Pre-Dimensioning for Selected Aircraft and Material...');
            structure = pre_dimensioning_graph(My, Vy, T, x, material, SF, geom, datosEstructural, false);
            
            num_cycles = 1e6; % Default fatigue cycles
            strength_results = strength_analysis(material, datosEstructural, selected_larguerillo, selected_cordon, cajon_dims, naca_wing, My, Vy, T, num_cycles, database_computer);
            plot_strength_results(strength_results);

            % ✅ Ask the user for a name for this pre-dimensioning case
            disp('----------------------------------------');
            disp('📢 Strength Analysis Completed!');
            disp('🔹 Press [Enter] if you do NOT want to save this configuration.');
            predim_name = input('🔹 Or enter a name to save this Pre-Dimensioning configuration: ', 's');
            
            % ✅ If the user just presses Enter, do NOT save anything & return to main_strength_analysis
            if isempty(predim_name)
                disp('❌ Configuration NOT saved. Returning to Strength Analysis Menu...');
                run('main3.m');  % 🔄 Restart Strength Analysis
                return;  % Exit this script
            end
            
            % ✅ Ensure `predimensionado` field exists in `avion`
            if ~isfield(TFG_Amora.aviones.(name), 'predimensionado')
                TFG_Amora.aviones.(name).predimensionado = struct();  % Create empty struct
            end
            
            % ✅ Check if this name already exists
            if isfield(TFG_Amora.aviones.(name).predimensionado, predim_name)
                overwrite_choice = input('⚠️ This name already exists. Overwrite it? (y/n): ', 's');
                if ~strcmpi(overwrite_choice, 'y')
                    disp('❌ Configuration not saved. Returning to Strength Analysis Menu...');
                    run('main_strength_analysis.m');  % 🔄 Restart Strength Analysis
                    return; % Exit this script
                end
            end
            
            % ✅ Save the pre-dimensioned structure inside `avion.predimensionado`
            TFG_Amora.aviones.(name).predimensionado.(predim_name) = struct( ...
                'material', materialName, ...
                'larguerillo', selected_larguerillo, ...
                'cordon', selected_cordon, ...
                'cajon', selected_cajon, ...
                'strength_results', strength_results, ...
                'structure', structure ...
            );
            
            % ✅ Save the computed structural parameters in the database
            save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
            
            disp(['✅ Configuration "', predim_name, '" saved successfully for the next stage (generate_structure).']);
            
            % ✅ Return to Strength Analysis Menu
            run('main3.m');  % 🔄 Restart Strength Analysis


        elseif modeIndex == 2
            % ✅ Run Create Parts Menu (Cajón, Larguerillo, Cordon)
            while true  % 🔁 Keep Create Parts menu active
                disp('----------------------------------------');
                disp('🛠  Structural Parts Creation');
                disp('1) Create Cordon');
                disp('2) Create Larguerillo');
                disp('3) Create Cajón');
                disp('4) 🔙 Return');

                partChoice = input('Select an option: ', 's');
                partIndex = str2double(partChoice);

                if isnan(partIndex) || partIndex < 1 || partIndex > 4
                    disp('❌ Invalid selection. Try again.');
                    continue;
                end

                if partIndex == 4
                    break;
                end

                add_structural_parts(partIndex, database_computer, avion);
                save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
                disp('✅ Structural part creation completed and saved.');
            end
        
        elseif modeIndex == 3
           z

        elseif modeIndex == 4
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
