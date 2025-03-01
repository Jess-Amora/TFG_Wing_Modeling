function write_bdf_quads(filename, quads_matrix, tris_matrix, pshell_info, material_info)
    % WRITE_BDF_QUADS: Writes quad (CQUAD4) and triangle (CTRIA3) data,
    % material, and property info in BDF format.
    % This version ensures that the MAT1 card uses fixed-field (8-character)
    % fields, with a trailing dot on floating-point numbers.
    
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
        fprintf(fid, '$ Material Record : MAT1 for material %d\n', material_info.material_id);
        fprintf(fid, '$ Description of Material :\n');

        % Set default values if missing
        rho_value = 0.0;
        if isfield(material_info, 'rho')
            rho_value = material_info.rho;
        end
        % Compute G using G = E/(2*(1+nu)) if not provided.
        G_value = material_info.E / (2 * (1 + material_info.nu));
        if isfield(material_info, 'G')
            G_value = material_info.G;
        end
        alpha_value = 0.0;
        if isfield(material_info, 'alpha')
            alpha_value = material_info.alpha;
        end

        % Format each number with exactly 8-character fields.
        mid_str   = sprintf('%-8d', material_info.material_id);
        E_str     = formatField(material_info.E, 8);
        G_str     = formatField(G_value, 8);
        nu_str    = formatField(material_info.nu, 8);
        rho_str   = formatField(rho_value, 8);
        alpha_str = formatField(alpha_value, 8);

        % The MAT1 card in fixed-field format typically has the following layout:
        % Columns 1-8: 'MAT1*  ' (with a continuation marker for subsequent fields)
        % Columns 9-16: MID, 17-24: E, 25-32: G, 33-40: NU, etc.
        % We will print a continuation line for rho and alpha.
        fprintf(fid, 'MAT1*   %s%s%s%s\n', mid_str, E_str, G_str, nu_str);
        fprintf(fid, '*       %s%s\n', rho_str, alpha_str);
    else
        error('Material information is incomplete. Please provide material_id, E, and nu.');
    end

    % --- Step 2: Write Property Card (PSHELL) ---
    if isfield(pshell_info, 'property_id') && isfield(pshell_info, 'material_id') && isfield(pshell_info, 'thickness')
        % For PSHELL, print using fixed-field formatting as well (example uses %-8.6f)
        fprintf(fid, 'PSHELL  %-8d%-8d%-8.6f\n', ...
            pshell_info.property_id, pshell_info.material_id, pshell_info.thickness);
    else
        error('PSHELL information is incomplete. Please provide property_id, material_id, and thickness.');
    end

    % --- Step 3: Write Quad Elements (CQUAD4) ---
    for i = 1:size(quads_matrix, 1)
        % Using fixed field width formatting for element connectivity.
        fprintf(fid, 'CQUAD4  %-8d%-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
            quads_matrix(i, 1), quads_matrix(i, 2), quads_matrix(i, 3), ...
            quads_matrix(i, 4), quads_matrix(i, 5), quads_matrix(i, 6), ...
            quads_matrix(i, 7), quads_matrix(i, 8));
    end

    % --- Step 4: Write Triangle Elements (CTRIA3) ---
    for i = 1:size(tris_matrix, 1)
        fprintf(fid, 'CTRIA3  %-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
            tris_matrix(i, 1), tris_matrix(i, 2), tris_matrix(i, 3), ...
            tris_matrix(i, 4), tris_matrix(i, 5), tris_matrix(i, 6), ...
            tris_matrix(i, 7));
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
    fprintf('BDF file written successfully to %s\n', filename);
end

function s = formatField(num, width)
    % FORMATFIELD Formats a number to a fixed field string for MAT1 output.
    % Uses %g format, ensures a trailing dot if missing, removes a leading 0
    % for numbers less than 1, and pads the result to exactly 'width' characters.
    %
    % Inputs:
    %   num   - The number to format.
    %   width - The field width (e.g., 8).
    %
    % Output:
    %   s     - A string of length 'width' representing the number.
    
    temp = sprintf('%g', num);
    % If no decimal point, append one.
    if ~contains(temp, '.')
        temp = [temp, '.'];
    end
    % For numbers between 0 and 1, remove leading zero.
    if startsWith(temp, '0.')
        temp = temp(2:end);
    end
    % Left-align and pad the string to exactly 'width' characters.
    s = sprintf('%-8s', temp);
    % If the result is longer than width, trim (but ideally numbers should fit).
    s = s(1:width);
end
