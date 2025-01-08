function valid_nodes = preprocess_nodes(nodes)
% preprocess_nodes: Filters and validates node matrices.
%
% Inputs:
%   nodes: Nx6 node matrix [local_id, x, y, rib_index, stringer_index, tag]
%
% Outputs:
%   valid_nodes: Filtered node matrix with only valid numeric rows

    %% Validate Input Dimensions
    if size(nodes, 2) < 5
        error('Input nodes must have at least 5 columns: [local_id, x, y, rib_index, stringer_index].');
    end
    
    %% Filter Valid Nodes
    valid_nodes = nodes( ...
        isnumeric(nodes(:, 3)) & ...
        isnumeric(nodes(:, 4)) & ...
        ~isnan(nodes(:, 3)) & ...
        ~isnan(nodes(:, 4)), :);
    
    %% Display Preprocessing Summary
    fprintf('✅ Preprocessed nodes: %d valid rows retained out of %d total rows.\n', ...
        size(valid_nodes, 1), size(nodes, 1));
end
