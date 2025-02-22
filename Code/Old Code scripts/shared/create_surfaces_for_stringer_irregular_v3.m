function [quad_surfaces, tri_surfaces, warnings] = create_surfaces_for_stringer_irregular_v3(...
    combined_nodes, stringer_index, start_rib, threshold_distance)
% Handles surface creation for irregular zones between stringers.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the irregular zone.
%   threshold_distance: Minimum distance threshold for surface validity.
%
% Outputs:
%   quad_surfaces: Table with columns:
%       - local_id, node_1, node_2, node_3, node_4: Local node IDs defining the surface.
%       - stringer_1, stringer_2, rib_1, rib_2: Indices defining the surface.
%       - tags: Surface type (e.g., 'quad irregular').
%       - area, aspect_ratio: Precomputed surface properties.
%   tri_surfaces: Table with similar structure but with NaN for node_4.
%   warnings: Cell array with warnings.

    %% 📝 Initialization
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    tri_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index & ...
        combined_nodes.rib_index >= start_rib, :);

    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1 & ...
        combined_nodes.rib_index >= start_rib, :);
    
    % Check for the endpoint node (rib_index = -2) in the next stringer
    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                               combined_nodes.rib_index == -2, :);
    
    % Append the endpoint node to next_stringer_nodes if it exists
    if ~isempty(end_point)
        next_stringer_nodes = [next_stringer_nodes; end_point];
    end

    % Extract front spar nodes from combined_nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    % Append front spar nodes to next stringer nodes
    if ~isempty(next_stringer_nodes)
        last_rib_index = max(next_stringer_nodes.rib_index);
        additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);
        next_stringer_nodes = [next_stringer_nodes; additional_nodes];
    end

    %% 🔄 Loop Through Ribs to Create Quadrilateral Surfaces
    for rib_idx = start_rib:max(current_stringer_nodes.rib_index) - 1
        % Extract nodes for the current rib
        node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == rib_idx, :);        % Bottom-left
        node_2 = current_stringer_nodes(current_stringer_nodes.rib_index == rib_idx + 1, :);    % Top-left
        node_3 = next_stringer_nodes(next_stringer_nodes.rib_index == rib_idx + 1, :);          % Top-right
        node_4 = next_stringer_nodes(next_stringer_nodes.rib_index == rib_idx, :);              % Bottom-right

        % Validate nodes
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', rib_idx, rib_idx + 1);
            continue;
        end

        % Extract coordinates for surface property calculation
        surface_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y;
            node_4.x, node_4.y
        ];
        size(surface_coords)
        rib_idx
        stringer_index
        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', rib_idx, rib_idx + 1);
            continue;
        end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Append surface to quad_surfaces
        quad_surfaces = [quad_surfaces; table( ...
            surface_counter, ...        % local_id
            node_1.local_id, ...        % node_1
            node_4.local_id, ...        % node_2
            node_3.local_id, ...        % node_3
            node_2.local_id, ...        % node_4
            stringer_index, ...         % stringer_1
            stringer_index + 1, ...     % stringer_2
            rib_idx, ...                % rib_1
            rib_idx + 1, ...            % rib_2
            "quad irregular", ...       % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'})];

        surface_counter = surface_counter + 1;
    end

    %% 🔺 Handle Triangular Surface at the End
    triangle_node = next_stringer_nodes(next_stringer_nodes.rib_index == -2, :); % Node at the front spar
    if ~isempty(triangle_node) && size(current_stringer_nodes, 1) >= 2
        % Define nodes for the triangle
        node_1 = current_stringer_nodes(end-1, :); % Bottom-left
        node_2 = current_stringer_nodes(end, :);   % Bottom-right
        node_3 = triangle_node;                    % Apex at the front spar

        % Extract coordinates
        tri_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y
        ];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(tri_coords, 'triangle');
        if ~is_valid
            warnings{end+1} = 'Skipped triangle due to poor aspect ratio.';
            return;
        end
        area = polyarea(tri_coords(:, 1), tri_coords(:, 2));

        % Append surface to tri_surfaces
        tri_surfaces = [tri_surfaces; table( ...
            surface_counter, ...        % local_id
            node_1.local_id, ...        % node_1
            node_2.local_id, ...        % node_2
            node_3.local_id, ...        % node_3
            NaN, ...                    % node_4
            stringer_index, ...         % stringer_1
            NaN, ...                    % stringer_2
            node_1.rib_index, ...       % rib_1
            NaN, ...                    % rib_2
            "tri", ...                  % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'})];
    end

    %% ✅ Success Message
    disp('✅ Irregular quadrilateral and triangular surfaces created successfully.');
end
