function TFG_Amora = addStructuralData(name, ribSpacing, stringerSpacing, sparLocations,numero_de_puntos_en_las_lineas)
    % Function to add structural data to TFG_Amora struct with overwrite warning
    % Inputs:
    %   - TFG_Amora (struct): Main database
    %   - name (string): Aircraft name (must match existing aircraft)
    %   - ribSpacing (m): Distance between ribs
    %   - stringerSpacing (m): Distance between stringers
    %   - sparLocations (array): [Front spar, Rear spar] in % of chord
    
    % Define database file path 
    database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24';
    databasePath = fullfile(database_computer,'Project_Root', 'Data', 'TFG_Amora.mat');

    % Load existing database if it exists
    if isfile(databasePath)
        load(databasePath, 'TFG_Amora');
    else
        warning('Database does not exist. Creating a new one.');
        TFG_Amora = struct(); % Create empty struct
    end

    % Check if aircraft already exists
    if isfield(TFG_Amora, 'datosEstructural') && isfield(TFG_Amora.datosEstructural, name)
        warning('Datos Estructural "%s" already exists.', name);
        userChoice = input('Do you want to overwrite it? (y/n): ', 's');
        if lower(userChoice) ~= 'y'
            disp('Operation canceled. Data was NOT modified.');
            return;
        end
    end

    % Save structural parameters
    TFG_Amora.datosEstructural.(name).numero_de_puntos_en_las_lineas = numero_de_puntos_en_las_lineas;
    TFG_Amora.datosEstructural.(name).Structure.RibSpacing = ribSpacing;
    TFG_Amora.datosEstructural.(name).Structure.StringerSpacing = stringerSpacing;
    TFG_Amora.datosEstructural.(name).Structure.SparLocations = sparLocations;
    
    % Save the updated struct
    save(databasePath, 'TFG_Amora');

    disp(['Structural data for "' name '" successfully added/updated.']);
end
