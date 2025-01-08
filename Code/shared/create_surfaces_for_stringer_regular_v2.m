function [quad_surfaces, warnings] = create_surfaces_for_stringer_regular_v2(...
    current_stringer_nodes, next_stringer_nodes, threshold_distance, start_rib, end_rib)

% Handles general surface creation between two stringers, ensuring only valid quadrilateral surfaces are saved.
%
% Inputs:
%   current_stringer_nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   next_stringer_nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   threshold_distance: Minimum distance threshold between nodes
%
% Outputs:
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   warnings: Cell array with warnings

    %% Initialization
    quad_surfaces = [];
    warnings = {};
    
    %% Step 1: Remove Duplicate Rib Indices (Keep Last Occurrence)
    % Sort nodes by rib index to ensure order
    current_stringer_nodes = sortrows(current_stringer_nodes, 3); % By rib index
    next_stringer_nodes = sortrows(next_stringer_nodes, 3); % By rib index
    
    % Reverse nodes, find unique indices based on rib index, and reverse back
    [~, unique_current_idx] = unique(flipud(current_stringer_nodes(:, 3)), 'first');
    [~, unique_next_idx] = unique(flipud(next_stringer_nodes(:, 3)), 'first');
    
    % Correct the order of indices
    unique_current_idx = size(current_stringer_nodes, 1) + 1 - unique_current_idx;
    unique_next_idx = size(next_stringer_nodes, 1) + 1 - unique_next_idx;
    
    % Select the unique rows
    current_stringer_nodes = current_stringer_nodes(unique_current_idx, :);
    next_stringer_nodes = next_stringer_nodes(unique_next_idx, :);

    % Filter nodes within the rib range
    current_stringer_nodes = current_stringer_nodes(...
        current_stringer_nodes(:, 3) >= start_rib & current_stringer_nodes(:, 3) <= end_rib, :);
    
    next_stringer_nodes = next_stringer_nodes(...
        next_stringer_nodes(:, 3) >= start_rib & next_stringer_nodes(:, 3) <= end_rib, :);

    % save(current_stringer_nodes, 'vector'); % Save the vector to the .mat file
    % save(next_stringer_nodes, 'vector'); % Save the vector to the .mat file
    save('current_stringer_nodes.mat', 'current_stringer_nodes');
    save('next_stringer_nodes.mat', 'next_stringer_nodes');

    % Ensure sufficient nodes exist after filtering
    num_ribs = min(size(current_stringer_nodes, 1), size(next_stringer_nodes, 1));
    if num_ribs < 2
        warnings{end+1} = 'Not enough valid nodes to create quadrilateral surfaces.';
        return;
    end
    
    % Loop through ribs to create quadrilaterals
    for i = 1:num_ribs - 1
        node1 = current_stringer_nodes(i, :);
        node2 = current_stringer_nodes(i+1, :);
        node3 = next_stringer_nodes(i, :);
        node4 = next_stringer_nodes(i+1, :);
        
        % Check geometric constraints
        if node1(3) < start_rib || node2(3) > end_rib
            warnings{end+1} = sprintf('Skipping rib pair %d-%d due to range constraints.', node1(3), node2(3));
            continue;
        end
        
        % Validate distances
        dist12 = norm(node1(1:2) - node2(1:2));
        dist34 = norm(node3(1:2) - node4(1:2));
        
        if dist12 > threshold_distance && dist34 > threshold_distance
            quad_surfaces = [quad_surfaces; node1(5), node2(5), node3(5), node4(5)];
        else
            warnings{end+1} = sprintf('Node spacing below threshold at rib pair %d-%d.', node1(3), node2(3));
        end
    end

    
    disp('✅ Normal quadrilateral surfaces created successfully.');
end
