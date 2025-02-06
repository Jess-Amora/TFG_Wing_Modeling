function write_bdf_points_v3(filename, nodes)
% WRITE_BDF_POINTS_V3: Writes node data to a BDF (Bulk Data File) for Nastran.
%
% Inputs:
%   filename - Path to the output .bdf file.
%   nodes - Nx6 numeric matrix with columns:
%           [ID, CP, X, Y, Z, CD]
%
% Outputs:
%   Generates a `.bdf` file with GRID entries.

    % ✅ Ensure the directory exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % ✅ Open the file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    % ✅ Write the header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    % 🔄 Loop through each node and write it to the file
    for i = 1:size(nodes, 1)  % Use `size(nodes,1)` for a numeric matrix
        fprintf(fid, 'GRID,%d,%d,%.6f,%.6f,%.6f,%d\n', ...
                nodes(i, 1), nodes(i, 2), nodes(i, 3), ...
                nodes(i, 4), nodes(i, 5), nodes(i, 6));
    end

    % ✅ Write the footer
    fprintf(fid, 'ENDDATA\n');

    % ✅ Close the file
    fclose(fid);

    fprintf('✅ BDF file written successfully to %s\n', filename);
end
