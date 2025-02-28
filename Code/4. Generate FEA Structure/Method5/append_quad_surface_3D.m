function [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                                     node1, node2, node3, node4, ...
                                                                                     stringer_1, stringer_2, rib_1, rib_2)
    % Appends a quadrilateral surface to the quad_surfaces table
    % Takes four separate nodes instead of a node array
    % Includes warnings and additional information for skipped surfaces

    % Initialize warning table
    warning_surface = quad_initialize();  % Assuming this function initializes an empty table

    % Check if any of the four nodes are missing
    if isempty(node1) || isempty(node2) || isempty(node3) || isempty(node4)
        warning('Skipping surface %d: One or more nodes are missing.', surface_counter);
        disp(struct2table([node1, node2, node3, node4]));  % Display the problematic node data
        return;
    end

    % Extract coordinates for area and aspect ratio calculations
    surface_coords = [node1.x, node1.y; ...
                      node2.x, node2.y; ...
                      node3.x, node3.y; ...
                      node4.x, node4.y];

    % Check aspect ratio validity
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    if ~is_valid
        warning('Skipping surface %d at rib %d: Poor aspect ratio (%.2f).', surface_counter, rib_1, aspect_ratio);
        
        % Store the skipped surface in the warning table
        warning_surface = table(surface_counter, ...
            node1.local_id, node2.local_id, node3.local_id, node4.local_id, ...
            stringer_1, stringer_2, rib_1, rib_2, tag, NaN, aspect_ratio, ...
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                              'area', 'aspect_ratio'});
        return; % Skip adding this surface
    end

    % Calculate area
    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

    % Create new quadrilateral surface entry
    new_surface = table(surface_counter, ...
        node1.local_id, node2.local_id, node3.local_id, node4.local_id, ...
        stringer_1, stringer_2, rib_1, rib_2, ...
        tag, area, aspect_ratio, ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});

    % Append to the table
    quad_surfaces = [quad_surfaces; new_surface];

    % Increment surface counter
    surface_counter = surface_counter + 1;
end
