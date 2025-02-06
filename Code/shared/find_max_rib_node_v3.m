function node = find_max_rib_node_v3(combined_table, stringer_index, use_3D)
% FIND_MAX_RIB_NODE_V3: Finds the node with the maximum rib_index (<= 5e4) for a given stringer_index.
% Now supports both 2D (combined_nodes) and 3D (combined_nodes_3D) tables.
%
% Inputs:
%   combined_table  - Table with columns:
%                     If 2D: [local_id, x, y, rib_index, stringer_index, tag]
%                     If 3D: [local_id, x, y, z, rib_index, stringer_index, tag, h]
%   stringer_index  - The stringer index to filter by.
%   use_3D          - Boolean flag: If true, searches in `combined_nodes_3D`;  
%                     If false, searches in `combined_nodes` (default: false).
%
% Output:
%   node - Row of `combined_table` with the maximum rib_index for the given stringer_index.

    % Validate input table structure
    if use_3D
        required_vars = {'local_id', 'x', 'y', 'z', 'rib_index', 'stringer_index', 'tag', 'h'};
    else
        required_vars = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
    end

    if ~all(ismember(required_vars, combined_table.Properties.VariableNames))
        error('The input table must contain columns: %s', strjoin(required_vars, ', '));
    end

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
