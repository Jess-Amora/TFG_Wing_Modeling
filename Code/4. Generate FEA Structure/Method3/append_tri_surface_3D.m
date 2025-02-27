function [tri_surfaces, warnings] = append_tri_surface_3D(tri_surfaces, warnings, surface_counter, ...
                                                           node_1, node_2, node_3, ...
                                                           stringer_1, stringer_2, rib_1, rib_2, tag)
    % Appends a triangular surface to the tri_surfaces table.
    % Handles error checking, area, and aspect ratio calculations.

    % 🚨 **Check if any node is missing**
    if isempty(node_1) || isempty(node_2) || isempty(node_3)
        warning_msg = sprintf('Skipping triangular surface %d due to missing nodes.', surface_counter);
        warnings{end+1} = warning_msg;
        warning(warning_msg);
        return;
    end

    %% 📐 Compute Triangular Surface Properties
    % 🔹 Extract **coordinates** for the triangle
    surface_coords = [
        node_1.x, node_1.y;
        node_2.x, node_2.y;
        node_3.x, node_3.y
    ];

    % 🔹 Compute **area** of the triangle
    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

    % 🔹 Compute **aspect ratio**
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');

    % % 🚨 **Check for poor aspect ratio**
    % if ~is_valid
    %     warning_msg = sprintf('Skipping triangular surface %d due to poor aspect ratio.', surface_counter);
    %     warnings{end+1} = warning_msg;
    %     warning(warning_msg);
    %     return;
    % end

    %% 📝 Append the New Surface to the Table
    new_surface = table( ...
        surface_counter, ...
        node_1.local_id, node_2.local_id, node_3.local_id, ...
        stringer_1, stringer_2, rib_1, rib_2, {tag}, area, aspect_ratio, ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});

    % 🔹 Append to the existing table
    tri_surfaces = [tri_surfaces; new_surface];

end
