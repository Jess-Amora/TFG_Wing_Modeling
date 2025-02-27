function [quad_surfaces, surface_counter] = create_new_surface_vertical(node_1, node_2, node_3, node_4, stringer_1, stringer_2, ...
                                                                        rib_1, rib_2, tag, h, surface_counter, quad_surfaces)
% CREATE_NEW_SURFACE_VERTICAL: Creates a new quadrilateral (quad) surface entry and appends it to the existing quad surface table.
%
% Inputs:
%   node_1, node_2, node_3, node_4 - Structs or table rows representing the four corner nodes.
%   rib_1, rib_2       - Rib indices for the first and third nodes.
%   tag                - Classification tag for the quad (e.g., 'quad vertical rib').
%   h                  - Indicates 'extrados' or 'intrados'.
%   surface_counter    - Current surface counter to assign unique IDs.
%   quad_surfaces      - Existing quad surface table to append the new surface.
%
% Outputs:
%   quad_surfaces      - Updated quad surface table with the new entry.
%   surface_counter    - Updated surface counter after adding the new surface.

    %% 🟢 Validate Nodes
    if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
        warning('Skipping quad surface creation due to missing nodes.');
        return;
    end

    %% 🔄 Extract Node Coordinates
    surface_coords = [
        node_1.x, node_1.y, node_1.z;
        node_2.x, node_2.y, node_2.z;
        node_3.x, node_3.y, node_3.z;
        node_4.x, node_4.y, node_4.z
    ];

    %% 📏 Compute Quad Properties
    [is_valid, aspect_ratio] = check_aspect_ratio_v2(surface_coords, 'quad');
    area = calculate_quad_area_3D(surface_coords);

    % (Optional) Handle invalid quads based on aspect ratio
    if ~is_valid
        warning('Skipping quad surface creation at rib %d-%d due to poor aspect ratio.', rib_1, rib_2);
        return;
    end

    %% 📝 Create New Quad Surface
    new_surface = table( ...
        surface_counter, ...        % local_id
        node_1.local_id, ...        % node_1
        node_2.local_id, ...        % node_2
        node_3.local_id, ...        % node_3
        node_4.local_id, ...        % node_4
        stringer_1, ...                     % stringer_1 (placeholder)
        stringer_2, ...                     % stringer_2 (placeholder)
        rib_1, ...                  % rib_1
        rib_2, ...                  % rib_2
        tag, ...                    % tag (e.g., 'quad vertical rib')
        area, ...                    % computed area
        aspect_ratio, ...            % computed aspect ratio
        h, ...                      % h (extrados or intrados)
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio', 'h'});

    %% 🔄 Append to Quad Surface Table
    quad_surfaces = [quad_surfaces; new_surface];

    %% 🔢 Increment Surface Counter
    surface_counter = surface_counter + 1;
end
