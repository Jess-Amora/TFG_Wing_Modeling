function combined_nodes_modified = add_nodes_to_combined_nodes_v2(combined_nodes, new_nodes)
% add_nodes_to_combined_nodes_v2: Adds new nodes to the combined_nodes table.
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

    % Replace NaN in local_id with temporary placeholder
    if any(isnan(new_nodes.local_id))
        new_nodes.local_id(isnan(new_nodes.local_id)) = -1; % Use -1 as a temporary placeholder
    end

    % Iterate through each tag in new_nodes
    unique_tags = unique(new_nodes.tag);
    for i = 1:length(unique_tags)
        current_tag = unique_tags{i};

        % Filter existing nodes with the same tag
        existing_tag_nodes = combined_nodes(strcmp(combined_nodes.tag, current_tag), :);

        if ~isempty(existing_tag_nodes)
            % If the tag exists, start local_id from the max local_id for that tag + 1
            max_local_id_for_tag = max(existing_tag_nodes.local_id);
            start_local_id = max_local_id_for_tag + 1;
        else
            % If the tag does not exist, start local_id from 1
            start_local_id = 1;
        end

        % Assign local_id to new nodes with the current tag
        tag_mask = strcmp(new_nodes.tag, current_tag);
        tag_indices = find(tag_mask); % Get indices for this tag
        new_nodes.local_id(tag_indices) = (start_local_id:(start_local_id + length(tag_indices) - 1))';
    end

    % Append new nodes to combined_nodes
    combined_nodes_modified = [combined_nodes_modified; new_nodes];

    disp('Nodes added successfully to combined_nodes.');
end
