function nodes = process_nodes(node_table)
    % PROCESS_NODES: Add a global ID column and save the node data and organization info.
    % Input:
    %   node_table - Input table containing node coordinates (x, y, z).
    % Output:
    %   nodes - Updated table with a global_id column.
    
    % Step 1: Assign a unique global ID
    num_nodes = size(node_table, 1);
    node_table.global_id = (1:num_nodes)'; % Add a new column for Global ID


    required_vars = {'x', 'y', 'z'};
    if ~all(ismember(required_vars, node_table.Properties.VariableNames))
        error('Table must contain columns: %s', strjoin(required_vars, ', '));
    end
    
    % Extract data from the table
    node_ids = node_table.global_id;
    coordinates = [node_table.x, node_table.y, node_table.z];

    
    % Initialize CP and CD columns
    CP = zeros(size(node_ids));  % Input coordinate system
    CD = zeros(size(node_ids));  % Output coordinate system
    
    % Combine all data into the nodes array
    nodes = [node_ids, CP, coordinates, CD];

end
