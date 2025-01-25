function write_bdf_lines(filename, lines_matrix)
% WRITE_BDF_LINES: Writes line (CROD) data in BDF format.
%
% Input:
%   filename - Path to the output .bdf file.
%   lines_matrix - Nx4 matrix:
%                  [Line ID (EID), Property ID (PID), Point1 (G1), Point2 (G2)].

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

    % Write CROD elements
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
end
