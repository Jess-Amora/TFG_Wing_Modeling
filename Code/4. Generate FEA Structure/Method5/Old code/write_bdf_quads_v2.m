function write_bdf_quads(filename, quads_matrix, tris_matrix, pshell_info, material_info)
    % WRITE_BDF_QUADS: Writes quad (CQUAD4) and triangle (CTRIA3) data, material, and property info in BDF format.
    %
    % Inputs:
    %   filename      - Path to the output .bdf file.
    %   quads_matrix  - Nx6 matrix for quads: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
    %   tris_matrix   - Mx5 matrix for tris: [EID, PID, G1, G2, G3, THETA, ZOFFS].
    %   pshell_info   - Struct with PSHELL properties:
    %                   - property_id: ID of the property (PID).
    %                   - material_id: ID of the associated material (MID).
    %                   - thickness: Shell thickness.
    %   material_info - Struct with material properties:
    %                   - material_id: ID of the material (MID).
    %                   - E: Young's modulus (MPa or N/m²).
    %                   - nu: Poisson's ratio.
    %                   - rho (optional): Density.

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
    % Set default values if missing
    rho_value = 0.0; % Default density if not provided
    if isfield(material_info, 'rho')
        rho_value = material_info.rho;
    end
    G_value = material_info.E / (2 * (1 + material_info.nu)); % Compute G if missing
    if isfield(material_info, 'G')
        G_value = material_info.G; % Use provided G if available
    end
    alpha_value = 0.0; % Default Thermal Expansion Coefficient
    if isfield(material_info, 'alpha')
        alpha_value = material_info.alpha;
    end
    tref_value = 0.0; % Default Reference Temperature
    if isfield(material_info, 'temperature')
        tref_value = material_info.temperature;
    end
    damping_value = 0.0; % Default Structural Damping Coefficient
    if isfield(material_info, 'damping')
        damping_value = material_info.damping;
    end
    
    % Correctly formatted MAT1 output (Nastran order)
    fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f%-16.6f%-16.6f%-16.6f%-16.6f\n', ...
    material_info.material_id, material_info.E, material_info.G, material_info.nu, ...
    material_info.rho, material_info.alpha, material_info.tref, material_info.ge);


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

    % --- Step 3: Write Quad Elements (CQUAD4) ---
    for i = 1:size(quads_matrix, 1)
        fprintf(fid, 'CQUAD4  %-8d%-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
            quads_matrix(i, 1), ... % EID
            quads_matrix(i, 2), ... % PID
            quads_matrix(i, 3), ... % G1
            quads_matrix(i, 4), ... % G2
            quads_matrix(i, 5), ... % G3
            quads_matrix(i, 6), ... % G4
            quads_matrix(i, 7), ... % THETA
            quads_matrix(i, 8));    % ZOFFS
    end

    % --- Step 4: Write Triangle Elements (CTRIA3) ---
    for i = 1:size(tris_matrix, 1)
        fprintf(fid, 'CTRIA3  %-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
            tris_matrix(i, 1), ... % EID
            tris_matrix(i, 2), ... % PID
            tris_matrix(i, 3), ... % G1
            tris_matrix(i, 4), ... % G2
            tris_matrix(i, 5), ... % G3
            tris_matrix(i, 6), ... % THETA
            tris_matrix(i, 7));    % ZOFFS
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
    fprintf('BDF file written successfully to %s\n', filename);
end
