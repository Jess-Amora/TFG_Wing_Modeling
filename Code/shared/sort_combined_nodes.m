function sorted_nodes = sort_combined_nodes(combined_nodes_3D)
    % SORT_COMBINED_NODES: Sorts nodes so that 'rear spars' with 'extrados' come first.
    %
    % Input:
    %   combined_nodes_3D - Table with at least the following columns:
    %       - tag: Node tag (e.g., 'rear spars', 'front spars', 'stringer').
    %       - h: Surface type (e.g., 'extrados', 'intrados').
    %
    % Output:
    %   sorted_nodes - The sorted table.

    % Ensure 'tag' and 'h' are categorical with a custom sorting order
    combined_nodes_3D.tag = categorical(combined_nodes_3D.tag, ...
        {'rear spars', 'front spars', 'stringer', 'other'}, 'Ordinal', true);
    combined_nodes_3D.h = categorical(combined_nodes_3D.h, ...
        {'extrados', 'intrados'}, 'Ordinal', true);

    % Sort by 'tag' first, then by 'h'
    sorted_nodes = sortrows(combined_nodes_3D, {'tag', 'h'});
end
