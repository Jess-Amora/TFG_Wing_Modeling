clear all;
addpath('./3. Strength Analysis');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

while true  % 🔁 Keep menu active until user exits

    %% 🔹 Step 2: Select Aircraft
    disp('----------------------------------------');
    disp('✏️  Edit Aircraft Data:');
    avionNames = fieldnames(TFG_Amora.aviones);

    if isempty(avionNames)
        disp('⚠️ No aircraft data available. Please add aircraft first.');
        return;
    end

    % ✅ Display available aircraft options
    for i = 1:length(avionNames)
        fprintf('%d) %s\n', i, avionNames{i});
    end
    fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);

    % ✅ User selects an aircraft
    avionChoice = input('Select an aircraft to edit: ', 's');
    avionIndex = str2double(avionChoice);

    if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
        disp('❌ Invalid selection. Try again.');
        continue;
    end

    if avionIndex == length(avionNames) + 1
        disp('🔙 Returning to Main Menu...');
        run('main_menu.m');
        return;
    end

    % ✅ Load selected aircraft
    name = avionNames{avionIndex};
    disp(['✅ Editing Aircraft: ', name]);
    avion = TFG_Amora.aviones.(name);

    %% 🔹 Step 3: Choose Edit Mode
    while true  % 🔁 Keep edit menu active
        disp('----------------------------------------');
        disp('🛠  Edit Aircraft Data');
        disp('1) Add New Field');
        disp('2) Modify Existing Field');
        disp('3) Edit Structural Parts');
        disp('4) 🔙 Return to Aircraft Selection');

        editChoice = input('Select an option: ', 's');
        editIndex = str2double(editChoice);

        if isnan(editIndex) || editIndex < 1 || editIndex > 4
            disp('❌ Invalid selection. Try again.');
            continue;
        end

        if editIndex == 4
            break;  % 🔙 Return to aircraft selection
        end

        %% 🔹 Step 4: Execute Selected Edit Mode
        if editIndex == 1
            % ✅ Add New Field
            newField = input('Enter new field name: ', 's');
            newValue = input(['Enter value for "', newField, '": '], 's');

            % ✅ Save as string or numeric
            if isnan(str2double(newValue))
                avion.(newField) = newValue; % Save as text
            else
                avion.(newField) = str2double(newValue); % Save as number
            end
            disp(['✅ New field "', newField, '" added.']);

        elseif editIndex == 2
            % ✅ Modify Existing Field
            existingFields = fieldnames(avion);
            disp('Available Fields:');
            for i = 1:length(existingFields)
                fprintf('%d) %s\n', i, existingFields{i});
            end
            fieldChoice = input('Select a field to modify: ', 's');
            fieldIndex = str2double(fieldChoice);

            if isnan(fieldIndex) || fieldIndex < 1 || fieldIndex > length(existingFields)
                disp('❌ Invalid selection.');
                continue;
            end

            selectedField = existingFields{fieldIndex};
            disp(['🔄 Modifying "', selectedField, '"']);
            newValue = input(['Enter new value for "', selectedField, '": '], 's');

            if isnan(str2double(newValue))
                avion.(selectedField) = newValue;
            else
                avion.(selectedField) = str2double(newValue);
            end
            disp(['✅ Field "', selectedField, '" updated.']);

        elseif editIndex == 3
            % ✅ Modify Structural Parts
            while true
                disp('----------------------------------------');
                disp('🛠  Edit Structural Parts');
                disp('1) Modify Cordon');
                disp('2) Modify Larguerillo');
                disp('3) Modify Cajón');
                disp('4) 🔙 Return');

                partChoice = input('Select a structural part to modify: ', 's');
                partIndex = str2double(partChoice);

                if isnan(partIndex) || partIndex < 1 || partIndex > 4
                    disp('❌ Invalid selection. Try again.');
                    continue;
                end

                if partIndex == 4
                    break;
                end

                % ✅ Select which structural part to edit
                if partIndex == 1
                    partType = 'cordon';
                elseif partIndex == 2
                    partType = 'larguerillo';
                elseif partIndex == 3
                    partType = 'cajon';
                end

                if ~isfield(TFG_Amora.parts, partType) || isempty(fieldnames(TFG_Amora.parts.(partType)))
                    disp(['❌ No ', partType, 's available.']);
                    continue;
                end

                partNames = fieldnames(TFG_Amora.parts.(partType));
                disp(['Available ', partType, 's:']);
                for i = 1:length(partNames)
                    fprintf('%d) %s\n', i, partNames{i});
                end

                partChoice = input(['Select ', partType, ' to modify: '], 's');
                partIndex = str2double(partChoice);

                if isnan(partIndex) || partIndex < 1 || partIndex > length(partNames)
                    disp('❌ Invalid selection.');
                    continue;
                end

                selectedPart = partNames{partIndex};
                disp(['🔄 Modifying "', selectedPart, '" in ', partType]);

                % ✅ Modify values
                partFields = fieldnames(TFG_Amora.parts.(partType).(selectedPart));
                disp('Available Fields:');
                for i = 1:length(partFields)
                    fprintf('%d) %s\n', i, partFields{i});
                end

                fieldChoice = input('Select a field to modify: ', 's');
                fieldIndex = str2double(fieldChoice);

                if isnan(fieldIndex) || fieldIndex < 1 || fieldIndex > length(partFields)
                    disp('❌ Invalid selection.');
                    continue;
                end

                selectedField = partFields{fieldIndex};
                newValue = input(['Enter new value for "', selectedField, '": '], 's');

                if isnan(str2double(newValue))
                    TFG_Amora.parts.(partType).(selectedPart).(selectedField) = newValue;
                else
                    TFG_Amora.parts.(partType).(selectedPart).(selectedField) = str2double(newValue);
                end
                disp(['✅ ', partType, ' "', selectedPart, '" updated.']);
            end
        end

        % ✅ Save changes
        TFG_Amora.aviones.(name) = avion;
        save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
        disp('✅ Changes saved successfully.');
    end
end
