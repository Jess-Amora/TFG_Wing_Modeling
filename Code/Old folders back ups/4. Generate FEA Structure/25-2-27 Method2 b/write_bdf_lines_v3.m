function write_bdf_lines_v3(filename, lines_matrix, material_info, property_info)
% WRITE_BDF_LINES: Writes line (CROD) data and material/property information in BDF format.
%
% Inputs:
%   filename - Path to the output .bdf file.
%   lines_matrix - Nx4 matrix:
%                  [Line ID (EID), Property ID (PID), Point1 (G1), Point2 (G2)].
%   material_info - Struct containing material properties with fields:
%                   - material_id: ID of the material (MID)
%                   - E: Young's modulus (MPa or N/m²)
%                   - nu: Poisson's ratio
%                   - rho: Density (optional, in tonne/mm³)
%   property_info - Struct containing property definitions with fields:
%                   - property_id: ID of the property (PID)
%                   - material_id: ID of the associated material (MID)
%                   - A: Cross-sectional area (m²)

    % Ensure the directory exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % Open the file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    % Write the header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    % --- Step 1: Write Material Card (MAT1) ---
    if isfield(material_info, 'material_id') && isfield(material_info, 'E') && isfield(material_info, 'nu')
        rho_value = 0.0; % Default density if not provided
        if isfield(material_info, 'rho')
            rho_value = material_info.rho;
        end
        fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f\n', ...
            material_info.material_id, material_info.E, rho_value, material_info.nu);
    else
        error('Material information is incomplete. Please provide material_id, E, and nu.');
    end

    % --- Step 2: Write Property Card (PROD) ---
    if isfield(property_info, 'property_id') && isfield(property_info, 'material_id') && isfield(property_info, 'A')
        fprintf(fid, 'PROD    %-8d%-8d%-16.6f\n', ...
            property_info.property_id, property_info.material_id, property_info.A);
    else
        error('Property information is incomplete. Please provide property_id, material_id, and A.');
    end

    % --- Step 3: Write CROD Elements ---
    for i = 1:size(lines_matrix, 1)
        fprintf(fid, 'CROD    %-8d%-8d%-8d%-8d\n', ...
            lines_matrix(i, 1), ... % Line ID (EID)
            lines_matrix(i, 2), ... % Property ID (PID)
            lines_matrix(i, 3), ... % Point1 (G1)
            lines_matrix(i, 4));    % Point2 (G2)
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
    fprintf('BDF file written successfully to %s\n', filename);
end
