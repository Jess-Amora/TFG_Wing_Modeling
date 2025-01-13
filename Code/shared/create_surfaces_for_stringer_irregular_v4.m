function [quad_surfaces, warnings] = create_surfaces_for_stringer_irregular_v4( ...
    combined_nodes, inserted_table, stringer_index, start_rib)
% Iteratively creates quadrilateral surfaces for irregular zones until the endpoint or triangle.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the irregular zone.
%
% Outputs:
%   quad_surfaces: Table with surface properties for irregular quadrilaterals.
%   warnings: Cell array with warnings about skipped or invalid surfaces.

    %% Initialization
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
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

   % Extract inserted nodes for the current stringer
    inserted_nodes = inserted_table(inserted_table.stringer_index == stringer_index, :);

    % Extract front spar nodes from combined_nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    % Append front spar nodes to next stringer nodes
    if ~isempty(next_stringer_nodes)
        last_rib_index = max(next_stringer_nodes.rib_index);
        additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);
        next_stringer_nodes = [next_stringer_nodes; additional_nodes];
    end

    %% Create First Surface
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes) && ~isempty(end_point) && ~isempty(inserted_nodes)
        node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :); % Bottom-left
        node_2 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib & next_stringer_nodes.tag=='stringer', :);       % Bottom-right
        node_3 = end_point;                                                               % Top-right
        node_4 = inserted_nodes;                                                          % Top-left

        % Validate nodes
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
            % continue;
        end

        % Extract coordinates for surface property calculation
        surface_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y;
            node_4.x, node_4.y
        ];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
            % continue;
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
            start_rib, ...                % rib_1
            -2, ...            % rib_2
            "quad irregular P4 inserted", ...       % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'})];

        surface_counter = surface_counter + 1;
    end
    
    %% Create second Surface
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes) && ~isempty(end_point) && ~isempty(inserted_nodes)
        node_1 = inserted_nodes; % Bottom-left
        node_2 = end_point;       % Bottom-right
        node_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib+1 & next_stringer_nodes.tag=='front spars', :);                                                             % Top-right
        node_4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib+1, :);

        % Validate nodes
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
            % continue;
        end

        % Extract coordinates for surface property calculation
        surface_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y;
            node_4.x, node_4.y
        ];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
            % continue;
        end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Append surface to quad_surfaces
        quad_surfaces = [quad_surfaces; table( ...
            surface_counter, ...        % local_id
            node_1.local_id, ...        % node_1
            node_4.local_id, ...        % node_2
            node_3.local_id, ...        % node_3
            node_2.local_id, ...        % node_4
            stringer_index , ...         % stringer_1
            stringer_index + 1, ...     % stringer_2
            -2, ...                % rib_1
            start_rib+1, ...            % rib_2
            "quad irregular P1 inserted", ...       % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'})];

        surface_counter = surface_counter + 1;
    end
    %% Iterative Surface Creation


    while ~isempty(prev_P1) && ~isempty(prev_P2) && prev_P1.rib_index < -2
        % Define nodes for the current iteration
        P1 = prev_P1; % Bottom-left from the previous top-left
        P2 = prev_P2; % Bottom-right from the previous top-right
        P3 = front_spar_nodes(front_spar_nodes.rib_index == P2.rib_index + 1, :); % Top-right
        P4 = current_stringer_nodes(current_stringer_nodes.rib_index == P1.rib_index + 1, :); % Top-left

        % Stop if we reach the endpoint or no valid nodes are available
        if isempty(P3) || isempty(P4)
            warnings{end+1} = sprintf('Terminating iteration due to missing nodes at rib %d.', P1.rib_index + 1);
            break;
        end

        % Append quadrilateral surface
        quad_surfaces = append_surface(quad_surfaces, surface_counter, P1, P2, P3, P4, ...
                                       stringer_index, stringer_index + 1, P1.rib_index, P4.rib_index, "quad irregular");
        surface_counter = surface_counter + 1;

        % Update previous nodes
        prev_P1 = P4;
        prev_P2 = P3;
    end

    %% Success Message
    disp('✅ Irregular quadrilateral surfaces created successfully.');
end

%% Helper Function to Append Surfaces
function quad_surfaces = append_surface(quad_surfaces, surface_counter, P1, P2, P3, P4, ...
                                         stringer_1, stringer_2, rib_1, rib_2, tag)
    % Extract coordinates
    surface_coords = [
        P1.x, P1.y;
        P2.x, P2.y;
        P3.x, P3.y;
        P4.x, P4.y
    ];

    % Compute area and aspect ratio
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    if ~is_valid
        warnings{end+1} = sprintf('Skipped surface due to poor aspect ratio at rib pair %d-%d.', rib_1, rib_2);
        return;
    end
    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

    % Append to surfaces table
    quad_surfaces = [quad_surfaces; table( ...
        surface_counter, ...    % local_id
        P1.local_id, ...        % node_1
        P2.local_id, ...        % node_2
        P3.local_id, ...        % node_3
        P4.local_id, ...        % node_4
        stringer_1, ...         % stringer_1
        stringer_2, ...         % stringer_2
        rib_1, ...              % rib_1
        rib_2, ...              % rib_2
        tag, ...                % tags
        area, ...               % area
        aspect_ratio, ...       % aspect_ratio
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'})];
end
