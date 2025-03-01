function write_bdf_quads(filename, quads_matrix, tris_matrix, pshell_info, material_info)
    % WRITE_BDF_QUADS: Writes quad (CQUAD4) and triangle (CTRIA3) data,
    % material, and property info in BDF format.
    %
    % This version ensures that material card values are formatted so that
    % floating‐point numbers have a trailing dot without unnecessary decimals.
    
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
        fprintf(fid, '$ Material Record : mat1.%d\n', material_info.material_id);
        fprintf(fid, '$ Description of Material :\n');

        % Set default values if missing
        rho_value = 0.0;
        if isfield(material_info, 'rho')
            rho_value = material_info.rho;
        end
        % Compute G if missing using the relation G = E/(2*(1+nu))
        G_value = material_info.E / (2 * (1 + material_info.nu));
        if isfield(material_info, 'G')
            G_value = material_info.G;
        end
        alpha_value = 0.0;
        if isfield(material_info, 'alpha')
            alpha_value = material_info.alpha;
        end

        % Use our custom formatting function to get strings with a trailing dot.
        E_str = format_mat1_number(material_info.E, 16);
        G_str = format_mat1_number(G_value, 16);
        nu_str = format_mat1_number(material_info.nu, 16);
        rho_str = format_mat1_number(rho_value, 16);
        alpha_str = format_mat1_number(alpha_value, 16);

        % Print material card with continuation line
        fprintf(fid, 'MAT1*   %-8d%s%s%s\n', material_info.material_id, E_str, G_str, nu_str);
        fprintf(fid, '*       %s%s\n', rho_str, alpha_str);
    else
        error('Material information is incomplete. Please provide material_id, E, and nu.');
    end

    % --- Step 2: Write Property Card (PSHELL) ---
    if isfield(pshell_info, 'property_id') && isfield(pshell_info, 'material_id') && isfield(pshell_info, 'thickness')
        % For PSHELL, we'll print thickness with one decimal place (modify if needed)
        fprintf(fid, 'PSHELL  %-8d%-8d%-16.6f\n', ...
            pshell_info.property_id, pshell_info.material_id, pshell_info.thickness);
    else
        error('PSHELL information is incomplete. Please provide property_id, material_id, and thickness.');
    end

    % --- Step 3: Write Quad Elements (CQUAD4) ---
    for i = 1:size(quads_matrix, 1)
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

function str = format_mat1_number(num, width)
    % FORMAT_MAT1_NUMBER Formats a number for MAT1 card output.
    % Uses %g format, then ensures a trailing dot, and removes a leading 0 if the number is less than 1.
    %
    % Inputs:
    %   num   - The number to format.
    %   width - The field width (characters).
    %
    % Output:
    %   str   - A string of length 'width' with the formatted number.

    % Convert number to string using %g
    temp = sprintf('%g', num);
    
    % Ensure there is a decimal point: if not, append one.
    if ~contains(temp, '.')
        temp = [temp, '.'];
    end
    
    % Remove a leading zero for numbers between 0 and 1.
    if startsWith(temp, '0.')
        temp = temp(2:end);
    end

    % Pad or truncate the string to exactly 'width' characters (left-aligned)
    % If the string is longer than width, we do not want to truncate important digits.
    % So we use a minimum field width.
    formatSpec = sprintf('%%-%ds', width);
    str = sprintf(formatSpec, temp);
end
