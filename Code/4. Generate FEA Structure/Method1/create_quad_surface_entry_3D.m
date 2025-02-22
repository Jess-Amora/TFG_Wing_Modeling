function [quad_surface, warnings] = create_quad_surface_entry_3D(node_1, node_2, node_3, node_4, ...
                                                                stringer_1, stringer_2, rib_1, rib_2, ...
                                                                surface_counter, tag)
% CREATE_QUAD_SURFACE_ENTRY_3D - Creates a single 3D quadrilateral surface entry.
    warnings = {};

    % Validate nodes
    if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
        warnings{end+1} = sprintf('⚠️ Skipping quadrilateral surface due to missing nodes at rib %d.', rib_1);
        quad_surface = table(); % Return empty table if invalid
        return;
    end

    % Extract coordinates for surface property calculation
    surface_coords = [
        node_1.x, node_1.y, node_1.z;
        node_2.x, node_2.y, node_2.z;
        node_3.x, node_3.y, node_3.z;
        node_4.x, node_4.y, node_4.z
    ];

    % Compute area and aspect ratio
    area = calculate_quad_area_3D(surface_coords);
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    
    if ~is_valid
        warnings{end+1} = sprintf('⚠️ Skipped quadrilateral due to poor aspect ratio at rib %d.', rib_1);
        quad_surface = table(); % Return empty table if invalid
        return;
    end

    % Append surface to table
    quad_surface = table( ...
        surface_counter, ...        % local_id
        node_1.local_id, ...        % node_1
        node_2.local_id, ...        % node_2
        node_3.local_id, ...        % node_3
        node_4.local_id, ...        % node_4
        stringer_1, ...             % stringer_1
        stringer_2, ...             % stringer_2
        rib_1, ...                  % rib_1
        rib_2, ...                  % rib_2
        tag, ...                    % tag
        area, ...                   % area
        aspect_ratio, ...           % aspect_ratio
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});
end
