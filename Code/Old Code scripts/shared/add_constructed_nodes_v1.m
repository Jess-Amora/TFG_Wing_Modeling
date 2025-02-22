function combined_nodes = add_constructed_nodes_v1(combined_nodes, root_rib, front_spar, num_new_ribs)
% add_constructed_nodes: Adds constructed nodes to fill gaps near the root-front spar.
%
% Inputs:
%   combined_nodes: Table with existing nodes [local_id, x, y, rib_index, stringer_index, tag].
%   root_rib: Rib index for the root (e.g., 0 or -1).
%   front_spar: Spar tag for the front spar (e.g., 'front spars').
%   num_new_ribs: Number of new ribs to create for filling the gaps.
%
% Output:
%   combined_nodes: Updated table with new constructed nodes.

    %% Initialization
    warnings = {};
    constructed_nodes = table([], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});
    next_local_id = max(combined_nodes.local_id) + 1;

    %% Extract Relevant Nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, front_spar), :);
    root_rib_nodes = combined_nodes(combined_nodes.rib_index == root_rib, :);
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);

    if isempty(front_spar_nodes) || isempty(root_rib_nodes) || isempty(stringer_nodes)
        warning('Relevant nodes for front spar, root rib, or stringers are missing.');
        return;
    end

    %% Generate New Ribs
    rib_indices = linspace(root_rib, min(combined_nodes.rib_index), num_new_ribs);
    for i = 2:length(rib_indices)
        current_rib = rib_indices(i);
        previous_rib = rib_indices(i - 1);

        for stringer_idx = unique(stringer_nodes.stringer_index)'
            % Find stringer coordinates at previous rib
            prev_stringer_node = stringer_nodes(stringer_nodes.stringer_index == stringer_idx & ...
                                                stringer_nodes.rib_index == previous_rib, :);

            % Project node forward to the current rib
            if ~isempty(prev_stringer_node)
                projected_x = prev_stringer_node.x + (front_spar_nodes.x(1) - prev_stringer_node.x) * ...
                              (current_rib - previous_rib) / (root_rib - previous_rib);
                projected_y = prev_stringer_node.y + (front_spar_nodes.y(1) - prev_stringer_node.y) * ...
                              (current_rib - previous_rib) / (root_rib - previous_rib);

                % Append constructed node
                constructed_nodes = [constructed_nodes; table( ...
                    next_local_id, projected_x, projected_y, current_rib, stringer_idx, "constructed", ...
                    'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'})];
                next_local_id = next_local_id + 1;
            else
                warnings{end+1} = sprintf('Missing stringer %d node for rib %d.', stringer_idx, previous_rib);
            end
        end
    end

    %% Combine and Return Updated Nodes
    combined_nodes = [combined_nodes; constructed_nodes];
    disp('Constructed nodes added successfully.');
    if ~isempty(warnings)
        disp('Warnings:');
        disp(warnings);
    end
end
