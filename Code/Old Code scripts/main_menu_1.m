clc; clear;
disp('----------------------------------------');
disp('✈️  Aircraft Structural Analysis System');
disp('----------------------------------------');

% Define the project root (Modify if needed)
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
    disp('📌 **Select an Option:**');
    disp('1️⃣  Read Database (Load structural and aircraft data from CSV)');
    disp('2️⃣  Input Data (Manually add structural and aircraft data)');
    disp('3️⃣  Select Aircraft to Generate Wing');
    disp('4️⃣  Exit');
    choice = input('Enter your choice (1-4): ', 's');

    switch choice
        case '1' % 📂 **Read Database**
            disp('🔄 Loading structural parameters and aircraft data...');
            read_database(projectRoot);
            disp('✅ Database successfully updated.');

        case '2' % ✏️ **Input Data**
            disp('✏️ Redirecting to Manual Data Input...');
            main_database; % Calls the existing main script

        case '3' % 🛩 **Select Aircraft to Generate Wing**
            disp('🛩 Selecting an Aircraft for Wing Generation...');
            
            % ✅ Step 1: Check if there are saved aircraft
            aircraftNames = fieldnames(TFG_Amora.aviones);
            if isempty(aircraftNames)
                warning('⚠️ No aircraft data available. Please input aircraft data first.');
                continue;
            end

            % ✅ Step 2: Display available aircraft
            disp('Available Aircraft:');
            for i = 1:length(aircraftNames)
                fprintf('%d) %s\n', i, aircraftNames{i});
            end

            % ✅ Step 3: User selects an aircraft
            aircraftChoice = input('Select an aircraft by number: ', 's');
            aircraftIndex = str2double(aircraftChoice);

            if isnan(aircraftIndex) || aircraftIndex < 1 || aircraftIndex > length(aircraftNames)
                warning('❌ Invalid selection. Please try again.');
                continue;
            end

            selectedAircraft = aircraftNames{aircraftIndex};
            avion = TFG_Amora.aviones.(selectedAircraft);
            disp(['✅ Selected Aircraft: ', selectedAircraft]);

            % ✅ Step 4: Generate Wing
            disp('✈️  Generating Wing...');
            results = generate_wing_v7(avion);
            disp('✅ Wing Generation Complete.');

        case '4' % ❌ **Exit**
            disp('👋 Exiting the system. See you next time!');
            break;

        otherwise
            warning('❌ Invalid selection. Please enter a number between 1 and 4.');
    end
end

% ✅ Save any modifications to the database
save(databasePath, 'TFG_Amora');
disp('💾 Database saved.');
