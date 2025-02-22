function node = find_max_rib_node(combined_table, stringer_index)
    % Find the row in the combined_table with the given stringer_index
    % and the maximum rib_index.
    %
    % Inputs:
    %   combined_table: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
    %   stringer_index: The stringer index to filter by.
    %
    % Output:
    %   node: Row of combined_table with the maximum rib_index for the given stringer_index.
    
    % Filter rows for the specified stringer_index
    stringer_nodes = combined_table(combined_table.stringer_index == stringer_index, :);
    
    % Check if any rows match the stringer_index
    if isempty(stringer_nodes)
        warning('No nodes found for stringer_index %d.', stringer_index);
        node = []; % Return empty if no matching rows
        return;
    end
    
    % Find the row with the maximum rib_index
    [~, max_idx] = max(stringer_nodes.rib_index); % Index of max rib_index
    node = stringer_nodes(max_idx, :); % Return the corresponding row
end
