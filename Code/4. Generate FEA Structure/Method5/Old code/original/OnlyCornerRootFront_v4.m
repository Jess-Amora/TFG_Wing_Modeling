function [tri_surfaces, quad_surfaces, warnings] = OnlyCornerRootFront_v1(combined_nodes)
% Iteratively creates quadrilateral surfaces for irregular zones until the endpoint or triangle.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the irregular zone.
%
% Outputs:
%   quad_surfaces: Table with surface properties for irregular quadrilaterals.
%   warnings: Cell array with warnings about skipped or invalid surfaces.
% OnlyCornerRootFront_v1
% ----------------------
% This function assumes the existence of a single additional rib with rib_index = 0,
% representing the front spar rib. This special rib is currently the only auxiliary rib
% included in the model, apart from the regular ribs (rib_index ≥ 1) and the root rib 
% (rib_index = -1).
%
% Future Expansion:
% -----------------
% The current framework is designed to be flexible, allowing for the inclusion of more 
% auxiliary ribs (e.g., rib_index ≤ -3) in future versions. The logic can be extended to 
% handle these cases with minimal changes.
%
% Current Assumption:
% -------------------
% - rib_index = 0: Represents the front spar rib and is used for corner surface creation.
% - Only one instance of rib_index = 0 is allowed in the current implementation. If more 
%   auxiliary ribs are added in future iterations, the function will need to be updated 
%   accordingly to process them.
%
% Author: [Jess Bern Amora Ycong]
% Date: [17/01/25]

% ONLYCORNERROOTFRONT_V1 - Creates quadrilateral and triangular surfaces in the front spar region.
%
% Inputs:
%   combined_nodes - Table containing node data.
%
% Outputs:
%   tri_surfaces   - Table with triangular surface data.
%   quad_surfaces  - Table with quadrilateral surface data.
%   warnings       - Cell array with warnings about skipped surfaces.

    %% 🔹 Initialization
    tri_surfaces = tri_initialize();
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    [~, max_rib_index, max_stringer_index, rib_ranges] = analyze_stringer_rib_data(combined_nodes);
    stringer_index = max_stringer_index;
    current_stringer_nodes = filter_nodes_by_stringer(combined_nodes, stringer_index);

    %% 🏗️ Create First Quadrilateral Surface
    [quad_surfaces, warnings, surface_counter] = create_front_corner_surface( ...
        combined_nodes, current_stringer_nodes, max_rib_index, max_stringer_index, quad_surfaces, warnings, surface_counter);

    %% 🔄 Loop to Create Additional Quadrilateral Surfaces
    start_rib = determine_start_rib(current_stringer_nodes);
    for index_rib = start_rib:rib_ranges(max_stringer_index, 3) - 1
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            extract_node(current_stringer_nodes, index_rib), extract_node_by_tag(combined_nodes, 'front spars', index_rib), ...
            extract_node_by_tag(combined_nodes, 'front spars', index_rib + 1), extract_node(current_stringer_nodes, index_rib + 1), ...
            max_stringer_index, -1, index_rib, index_rib + 1, surface_counter, "quad irregular root corner");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i];
        surface_counter = surface_counter + 1;
    end

    %% 🔺 Create Final Triangular Surface
    if is_tri_surface_needed(combined_nodes, stringer_index)
        [tri_surface, warnings_i] = create_tri_surface_entry( ...
            extract_node(current_stringer_nodes, -2), extract_node(current_stringer_nodes, rib_ranges(max_stringer_index, 3)), ...
            extract_node_by_tag(combined_nodes, 'front spars', rib_ranges(max_stringer_index, 3)), ...
            max_stringer_index, -1, rib_ranges(max_stringer_index, 3), -2, surface_counter, "tri last front");

        tri_surfaces = [tri_surfaces; tri_surface];
        warnings = [warnings; warnings_i];
    end
end
function nodes = filter_nodes_by_stringer(combined_nodes, stringer_index)
% FILTER_NODES_BY_STRINGER - Retrieves nodes for a given stringer.
    nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
end
function [quad_surfaces, warnings, surface_counter] = create_front_corner_surface( ...
    combined_nodes, current_stringer_nodes, max_rib_index, max_stringer_index, quad_surfaces, warnings, surface_counter)
% CREATE_FRONT_CORNER_SURFACE - Constructs the first quadrilateral surface at the front corner.

    node_1 = extract_node(current_stringer_nodes, -1); % Bottom-left
    node_2 = extract_node_by_tag(combined_nodes, 'front spars', 1e5); % Bottom-right
    node_3 = extract_node_by_tag(combined_nodes, 'front spars', max_rib_index + 1); % Top-right
    node_4 = extract_node(current_stringer_nodes, 0); % Top-left

    node_4_empty = isempty(node_4);
    if node_4_empty
        node_4 = extract_node(current_stringer_nodes, 1);
    end

    [quad_surface, warnings_i] = create_quad_surface_entry( ...
        node_1, node_2, node_3, node_4, max_stringer_index, -1, -1, node_4_empty, surface_counter, "quad OnlyNode1");

    quad_surfaces = [quad_surfaces; quad_surface];
    warnings = [warnings; warnings_i];
    surface_counter = surface_counter + 1;
end
function start_rib = determine_start_rib(current_stringer_nodes)
% DETERMINE_START_RIB - Determines whether to start from rib 0 or 1.
    if ~isempty(extract_node(current_stringer_nodes, 0))
        start_rib = 0;
    else
        start_rib = 1;
    end
end
function node = extract_node(nodes, rib_index)
% EXTRACT_NODE - Retrieves a node at a given rib index.
    node = nodes(nodes.rib_index == rib_index, :);
end
function node = extract_node_by_tag(combined_nodes, tag, rib_index)
% EXTRACT_NODE_BY_TAG - Retrieves a node with a given tag at a specified rib index.
    node = combined_nodes(strcmp(combined_nodes.tag, tag) & combined_nodes.rib_index == rib_index, :);
end
function is_needed = is_tri_surface_needed(combined_nodes, stringer_index)
% IS_TRI_SURFACE_NEEDED - Determines if a final triangular surface is necessary.
    [num_stringers_last_rib, ~, ~, ~] = analyze_stringer_rib_data(combined_nodes);
    is_needed = num_stringers_last_rib ~= stringer_index;
end
