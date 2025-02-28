function forces = generate_input_forces_table(input_matrix, combined_nodes_3D, tolerance)
% GENERATE_INPUT_FORCES_TABLE returns a forces table by matching given 
% (x,y, force_z) inputs with nodes in combined_nodes_3D.
%
%   forces = generate_input_forces_table(input_matrix, combined_nodes_3D, tolerance)
%
% Inputs:
%   input_matrix       - Nx3 matrix where columns are [x, y, force_z].
%                        force_z is the load (signed) at that (x,y) point.
%   combined_nodes_3D  - Table containing existing nodes with at least these columns:
%                        'global_id','x','y','z','rib_index','stringer_index','tag','h'.
%   tolerance          - A positive scalar specifying the allowable difference in x and y
%                        for a match (e.g. 1e-3).
%
% Output:
%   forces             - Table with columns:
%                           {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'}
%                        For each input point that finds a matching node,
%                        node_id is taken from combined_nodes_3D.global_id,
%                        magnitude is the absolute value of force_z, and the z-direction 
%                        is set to -1 if force_z is negative and +1 otherwise. 
%
% Example:
%   input_matrix = [10, 5, -1000;
%                   15, 5, -1200;
%                   25, 10, 800];
%   tol = 1e-3;
%   forces = generate_input_forces_table(input_matrix, combined_nodes_3D, tol);
%
% See also: find_nodes_in_combined_nodes_3D

    % Validate inputs
    if size(input_matrix,2) ~= 3
        error('input_matrix must be Nx3 with columns [x, y, force_z].');
    end

    nPoints = size(input_matrix,1);
    forces = table([], [], [], [], [], ...
        'VariableNames', {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'});

    % Loop through each input point
    for i = 1:nPoints
        xq = input_matrix(i,1);
        yq = input_matrix(i,2);
        fz = input_matrix(i,3);
        
        % Find matching nodes using the helper function.
        % (This function returns all nodes in combined_nodes_3D whose x and y
        % are within 'tolerance' of the provided values.)
        matches = find_nodes_in_combined_nodes_3D(combined_nodes_3D, xq, yq, tolerance);
        
        if isempty(matches)
            warning('No matching node found for input (x,y) = (%.3f, %.3f)', xq, yq);
            continue;  % Skip this input if no match found
        end
        
        % Use the first matching node.
        match = matches(1,:);
        node_id = match.global_id;
        
        % Determine magnitude and direction.
        % If force is negative, we assume it acts downward (dir_z = -1); otherwise upward.
        if fz < 0
            magnitude = abs(fz);
            dir_z = -1;
        else
            magnitude = fz;
            dir_z = 1;
        end
        
        % For this example, we assume the force is purely vertical, so:
        dir_x = 0;
        dir_y = 0;
        
        % Create a new row of forces.
        new_force = table(node_id, magnitude, dir_x, dir_y, dir_z, ...
            'VariableNames', {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'});
        
        forces = [forces; new_force];  %#ok<AGROW>
    end

end
