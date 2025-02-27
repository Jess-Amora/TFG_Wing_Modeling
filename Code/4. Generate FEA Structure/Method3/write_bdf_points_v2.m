function write_bdf_points_v2(filename, nodes)
    % WRITE_BDF: Write nodes to a BDF (Bulk Data File) for Nastran.
    % Input:
    %   filename - Name of the BDF file to be written.
    %   nodes - Matrix containing node data in the following format:
    %           [ID, CP, X, Y, Z, CD]
    %
    % Example:
    %   write_bdf('output.bdf', nodes);

    % Open the file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    % Write the header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    % Loop through each node and write it to the file
    for i = 1:size(nodes, 1)
        % Node format: GRID, ID, CP, X, Y, Z, CD
        fprintf(fid, 'GRID,%d,%d,%.6f,%.6f,%.6f,%d\n', ...
                nodes(i, 1), nodes(i, 2), nodes(i, 3), ...
                nodes(i, 4), nodes(i, 5), nodes(i, 6));
    end

    % Write the end of the bulk section
    fprintf(fid, 'ENDDATA\n');

    % Close the file
    fclose(fid);
end
