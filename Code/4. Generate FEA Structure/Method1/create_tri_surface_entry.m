function [tri_entry, warnings] = create_tri_surface_entry(node_1, node_2, node_3, ...
                                                          stringer_1, stringer_2, rib_1, rib_2, ...
                                                          surface_counter, tri_tag)
% CREATE_TRI_SURFACE_ENTRY - Standardized function to create a triangular surface entry.
%
% Inputs:
%   node_1, node_2, node_3 - Node table rows representing triangle vertices.
%   stringer_1, stringer_2 - Stringer indices associated with the surface.
%   rib_1, rib_2           - Rib indices defining the surface.
%   surface_counter        - Unique ID for the surface.
%   tri_tag                - Descriptive tag for the triangle (e.g., "tri front").
%
% Outputs:
%   tri_entry - A single row table containing the triangle surface entry.
%   warnings  - Cell array with warnings if any issues are found.

    %% 📝 Initialize Warnings
    warnings = {}; 

    %% 🔍 Validate Nodes
    if isempty(node_1) || isempty(node_2) || isempty(node_3)
        warnings{end+1} = sprintf('Skipping triangular surface due to missing nodes.');
        tri_entry = tri_initialize(); % Return an empty entry
        return;
    end

    %% 📐 Compute Surface Properties
    surface_coords = [
        node_1.x, node_1.y;
        node_2.x, node_2.y;
        node_3.x, node_3.y
    ];

    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');

    if ~is_valid
        warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio.');
        tri_entry = tri_initialize(); % Return an empty entry
        return;
    end

    %% ✅ Create the Triangular Surface Entry
    tri_entry = table( ...
        surface_counter, ...             % local_id
        node_1.local_id, ...             % node_1
        node_2.local_id, ...             % node_2
        node_3.local_id, ...             % node_3
        stringer_1, ...                  % stringer_1
        stringer_2, ...                  % stringer_2
        rib_1, ...                       % rib_1
        rib_2, ...                       % rib_2
        tri_tag, ...                     % tag
        area, ...                        % area
        aspect_ratio, ...                % aspect_ratio
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});
end
