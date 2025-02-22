function [new_surface, is_valid_surface, warnings] = create_quad_surface_entry(...
    node_1, node_2, node_3, node_4, stringer_1, stringer_2, rib_1, rib_2, surface_counter, tag)
% CREATE_QUAD_SURFACE_ENTRY - Generates a quadrilateral surface entry.
%
% Inputs:
%   node_1, node_2, node_3, node_4 - Table rows representing the 4 corner nodes.
%   stringer_1, stringer_2 - Indices of the stringers defining the surface.
%   rib_1, rib_2 - Rib indices defining the surface.
%   surface_counter - Unique ID for this surface.
%   tag - Label for surface classification (e.g., 'quad regular').
%
% Outputs:
%   new_surface - Table row for the quadrilateral surface.
%   is_valid_surface - Boolean indicating if the surface is valid.
%   warnings - Cell array containing any warnings.

    warnings = {};
    is_valid_surface = true;

    % ✅ Ensure nodes are not empty
    if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
        warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', rib_1);
        is_valid_surface = false;
        new_surface = table();
        return;
    end

    % ✅ Extract coordinates for surface property calculation
    surface_coords = [
        node_1.x(1), node_1.y(1);
        node_2.x(1), node_2.y(1);
        node_3.x(1), node_3.y(1);
        node_4.x(1), node_4.y(1)
    ];

    % ✅ Compute area and aspect ratio
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

    if ~is_valid
        warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', rib_1, rib_2);
        is_valid_surface = false;
        new_surface = table();
        return;
    end

    % ✅ Create the quadrilateral surface entry
    new_surface = table( ...
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
