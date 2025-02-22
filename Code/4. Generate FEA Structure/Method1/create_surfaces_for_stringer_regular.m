function [quad_surfaces, warnings] = create_surfaces_for_stringer_regular(...
    combined_nodes, stringer_index, start_rib, end_rib)
% Handles general surface creation between two stringers for regular zones.

    %% 📝 Initialization
    quad_surfaces = quad_initialize(); % Use your initialized table function
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
        % ✅ Call the helper function to generate the quad surface
        [new_surface, is_valid_surface, warn] = create_quad_surface_entry(...
            current_stringer_nodes(i, :), ...
            next_stringer_nodes(i, :), ...
            next_stringer_nodes(i + 1, :), ...
            current_stringer_nodes(i + 1, :), ...
            stringer_index, ...
            stringer_index + 1, ...
            current_stringer_nodes.rib_index(i), ...
            next_stringer_nodes.rib_index(i + 1), ...
            surface_counter, ...
            "quad regular");

        % ✅ Handle warnings
        warnings = [warnings; warn(:)];

        % ✅ Append valid surfaces
        if is_valid_surface
            quad_surfaces = [quad_surfaces; new_surface];
            surface_counter = surface_counter + 1;
        end
    end
end
