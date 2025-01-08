function [tri_surfaces, warnings] = handle_front_spar_irregularities(current_stringer_nodes, next_stringer_nodes)
% Handles irregularities near the front spar (nodes marked with -2).
%
% Inputs:
%   current_stringer_nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   next_stringer_nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%
% Outputs:
%   tri_surfaces: Mx3 matrix (triangular surfaces)
%   warnings: Cell array of warnings

    %% Initialization
    tri_surfaces = [];
    warnings = {};
    
    % Extract front spar nodes
    front_nodes_current = current_stringer_nodes(current_stringer_nodes(:, 3) == -2, :);
    front_nodes_next = next_stringer_nodes(next_stringer_nodes(:, 3) == -2, :);
    
    if size(front_nodes_current, 1) < 1 || size(front_nodes_next, 1) < 1
        warnings{end+1} = 'Missing front spar nodes.';
        return;
    end
    
    % Create triangular surface using last valid nodes
    last_valid_node_current = current_stringer_nodes(end-1, :);
    last_valid_node_next = next_stringer_nodes(end-1, :);
    
    tri_surfaces = [
        tri_surfaces;
        last_valid_node_current(5), front_nodes_current(5), front_nodes_next(5);
    ];
    
    disp('✅ Irregular front spar surfaces created.');
end
