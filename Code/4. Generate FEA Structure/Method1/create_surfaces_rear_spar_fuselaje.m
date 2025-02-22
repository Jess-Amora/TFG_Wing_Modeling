function [quad_surfaces, warnings] = create_surfaces_rear_spar_fuselaje(combined_nodes_fuselaje, combined_nodes, start_rib)
% CREATE_SURFACES_REAR_SPAR_FUSELAJE - Generates quadrilateral surfaces for the fuselage rear spar.
%
% Inputs:
%   combined_nodes_fuselaje - Table containing fuselage node data.
%   combined_nodes          - Table containing all structure nodes.
%   start_rib               - Starting rib index for surface generation.
%
% Outputs:
%   quad_surfaces           - Table with quadrilateral surface data.
%   warnings                - Cell array with warnings about skipped surfaces.

    %% 🔹 Initialization
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = filter_nodes_by_stringer(combined_nodes_fuselaje, 1);

    if isempty(current_stringer_nodes)
        warnings{end+1} = sprintf('No valid nodes found for stringer %d.', 1);
        return;
    end

    %% 🔄 Create Quadrilateral Surfaces for Fuselage Rear Spar
    num_ribs = height(current_stringer_nodes) - 1;
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', 1);
        return;
    end

    for i = 1:num_ribs - 1
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            extract_node_by_tag(combined_nodes_fuselaje, 'rear spars fuselaje', i), current_stringer_nodes(i, :), ...
            current_stringer_nodes(i + 1, :), extract_node_by_tag(combined_nodes_fuselaje, 'rear spars fuselaje', i + 1), ...
            -2, 1, i, i + 1, surface_counter, "quad fuselaje rear");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i];
        surface_counter = surface_counter + 1;
    end

    %% 🔗 Connect Fuselage Rear Spar to Wing Root
    [quad_surface_root, warnings_i] = create_quad_surface_entry( ...
        extract_node_by_tag(combined_nodes_fuselaje, 'rear spars fuselaje', num_ribs), ...
        current_stringer_nodes(num_ribs, :), ...
        extract_node(combined_nodes, -1, 1), ...
        extract_node_by_tag(combined_nodes, 'rear spars', start_rib), ...
        -2, 1, num_ribs, -1, surface_counter, "quad fuselaje rear root");

    quad_surfaces = [quad_surfaces; quad_surface_root];
    warnings = [warnings; warnings_i];
end
function nodes = filter_nodes_by_stringer(combined_nodes, stringer_index)
% FILTER_NODES_BY_STRINGER - Retrieves nodes for a given stringer.
    nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
end
function node = extract_node(combined_nodes, rib_index, stringer_index)
% EXTRACT_NODE - Retrieves a node at a given rib & stringer index.
    node = combined_nodes(combined_nodes.rib_index == rib_index & combined_nodes.stringer_index == stringer_index, :);
end
function node = extract_node_by_tag(combined_nodes, tag, rib_index)
% EXTRACT_NODE_BY_TAG - Retrieves a node with a given tag at a specified rib index.
    node = combined_nodes(strcmp(combined_nodes.tag, tag) & combined_nodes.rib_index == rib_index, :);
end
