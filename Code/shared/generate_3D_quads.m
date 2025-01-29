function quad_surfaces_3D = generate_3D_quads(quad_surfaces_2D, combined_nodes_3D, H)
% GENERATE_3D_QUADS Converts 2D quadrilateral elements into 3D extrados and intrados elements.
%
%   quad_surfaces_3D = generate_3D_quads(quad_surfaces_2D, combined_nodes_3D, H)
%
%   Inputs:
%       quad_surfaces_2D  - Table of 2D quadrilateral elements.
%                           Columns: {'local_id', 'node_1', 'node_2', 'node_3', 'node_4',
%                                     'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags',
%                                     'area', 'aspect_ratio'}
%
%       combined_nodes_3D - Table of 3D nodes from generate_3D_nodes().
%                           Includes 'local_id', 'x', 'y', 'z', 'rib_index',
%                           'stringer_index', 'tag', 'h'.
%
%       H                - Total thickness of the structure.
%
%   Output:
%       quad_surfaces_3D  - Table of 3D quadrilateral elements.
%                           Includes a new column 'h' for surface type ('extrados' or 'intrados').
%
%   Example:
%       % Generate 3D quads
%       quad_surfaces_3D = generate_3D_quads(quad_surfaces_2D, combined_nodes_3D, 0.02);
%
%   -------------------------------------------------------------------------
%   Author: Jess Bern Amora Ycong
%   Date:   29-Jan-2025
%   -------------------------------------------------------------------------

    %% 1. Handle edge cases
    if isempty(quad_surfaces_2D)
        warning('Input 2D quad table is empty. Returning an empty table.');
        quad_surfaces_3D = table([], [], [], [], [], [], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio', 'h'});
        return;
    end

    %% 2. Initialize storage for extrados and intrados quads
    numQuads = height(quad_surfaces_2D);
    extrados_quads = quad_surfaces_2D;  % Copy the structure
    intrados_quads = quad_surfaces_2D;  % Copy the structure

    %% 3. Process each quad to find corresponding 3D nodes
    for i = 1:numQuads
        % Extract 2D quad data
        quad_ID = quad_surfaces_2D.local_id(i);
        nodes_2D = [quad_surfaces_2D.node_1(i), quad_surfaces_2D.node_2(i), ...
                    quad_surfaces_2D.node_3(i), quad_surfaces_2D.node_4(i)];

        % Find corresponding 3D node IDs for extrados and intrados
        nodes_extrados = zeros(1, 4);
        nodes_intrados = zeros(1, 4);

        for j = 1:4
            % Find corresponding 3D node in combined_nodes_3D
            idx = combined_nodes_3D.local_id == nodes_2D(j);
            
            % Find extrados and intrados nodes
            nodes_extrados(j) = combined_nodes_3D.local_id(idx & (combined_nodes_3D.h == "extrados"));
            nodes_intrados(j) = combined_nodes_3D.local_id(idx & (combined_nodes_3D.h == "intrados"));
        end

        % Assign new node IDs to extrados and intrados quads
        extrados_quads.node_1(i) = nodes_extrados(1);
        extrados_quads.node_2(i) = nodes_extrados(2);
        extrados_quads.node_3(i) = nodes_extrados(3);
        extrados_quads.node_4(i) = nodes_extrados(4);
        extrados_quads.h(i) = "extrados";  % Mark as extrados

        intrados_quads.node_1(i) = nodes_intrados(1);
        intrados_quads.node_2(i) = nodes_intrados(2);
        intrados_quads.node_3(i) = nodes_intrados(3);
        intrados_quads.node_4(i) = nodes_intrados(4);
        intrados_quads.h(i) = "intrados";  % Mark as intrados

        % Adjust local_id for intrados to maintain uniqueness
        intrados_quads.local_id(i) = quad_ID + numQuads;
    end

    %% 4. Combine extrados and intrados quads
    quad_surfaces_3D = [extrados_quads; intrados_quads];

end
