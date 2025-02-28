function nodes_table = convert_nodes_rear_spars_to_table_fuselaje(nodes)
    % Convert rear spar nodes to table
    % Inputs:
    %   nodes: Nx2 matrix of node coordinates [x, y].
    % Outputs:
    %   nodes_table: Table with columns [local_id, x, y, rib_index, stringer_index, tag].

    num_nodes = size(nodes, 1); % Number of nodes
    nodes_table = table((1:num_nodes)', nodes(:, 1), nodes(:, 2), ...
        (1:num_nodes)', -2 * ones(num_nodes, 1), repmat("rear spars fuselaje", num_nodes, 1), ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
end
