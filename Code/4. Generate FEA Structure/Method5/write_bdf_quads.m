function write_bdf_quads(filename, quads_matrix, tris_matrix, pshell_info, material_info)
% WRITE_BDF_QUADS Writes quad (CQUAD4) and triangle (CTRIA3) element data,
% along with material (MAT1) and property (PSHELL) cards, to a BDF file.
%
% The MAT1 card is written with a continuation line. Material numbers are
% formatted to include a trailing dot if needed, without unnecessary decimals,
% and aligned in fixed fields.
%
% Example:
%   write_bdf_quads('model.bdf', quads_matrix, tris_matrix, pshell_info, material_info);

    %% Ensure output directory exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    %% Open file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    %% Write header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    %% --- Step 1: Write Material Card (MAT1) ---
    if isfield(material_info, 'material_id') && isfield(material_info, 'E') && isfield(material_info, 'nu')
        fprintf(fid, '$ Material Record : mat1.%d\n', material_info.material_id);
        fprintf(fid, '$ Description of Material :\n');
        
        % Set default values if missing
        if isfield(material_info, 'rho')
            rho_value = material_info.rho;
        else
            rho_value = 0.0;
        end
        
        if isfield(material_info, 'G')
            G_value = material_info.G;
        else
            G_value = material_info.E / (2 * (1 + material_info.nu)); 
        end
        
        if isfield(material_info, 'alpha')
            alpha_value = material_info.alpha;
        else
            alpha_value = 0.0;
        end

        % Format each value in a fixed-width field of 16 characters.
        E_str = format_mat1_number(material_info.E, 16);
        G_str = format_mat1_number(G_value, 16);
        nu_str = format_mat1_number(material_info.nu, 16);
        rho_str = format_mat1_number(rho_value, 16);
        alpha_str = format_mat1_number(alpha_value, 16);

        % Write MAT1 card with continuation line.
        % First line: material_id, E, G, nu.
        fprintf(fid, 'MAT1*   %-8d%s%s%s\n', material_info.material_id, E_str, E_str, G_str);
        % Continuation line: rho and alpha.
        fprintf(fid, '*       %s%s\n', nu_str, rho_str);
    else
        error('Material information is incomplete. Please provide material_id, E, and nu.');
    end

    %% --- Step 2: Write Property Card (PSHELL) ---
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

    %% Write footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
    fprintf('BDF file written successfully to %s\n', filename);
end

function str = format_mat1_number(num, width)
% FORMAT_MAT1_NUMBER Formats a number for MAT1 card output.
% It uses the %g format and then ensures:
%   - A trailing dot is present if not already.
%   - For numbers between 0 and 1, the leading zero is removed.
%   - The string is left-aligned in a field of the specified width.
%
% Inputs:
%   num   - The number to format.
%   width - The desired field width.
%
% Output:
%   str   - The formatted string of length 'width'.

    % Use %g to convert the number
    temp = sprintf('%g', num);
    
    % If no decimal point, append one.
    if ~contains(temp, '.')
        temp = [temp, '.'];
    end
    
    % For numbers less than one (starting with '0.'), remove the leading zero.
    if startsWith(temp, '0.')
        temp = temp(2:end);
    end
    
    % Left-align the number in the specified field width.
    str = sprintf('%-*s', width, temp);
end
