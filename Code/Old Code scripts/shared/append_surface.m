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