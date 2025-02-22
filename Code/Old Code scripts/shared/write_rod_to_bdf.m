function write_rod_to_bdf(databasePath, outputFile, material_name, area)
    % ===========================================================
    % 📌 Function: write_rod_to_bdf
    % ===========================================================
    % Creates a Patran/Nastran `.bdf` file defining a CROD element.
    %
    % ✅ Inputs:
    %   - `databasePath`: Path to TFG_Amora database
    %   - `outputFile`: Name of output `.bdf` file
    %   - `material_name`: Name of the material (used in Patran)
    %   - `area`: Cross-sectional area of the rod
    %
    % ✅ Generates:
    %   - Material Definition (`MAT1`)
    %   - Rod Property (`PROD`)
    %   - Rod Element (`CROD`)
    %   - Two Nodes (0,0,0) and (1,0,0)
    %   - Boundary Condition (Fix Node 1)
    %   - Force on Node 2 (1,0,0)
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

    % Check if the material exists in the database
    materialField = ['material_', material_name]; % Convert name to struct field
    if isfield(TFG_Amora.materials, materialField)
        material = TFG_Amora.materials.(materialField);
    else
        error('⚠️ Material "%s" not found in the database.', material_name);
    end

    % Extract material properties
    E = material.E;
    nu = material.nu;
    rho = 0.0; % Default if density is missing
    if isfield(material, 'rho')
        rho = material.rho;
    end

    % Open the BDF file for writing
    fid = fopen(outputFile, 'w');
    if fid == -1
        error('⚠️ Could not open file %s for writing.', outputFile);
    end

    % Write Nastran Header
    fprintf(fid, '$ MSC.Nastran input file created by MATLAB\n');
    fprintf(fid, '$ Patran-compatible CROD element definition\n\n');
    fprintf(fid, 'CEND\nBEGIN BULK\n\n');

    % --- Step 1: Write Material Definition (MAT1) ---
    fprintf(fid, '$ Referenced Material Records\n');
    fprintf(fid, '$ Material Record: %s\n', material_name);
    fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f\n', 1, E, rho, nu);
    fprintf(fid, '\n');

    % --- Step 2: Write Rod Property (PROD) ---
    fprintf(fid, '$ Elements and Element Properties for region: %s\n', material_name);
    fprintf(fid, 'PROD    %-8d%-8d%-16.6f\n', 1, 1, area);
    fprintf(fid, '$ Pset: "%s" will be imported as: "prod.1"\n', material_name);
    fprintf(fid, '\n');

    % --- Step 3: Write Rod Element (CROD) ---
    fprintf(fid, 'CROD    %-8d%-8d%-8d%-8d\n', 1, 1, 1, 2);
    fprintf(fid, '\n');

    % --- Step 4: Define Nodes ---
    fprintf(fid, '$ Nodes of the Entire Model\n');
    fprintf(fid, 'GRID    1               0.      0.      0.\n');
    fprintf(fid, 'GRID    2               1.      0.      0.\n');
    fprintf(fid, '\n');

    % --- Step 5: Apply Boundary Condition (Fix Node 1) ---
    fprintf(fid, '$ Loads for Load Case: Default\n');
    fprintf(fid, '$ Displacement Constraints of Load Set: BC\n');
    fprintf(fid, 'SPC1    1       123     1\n');
    fprintf(fid, '\n');

    % --- Step 6: Apply Force at Node 2 ---
    fprintf(fid, '$ Nodal Forces of Load Set: F1\n');
    fprintf(fid, 'FORCE   1       2       0       1.      1.      0.      0.\n');
    fprintf(fid, '\n');

    % Close the file
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    disp(['✅ Rod element successfully written to ', outputFile]);
end
