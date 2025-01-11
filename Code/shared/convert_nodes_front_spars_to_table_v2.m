function nodes_table = convert_nodes_front_spars_to_table(nodes)
    % Convert front spar nodes to table
    num_nodes = size(nodes, 1);
    nodes_table = table((1:num_nodes)', nodes(:, 1), nodes(:, 2), ...
        (1:num_nodes)', NaN(num_nodes, 1), repmat("front spars", num_nodes, 1), ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
end
