function node = find_max_rib_node_v2(combined_table, stringer_index)
    % FIND_MAX_RIB_NODE: Finds the node with the maximum rib_index (<= 5e4) for a given stringer_index.
    %
    % Inputs:
    %   combined_table: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
    %   stringer_index: The stringer index to filter by.
    %
    % Output:
    %   node: Row of combined_table with the maximum rib_index for the given stringer_index.
    
    % Filter rows for the specified stringer_index
    stringer_nodes = combined_table(combined_table.stringer_index == stringer_index, :);
    
    % Further filter rows for rib_index <= 5e4
    filtered_nodes = stringer_nodes(stringer_nodes.rib_index <= 5e4, :);
    
    % Check if any rows match the filters
    if isempty(filtered_nodes)
        warning('No nodes found for stringer_index %d with rib_index <= 5e4.', stringer_index);
        node = []; % Return empty if no matching rows
        return;
    end
    
    % Find the row with the maximum rib_index
    [~, max_idx] = max(filtered_nodes.rib_index); % Index of max rib_index
    node = filtered_nodes(max_idx, :); % Return the corresponding row
end
