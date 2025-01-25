function write_bdf_lines(filename, lines)
% WRITE_BDF_LINES: Writes line (element) data in BDF format.
%
% Input:
%   filename - Path to the output .bdf file.
%   lines    - Matrix containing line data.
%
% Line format: [ID, PID, StartNode, EndNode]
%
% Example:
%   lines = [
%       1, 1, 1, 2;  % Line 1: PID=1, connects Node 1 to Node 2
%       2, 1, 2, 3;  % Line 2: PID=1, connects Node 2 to Node 3
%   ];

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

    % Write line data
    for i = 1:size(lines, 1)
        fprintf(fid, 'CROD     %d       %d       %d       %d\n', ...
            lines(i, 1), lines(i, 2), lines(i, 3), lines(i, 4));
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
end
