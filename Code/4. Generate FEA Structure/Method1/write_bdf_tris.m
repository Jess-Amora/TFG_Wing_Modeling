function write_bdf_tris_v1(filename, tris_matrix, pshell_info, material_info)
% WRITE_BDF_TRIS_V1: Writes triangle (CTRIA3) data and material/property information in BDF format.
%
% Inputs:
%   filename     - Path to the output .bdf file.
%   tris_matrix  - Nx7 matrix for triangles: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   pshell_info  - Struct with PSHELL properties:
%                  - property_id: ID of the property (PID).
%                  - material_id: ID of the associated material (MID).
%                  - thickness: Shell thickness.
%   material_info - Struct with material properties:
%                  - material_id: ID of the material (MID).
%                  - E: Young's modulus (MPa or N/m²).
%                  - nu: Poisson's ratio.
%                  - rho (optional): Density.

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

    % --- Step 2: Write Property Card (PSHELL) ---
    if isfield(pshell_info, 'property_id') && isfield(pshell_info, 'material_id') && isfield(pshell_info, 'thickness')
        fprintf(fid, 'PSHELL  %-8d%-8d%-16.6f\n', ...
            pshell_info.property_id, pshell_info.material_id, pshell_info.thickness);
    else
        error('PSHELL information is incomplete. Please provide property_id, material_id, and thickness.');
    end

    % --- Step 3: Write Triangle Elements (CTRIA3) ---
    for i = 1:size(tris_matrix, 1)
        fprintf(fid, 'CTRIA3  %-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
            tris_matrix(i, 1), ... % Element ID (EID)
            tris_matrix(i, 2), ... % Property ID (PID)
            tris_matrix(i, 3), ... % G1 (Node 1)
            tris_matrix(i, 4), ... % G2 (Node 2)
            tris_matrix(i, 5), ... % G3 (Node 3)
            tris_matrix(i, 6), ... % THETA
            tris_matrix(i, 7));    % ZOFFS
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
    fprintf('BDF file written successfully to %s\n', filename);
end
