function write_materials_to_bdf(databasePath, outputFile)
    % ===========================================================
    % 📌 Function: write_materials_to_bdf (Patran-Compatible)
    % ===========================================================
    % Reads materials from `TFG_Amora.materials`
    % and writes a properly formatted `.bdf` file.
    %
    % ✅ Ensures Material Names Are Correctly Imported to Patran
    % ✅ Uses Fixed-Field Format for `MAT1`
    % ✅ Includes `PROD` for properties (if available)
    % ✅ Uses `CEND` and `BEGIN BULK` for Nastran Compatibility
    %
    % ===========================================================

    % Load the TFG_Amora database
    tfgFile = fullfile(databasePath, 'Data', 'TFG_Amora.mat');
    if isfile(tfgFile)
        load(tfgFile, 'TFG_Amora'); % Load database
        disp('✅ Database loaded.');
    else
        error('⚠️ No TFG_Amora.mat file found at %s', tfgFile);
    end

    % Check if materials exist
    if ~isfield(TFG_Amora, 'materials')
        error('⚠️ No materials found in TFG_Amora database.');
    end

    % Open the BDF file for writing
    fid = fopen(outputFile, 'w');
    if fid == -1
        error('⚠️ Could not open file %s for writing.', outputFile);
    end

    % Write Nastran header
    fprintf(fid, '$ MSC.Nastran Material File\n');
    fprintf(fid, 'CEND\nBEGIN BULK\n\n');

    % Get all material names
    materialNames = fieldnames(TFG_Amora.materials);
    matID = 1; % Material ID counter

    % Iterate through materials and write MAT1 cards
    for i = 1:length(materialNames)
        materialField = materialNames{i};
        material = TFG_Amora.materials.(materialField);
        
        % Extract material name (remove "material_" prefix for clarity)
        clean_material_name = strrep(materialField, 'material_', '');

        % Check required properties
        if isfield(material, 'E') && isfield(material, 'nu')
            % Set default density if missing
            rho_value = 0.0;
            if isfield(material, 'rho')
                rho_value = material.rho;
            end

            % ✅ Patran-Compatible Comment (Material Name)
            fprintf(fid, '$ PATRAN MATERIAL: %s\n', clean_material_name);

            % ✅ Fixed-Field Format for `MAT1`
            fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f\n', ...
                matID, material.E, rho_value, material.nu);

            % ✅ Write Comment for Material
            fprintf(fid, '$ Material: %s\n', clean_material_name);

            % ✅ Store material ID for use in PROD
            material_ids.(clean_material_name) = matID;
            matID = matID + 1;
        else
            warning('⚠️ Material %s is missing properties and will not be written.', clean_material_name);
        end
    end

    fprintf(fid, '\n');

    % ✅ Write Property Definitions (`PROD`) if available
    if isfield(TFG_Amora, 'properties')
        propertyNames = fieldnames(TFG_Amora.properties);
        propID = 1; % Property ID counter

        for i = 1:length(propertyNames)
            propertyField = propertyNames{i};
            property = TFG_Amora.properties.(propertyField);

            if isfield(property, 'material') && isfield(property, 'A')
                % Retrieve correct material ID
                matID = material_ids.(property.material);

                % ✅ Write `PROD` Property Card
                fprintf(fid, 'PROD    %-8d%-8d%-16.6f\n', ...
                    propID, matID, property.A);

                % ✅ Write Comment for Property
                fprintf(fid, '$ Property: %s\n', propertyField);

                propID = propID + 1;
            else
                warning('⚠️ Property %s is missing required fields and will not be written.', propertyField);
            end
        end
    end

    % ✅ Close the File
    fprintf(fid, '\nENDDATA\n');
    fclose(fid);

    disp(['✅ Material properties successfully written to ', outputFile]);
end
