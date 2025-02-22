function nodes_numeric = extract_numeric_nodes(nodes)
% extract_numeric_nodes: Extracts numeric columns from Nx6 nodes
%
% Inputs:
%   nodes: Nx6 matrix [local_id, x, y, rib_index, stringer_index, tag]
%
% Outputs:
%   nodes_numeric: Nx5 matrix [local_id, x, y, rib_index, stringer_index]

    %% Validate Input
    if size(nodes, 2) ~= 6
        error('Input nodes must have 6 columns: [local_id, x, y, rib_index, stringer_index, tag].');
    end

    %% Extract Only Relevant Numeric Columns
    nodes_numeric = nodes(:, 1:5);
end
