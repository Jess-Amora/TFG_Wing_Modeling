function write_bdf_points(filename, nodes)
    % WRITE_BDF_POINTS: Writes node data in BDF format with asterisk continuation.
    %
    % Input:
    %   filename - Path to the output .bdf file
    %   nodes    - Matrix containing node data
    %
    % Node format: [ID, CP, X, Y, Z, CD]

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

    % Write node data with asterisk formatting
    for i = 1:size(nodes, 1)
        % First line: GRID* format
        fprintf(fid, 'GRID*   %d                             %.6f       %.6f\n', ...
                nodes(i, 1), nodes(i, 3), nodes(i, 4));
        % Second line: * format
        fprintf(fid, '*        %.6f\n', nodes(i, 5));
    end

    % Write the footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);
end
