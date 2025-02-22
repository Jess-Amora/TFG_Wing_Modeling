function next_stringer_nodes = update_next_stringer_with_front_spar(combined_nodes, stringer_index)
% UPDATE_NEXT_STRINGER_WITH_FRONT_SPAR - Adds front spar nodes to next stringer nodes.

    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1, :);
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    if ~isempty(next_stringer_nodes)
        last_rib_index = max(next_stringer_nodes.rib_index);
    else
        last_rib_index = -Inf;
    end

    additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);
    next_stringer_nodes = [next_stringer_nodes; additional_nodes];

    if isempty(next_stringer_nodes)
        warning('Next stringer nodes are empty after including front spar nodes.');
    end
end
