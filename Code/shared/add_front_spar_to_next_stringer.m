function updated_next_stringer_nodes = add_front_spar_to_next_stringer(next_stringer_nodes, combined_nodes)
    % add_front_spar_to_next_stringer: Updates next_stringer_nodes by adding front spar nodes.
    %
    % Inputs:
    %   next_stringer_nodes: Table of current next stringer nodes.
    %   combined_nodes: Combined node table containing all nodes and tags.
    %
    % Outputs:
    %   updated_next_stringer_nodes: Table with front spar nodes appended to next stringer nodes.

    % Validate input types
    if ~istable(next_stringer_nodes)
        error('next_stringer_nodes must be a table. Received type: %s', class(next_stringer_nodes));
    end
    if ~istable(combined_nodes)
        error('combined_nodes must be a table. Received type: %s', class(combined_nodes));
    end

    % Identify the last rib index in next_stringer_nodes
    last_rib_index = next_stringer_nodes.rib_index(end);

    % Extract front spar nodes from combined_nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    % Find front spar nodes corresponding to ribs >= last_rib_index
    next_rib_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);

    % Sort the front spar nodes by rib_index to ensure sequential order
    next_rib_nodes = sortrows(next_rib_nodes, 'rib_index');

    % Append front spar nodes to next stringer nodes
    updated_next_stringer_nodes = [next_stringer_nodes; next_rib_nodes];
end
