function nodes_table = convert_nodes_to_table(nodes)
    % Validate and handle different input dimensions
    if ndims(nodes) == 3 && size(nodes, 1) == 1
        nodes = squeeze(nodes)';
    end
    if size(nodes, 2) < 4
        error('Input nodes must have at least 4 columns: [x, y, rib_index, stringer_index]');
    end

    % Extract columns and set default values
    x = nodes(:, 1);
    y = nodes(:, 2);
    rib_index = nodes(:, 3);
    stringer_index = nodes(:, 4);
    local_id = (1:size(nodes, 1))';
    tag = repmat("stringer", size(nodes, 1), 1);

    if size(nodes, 2) >= 5
        local_id = nodes(:, 5);
    end
    if size(nodes, 2) >= 6
        tag = string(nodes(:, 6));
    end

    % Create table
    nodes_table = table(local_id, x, y, rib_index, stringer_index, tag, ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
end
