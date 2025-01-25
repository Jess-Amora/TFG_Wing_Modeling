function write_bdf_v2(filename, nodes, lines)
% WRITE_BDF: Writes node and line data in BDF format.
%
% Input:
%   filename - Path to the output .bdf file.
%   nodes    - Matrix containing node data [ID, CP, X, Y, Z, CD].
%   lines    - Matrix containing line data [ID, PID, StartNode, EndNode].

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

    % Write node data
    for i = 1:size(nodes, 1)
        fprintf(fid, 'GRID*   %d                             %.6f       %.6f\n', ...
                nodes(i, 1), nodes(i, 3), nodes(i, 4));
        fprintf(fid, '*        %.6f\n', nodes(i, 5));
    end

    % Write line data
    for i = 1:size(lines, 1)
        fprintf(fid, 'CROD     %d       %d       %d       %d\n', ...
            lines(i, 1), lines(i, 2), lines(i, 3), lines(i, 4));
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
end
