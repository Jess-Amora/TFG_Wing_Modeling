function nodes = prepare_nodes_table(node_table)
%PREPARE_NODES_TABLE Prepare node data from a table for write_bdf function.
%
% Inputs:
%   node_table  : Table with columns 'NodeID', 'X', 'Y', and 'Z'.
%
% Output:
%   nodes       : Nx6 array formatted for write_bdf
%                 [ID, CP, X, Y, Z, CD]
%
% Example:
%   node_table = table([1; 2; 3], [0; 1; 1], [0; 0; 1], [0; 0; 0], ...
%                      'VariableNames', {'NodeID', 'X', 'Y', 'Z'});
%   nodes = prepare_nodes_table(node_table);

    % Validate table structure
    required_vars = {'NodeID', 'X', 'Y', 'Z'};
    if ~all(ismember(required_vars, node_table.Properties.VariableNames))
        error('Table must contain columns: %s', strjoin(required_vars, ', '));
    end
    
    % Extract data from the table
    node_ids = node_table.NodeID;
    coordinates = [node_table.X, node_table.Y, node_table.Z];
    
    % Check consistency of table data
    if height(node_table) ~= length(node_ids)
        error('Number of node IDs must match number of rows in the table.');
    end
    
    % Initialize CP and CD columns
    CP = zeros(size(node_ids));  % Input coordinate system
    CD = zeros(size(node_ids));  % Output coordinate system
    
    % Combine all data into the nodes array
    nodes = [node_ids, CP, coordinates, CD];
end
