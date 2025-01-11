function [quad_surfaces, warnings] = create_surfaces_for_stringer_regular_v3(...
    combined_nodes, stringer_index, start_rib, end_rib, threshold_distance)
% Handles general surface creation between two stringers for regular zones.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the region.
%   end_rib: Ending rib index for the region.
%   threshold_distance: Minimum distance threshold for surface validity.
%
% Outputs:
%   quad_surfaces: Table with columns:
%       - local_id: Unique surface identifier.
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface.
%       - stringer_1, stringer_2: Stringer indices defining the surface.
%       - rib_1, rib_2: Rib indices defining the surface.
%       - tags: Surface type (e.g., 'quad regular').
%       - area: Precomputed area of the surface.
%       - aspect_ratio: Aspect ratio of the surface.
%   warnings: Cell array with warnings.

    %% 📝 Initialization
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    warnings = {};
    surface_counter = 1;

    %% 🔍 Filter Nodes by Stringer and Rib
    current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index & ...
                                             combined_nodes.rib_index >= start_rib & ...
                                             combined_nodes.rib_index <= end_rib, :);
    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                                          combined_nodes.rib_index >= start_rib & ...
                                          combined_nodes.rib_index <= end_rib, :);

    % Debug: Check filtered nodes
    if isempty(current_stringer_nodes) || isempty(next_stringer_nodes)
        warnings{end+1} = sprintf('No valid nodes found for stringer %d and its neighbor.', stringer_index);
        return;
    end

    %% 🔄 Loop Through Nodes to Create Surfaces
    num_ribs = min(height(current_stringer_nodes), height(next_stringer_nodes)) - 1;
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', stringer_index);
        return;
    end

    for i = 1:num_ribs
        % Extract nodes for the quadrilateral
        node_1 = current_stringer_nodes(i, :);          % Bottom-left
        node_4 = current_stringer_nodes(i + 1, :);      % Top-left
        node_3 = next_stringer_nodes(i + 1, :);         % Top-right
        node_2 = next_stringer_nodes(i, :);             % Bottom-right

        % Ensure nodes are not empty
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', start_rib + i - 1);
            continue;
        end
        % 
        % % Validate distances
        % dist12 = norm([node_1.x - node_2.x, node_1.y - node_2.y]);
        % dist34 = norm([node_3.x - node_4.x, node_3.y - node_4.y]);
        % if dist12 > threshold_distance || dist34 > threshold_distance
        %     warnings{end+1} = sprintf('Node spacing exceeds threshold at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
        %     continue;
        % end

        % Extract coordinates for surface property calculation
        surface_coords = [
            node_1.x(1), node_1.y(1);
            node_2.x(1), node_2.y(1);
            node_3.x(1), node_3.y(1);
            node_4.x(1), node_4.y(1)
        ];
        % 
        % % Calculate Area and Aspect Ratio
        % surface_coords = [rear_spar_rib1.x(1), rear_spar_rib1.y(1); ...
        %                   stringer_rib1.x(1), stringer_rib1.y(1); ...
        %                   stringer_rib2.x(1), stringer_rib2.y(1); ...
        %                   rear_spar_rib2.x(1), rear_spar_rib2.y(1)];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        % if ~is_valid
        %     warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
        %     continue;
        % end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Append surface to table
        new_surface = table( ...
            surface_counter, ...        % local_id
            node_1.local_id, ...        % node_1
            node_2.local_id, ...        % node_2
            node_3.local_id, ...        % node_3
            node_4.local_id, ...        % node_4
            stringer_index, ...         % stringer_1
            stringer_index + 1, ...     % stringer_2
            node_1.rib_index, ...       % rib_1
            node_2.rib_index, ...       % rib_2
            "quad regular", ...         % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'});
        quad_surfaces = [quad_surfaces; new_surface];

        % Increment surface counter
        surface_counter = surface_counter + 1;
    end

    %% ✅ Success Message
    % disp('✅ Regular quadrilateral surfaces created successfully.');
end
