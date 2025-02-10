function TFG_Amora = addAircraftData(name, MTOW, Superficie, flecha_radian, b, Lf, c1, c2, datosEstructural_name, datosEstructural)
    % ===========================================================
    % 📌 Function: addAircraftData
    % ===========================================================
    % Adds a new aircraft entry to the TFG_Amora database.
    % 
    % Inputs:
    % - name: Unique identifier for the aircraft.
    % - MTOW: Maximum Take-Off Weight (kg).
    % - Superficie: Wing area (m²).
    % - flecha_radian: Wing sweep angle in radians.
    % - b: Wingspan (meters).
    % - Lf: Half fuselage length (meters).
    % - c1: Root chord length (meters).
    % - c2: Tip chord length (meters).
    % - datosEstructural_name: Name of the selected structural dataset.
    % - datosEstructural: Struct containing wing structural parameters.
    %
    % The function first checks whether the aircraft already exists.
    % If it does, it prompts the user for overwrite confirmation.
    % The updated structure is saved immediately.
    % ===========================================================

    % Extract project root from datosEstructural
    if isfield(datosEstructural, 'projectRoot')
        projectRoot = datosEstructural.projectRoot;
    else
        error('❌ projectRoot is missing in datosEstructural. Ensure it was set in add_datosEstructural.');
    end

    % Define database file path
    databasePath = fullfile(projectRoot, 'Data', 'TFG_Amora.mat');

    % ✅ Ensure fullAircraftName is always a char vector
    fullAircraftName = strcat(name, '_', datosEstructural_name); % Convert to char

    % Define results folder path
    resultsFolder = fullfile(projectRoot, 'Results', fullAircraftName);

    % Load existing database if it exists
    if isfile(databasePath)
        load(databasePath, 'TFG_Amora');
    else
        warning('⚠️ Database does not exist. Creating a new one.');
        TFG_Amora = struct(); % Create empty struct
    end

    % Check if aircraft already exists
    if isfield(TFG_Amora, 'aviones') && isfield(TFG_Amora.aviones, fullAircraftName)
        warning('⚠️ Aircraft "%s" already exists.', fullAircraftName);
        userChoice = input('Do you want to overwrite it? (y/n): ', 's');
        if lower(userChoice) ~= 'y'
            disp('Operation canceled. Data was NOT modified.');
            return;
        end
    end

    % Store aircraft data
    aircraft.MTOW = MTOW;  % Maximum Take-Off Weight
    aircraft.superficie = Superficie;  % Wing area
    aircraft.geometria.flecha_radian = flecha_radian;  % Sweep angle
    aircraft.geometria.b = b;  % Wingspan
    aircraft.geometria.Lf = Lf / 2;  % Adjusted half fuselage length
    aircraft.geometria.c1 = c1;  % Root chord
    aircraft.geometria.c2 = c2;  % Tip chord
    aircraft.geometria.Lw = b / 2 - (Lf / 2);  % Semi-wing span excluding fuselage
    
    % Assign datosEstructural
    aircraft.datosEstructural_name = datosEstructural_name;
    aircraft.datosEstructural = datosEstructural;

    % ✅ Save into database under the new name
    TFG_Amora.aviones.(fullAircraftName) = aircraft;

    % Save the updated struct
    save(databasePath, 'TFG_Amora');

    % Create the results folder for the aircraft
    if ~isfolder(resultsFolder)
        mkdir(resultsFolder);
        disp(['✅ Created results folder: ', resultsFolder]);
    else
        disp(['ℹ️ Results folder already exists: ', resultsFolder]);
    end

    fprintf('✅ Aircraft "%s" successfully added/updated in the database.\n', fullAircraftName);
end

%% ================================================
% 📌 **Detailed Explanation of `addAircraftData`**
% ================================================
%
% **Purpose:**
% This function adds a new aircraft entry (`avion`) to the TFG_Amora 
% database. It includes aerodynamic and geometric parameters required 
% for structural and aerodynamic analysis.
%
% **Input Parameters:**
% - `MTOW`: Maximum Take-Off Weight of the aircraft in kilograms.
% - `Superficie`: Wing reference area in square meters.
% - `flecha_radian`: Wing sweep angle in radians, measured at 25% chord.
% - `b`: Wingspan of the aircraft (meters).
% - `Lf`: Fuselage length (meters). The function stores **half of this value**.
% - `c1`: Chord length at the wing root (meters).
% - `c2`: Chord length at the wing tip (meters).
% - `datosEstructural_name`: The name of the selected `datosEstructural` set.
% - `datosEstructural`: Struct containing detailed wing structural parameters.
%
% **Workflow:**
% 1️⃣ **Extract the `projectRoot` from `datosEstructural`**  
% - Ensures consistency in file storage and avoids redundant inputs.  
% - If `projectRoot` is missing, the function throws an error.  
%
% 2️⃣ **Define and Load the Database (`TFG_Amora.mat`)**  
% - If the database exists, it loads the previous dataset.  
% - If not, a new struct is initialized.  
%
% 3️⃣ **Check for Existing Aircraft Entries**  
% - If the aircraft already exists, the user is asked if they want to overwrite it.  
% - If the user declines, the function exits without making changes.  
%
% 4️⃣ **Calculate and Store Aircraft Geometry**  
% - The function computes `Lf/2` to adjust the fuselage length.  
% - The effective **semi-wing span** (`Lw`) is calculated by removing the fuselage section.  
% - All geometry variables are stored in the `geometria` struct.  
%
% 5️⃣ **Save the Aircraft into the Database**  
% - The new aircraft entry is stored in `TFG_Amora.aviones` under the name:  
%   ```
%   fullAircraftName = [name, '_', datosEstructural_name]
%   ```
% - This ensures that different configurations of the same aircraft model  
%   (e.g., different structural properties) can coexist without overwriting each other.  
%
% 6️⃣ **Create a Results Folder for the Aircraft**  
% - If the folder doesn’t exist, it is created inside `Results/`.  
% - If it already exists, the function skips creation.  
%
% **Modification Notes:**
% - If additional geometric parameters are needed (e.g., aspect ratio,  
%   taper ratio), they should be computed and stored inside `aircraft.geometria`.
% - If `projectRoot` is changed, ensure all scripts referencing it are updated.
%
% **Future Improvements:**
% - Implement automatic validation of input values (e.g., `b > c1 > c2`).
% - Extend the function to support multiple wing configurations.
%
% ================================================
