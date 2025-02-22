function combined_nodes_modified = add_nodes_to_combined_nodes(combined_nodes, new_nodes)
% add_nodes_to_combined_nodes: Adds new nodes to the combined_nodes table.
%
% Inputs:
%   combined_nodes: Table with existing nodes [local_id, x, y, rib_index, stringer_index, tag].
%   new_nodes: Table with the new nodes to add. Must have the same structure as combined_nodes.
%
% Output:
%   combined_nodes_modified: Updated table with added nodes.

    %% 📝 Initialization
    combined_nodes_modified = combined_nodes; % Copy input table for modification

    % Validate new_nodes table structure
    required_columns = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
    if ~all(ismember(required_columns, new_nodes.Properties.VariableNames))
        error('new_nodes must have the following columns: %s', strjoin(required_columns, ', '));
    end

    % Find the largest local_id in the existing table
    next_local_id = max(combined_nodes.local_id) + 1;

    % Assign local IDs to the new nodes
    new_nodes.local_id = (next_local_id:(next_local_id + height(new_nodes) - 1))';

    % Append new nodes to combined_nodes
    combined_nodes_modified = [combined_nodes_modified; new_nodes];

    disp('Nodes added successfully to combined_nodes.');
end
