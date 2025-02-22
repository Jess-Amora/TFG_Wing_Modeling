function [quad_surfaces, tri_surfaces, warnings] = create_surfaces_for_stringer_irregular_v2(...
    current_stringer_nodes, next_stringer_nodes, threshold_distance, start_rib)
    % Handles surface creation for irregular zones between stringers
    %
    % Outputs:
    %   quad_surfaces: Mx12 matrix for quadrilateral surfaces.
    %   tri_surfaces: Nx12 matrix for triangular surfaces.
    %   warnings: Cell array with warnings.

    %% Initialization
    quad_surfaces = [];
    tri_surfaces = [];
    warnings = {};

    % Define aspect ratio threshold
    aspect_ratio_threshold = 3.0;

    %% Convert next_stringer_nodes to Numeric Matrix if Table
    if istable(next_stringer_nodes)
        next_stringer_nodes = [next_stringer_nodes.x, next_stringer_nodes.y, ...
                               next_stringer_nodes.rib_index, next_stringer_nodes.stringer_index, ...
                               next_stringer_nodes.local_id];
    end

    %% Main Loop for Surface Creation
    for i = start_rib:size(current_stringer_nodes, 1) - 1
        quad_nodes = [
            current_stringer_nodes(i, :);
            current_stringer_nodes(i+1, :);
            next_stringer_nodes(i+1, :);
            next_stringer_nodes(i, :)
        ];

        % Calculate surface properties
        [area, aspect_ratio] = calculate_surface_properties(quad_nodes(:, 1:2), 'quad');

        if aspect_ratio <= aspect_ratio_threshold
            quad_surfaces = [quad_surfaces; i, quad_nodes(:, 5)', ...
                quad_nodes(1, 4), quad_nodes(2, 4), quad_nodes(1, 3), quad_nodes(2, 3), ...
                "quad irregular", area, aspect_ratio];
        else
            warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio: %.2f', aspect_ratio);
        end
    end

    %% Handle Triangular Zone at the End
    if any(next_stringer_nodes(:, 3) == -2)
        tri_nodes = [
            current_stringer_nodes(end-1:end, 1:2);
            next_stringer_nodes(next_stringer_nodes(:, 3) == -2, 1:2)
        ];

        [area, aspect_ratio] = calculate_surface_properties(tri_nodes, 'triangle');

        if aspect_ratio <= aspect_ratio_threshold
            tri_surfaces = [ size(quad_surfaces, 1) + 1, tri_nodes(:, 5)', ...
                tri_nodes(1, 4), NaN, tri_nodes(1, 3), NaN, ...
                "tri", area, aspect_ratio];
        else
            warnings{end+1} = sprintf('Skipped triangle due to poor aspect ratio: %.2f', aspect_ratio);
        end
    end
end
