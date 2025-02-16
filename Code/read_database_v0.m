% read_database('C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root')


function read_database(databasePath)
    % ===========================================================
    % 📌 Function: read_database
    % ===========================================================
    % Reads structural and aircraft data from CSV files and loads
    % them into the `TFG_Amora.mat` database.
    %
    % ✅ Reads:
    %   - `structural_parameters.csv` → datosEstructural
    %   - `aircraft_data.csv` → aircraft_data
    % 
    % ✅ Saves:
    %   - `TFG_Amora.datosEstructural`
    %   - `TFG_Amora.aircraft_data`
    %
    % ===========================================================

    % Define paths for the CSV files
    structFile = fullfile(databasePath, 'Data', 'structural_parameters.csv');
    aircraftFile = fullfile(databasePath, 'Data', 'aircraft_data.csv');
    tfgFile = fullfile(databasePath, 'Data', 'TFG_Amora.mat');

    % ✅ Step 1: Load Existing Database or Create a New One
    if isfile(tfgFile)
        load(tfgFile, 'TFG_Amora'); % Load existing database
        disp('✅ Database loaded.');
    
        % ✅ Ensure `datosEstructural` exists
        if ~isfield(TFG_Amora, 'datosEstructural')
            warning('⚠️ `datosEstructural` was missing. Creating an empty struct.');
            TFG_Amora.datosEstructural = struct();
        end
    
        % ✅ Ensure `aircraft_data` exists
        if ~isfield(TFG_Amora, 'aircraft_data')
            warning('⚠️ `aircraft_data` was missing. Creating an empty struct.');
            TFG_Amora.aircraft_data = struct();
        end
    
    else
        warning('⚠️ No existing database found. Creating a new one.');
        TFG_Amora = struct();
        TFG_Amora.datosEstructural = struct();
        TFG_Amora.aircraft_data = struct();
    end

    % ✅ Step 2: Read Structural Parameters CSV
    if isfile(structFile)
        structData = readtable(structFile, 'PreserveVariableNames', true);
        for i = 1:height(structData)
            name = structData.name{i};
            TFG_Amora.datosEstructural.(name) = struct(...
                'porcentaje_peso_ala_MTOW', structData.porcentaje_peso_ala_MTOW(i), ...
                'porcentaje_peso_combustible_MTOW', structData.porcentaje_peso_combustible_MTOW(i), ...
                'n', structData.n(i), ...
                'distancia_entre_costillas', structData.distancia_entre_costillas(i), ...
                'distancia_entre_larguerillo', structData.distancia_entre_larguerillo(i), ...
                'distancia_larguero_anterior_cuerda_porcentaje', structData.distancia_larguero_anterior_cuerda_porcentaje(i), ...
                'distancia_larguero_posterior_cuerda_porcentaje', structData.distancia_larguero_posterior_cuerda_porcentaje(i), ...
                'distancia_centro_aerodinamico', structData.distancia_centro_aerodinamico(i), ...
                'distancia_eje_de_referencia_estructural_larguero', structData.distancia_eje_de_referencia_estructural_larguero(i), ...
                'distancia_eje_de_referencia_estructural_cuerda', structData.distancia_eje_de_referencia_estructural_cuerda(i), ...
                'numero_de_puntos_en_las_lineas', structData.numero_de_puntos_en_las_lineas(i), ...
                'k_sust_a350_1000', structData.k_sust(i), ...
                'projectRoot', databasePath ...
            );
        end
        disp('✅ Structural parameters loaded successfully.');
    else
        warning('⚠️ No structural_parameters.csv file found.');
    end

    % ✅ Step 3: Read Aircraft Data CSV
    if isfile(aircraftFile)
        aircraftData = readtable(aircraftFile, 'PreserveVariableNames', true);
        for i = 1:height(aircraftData)
            name = aircraftData.name{i};
            c1 * datosEstructural.distancia_centro_aerodinamico + sin(flecha_radian) * (Lw) - c2 * datosEstructural.distancia_centro_aerodinamico;

            TFG_Amora.aircraft_data.(name) = struct(...
                'MTOW', aircraftData.MTOW(i), ...
                'superficie', aircraftData.Superficie(i), ...
                'geometria', struct(...
                    'flecha_radian', aircraftData.flecha_radian(i), ...
                    'b', aircraftData.b(i), ...
                    'Lf', aircraftData.Lf(i), ...
                    'c1', aircraftData.c1(i), ...
                    'c2', aircraftData.c2(i), ...
                    'Lw', aircraftData.b(i) / 2 - (aircraftData.Lf(i) / 2)...
                ) ...
            );
        end
        disp('✅ Aircraft data loaded successfully.');
    else
        warning('⚠️ No aircraft_data.csv file found.');
    end

    % ✅ Step 4: Save the Updated Database
    save(tfgFile, 'TFG_Amora');
    disp('✅ Database updated successfully.');
end

% ✅ Step 2: Read Structural Parameters CSV and add to database
    if isfile(structFile)
        structData = readtable(structFile, 'PreserveVariableNames', true);
        for i = 1:height(structData)
            name = structData.name{i};
            
            % Call `add_datosEstructural` to ensure calculations
            add_datosEstructural(name, ...
                structData.porcentaje_peso_ala_MTOW(i), ...
                structData.porcentaje_peso_combustible_MTOW(i), ...
                structData.n(i), ...
                structData.distancia_entre_costillas(i), ...
                structData.distancia_entre_larguerillo(i), ...
                structData.distancia_larguero_anterior_cuerda_porcentaje(i), ...
                structData.distancia_larguero_posterior_cuerda_porcentaje(i), ...
                structData.distancia_centro_aerodinamico(i), ...
                structData.distancia_eje_de_referencia_estructural_larguero(i), ...
                structData.distancia_eje_de_referencia_estructural_cuerda(i), ...
                structData.numero_de_puntos_en_las_lineas(i), ...
                structData.k_sust(i), ...
                databasePath ...
            );
        end
        disp('✅ Structural parameters loaded successfully.');
    else
        warning('⚠️ No structural_parameters.csv file found.');
    end