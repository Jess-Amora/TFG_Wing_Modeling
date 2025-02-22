function [quad_surfaces, warnings] = create_surfaces_stringer_fuselaje_v1(combined_nodes_fuselaje, combined_nodes, stringer_index)
% CREATE_SURFACES_STRINGER_FUSELAJE_V1 - Generates quadrilateral surfaces for fuselage stringers.
%
% Inputs:
%   combined_nodes_fuselaje - Table containing fuselage node data.
%   combined_nodes          - Table containing all structure nodes.
%   stringer_index          - Index of the stringer being processed.
%
% Outputs:
%   quad_surfaces           - Table with quadrilateral surface data.
%   warnings                - Cell array with warnings about skipped surfaces.

    %% 🔹 Initialization
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = filter_nodes_by_stringer(combined_nodes_fuselaje, stringer_index);
    next_stringer_nodes = filter_nodes_by_stringer(combined_nodes_fuselaje, stringer_index + 1);

    if isempty(current_stringer_nodes) || isempty(next_stringer_nodes)
        warnings{end+1} = sprintf('No valid nodes found for stringer %d and its neighbor.', stringer_index);
        return;
    end

    %% 🔄 Create Quadrilateral Surfaces Along the Stringers
    num_ribs = min(height(current_stringer_nodes), height(next_stringer_nodes)) - 1;
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', stringer_index);
        return;
    end

    for i = 1:num_ribs - 1
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            current_stringer_nodes(i, :), next_stringer_nodes(i, :), ...
            next_stringer_nodes(i + 1, :), current_stringer_nodes(i + 1, :), ...
            stringer_index, stringer_index + 1, current_stringer_nodes(i, :).rib_index, ...
            next_stringer_nodes(i + 1, :).rib_index, surface_counter, "quad fuselaje");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i];
        surface_counter = surface_counter + 1;
    end

    %% 🔗 Connect Fuselage Stringer to Wing Root
    [quad_surface_root, warnings_i] = create_quad_surface_entry( ...
        current_stringer_nodes(num_ribs, :), next_stringer_nodes(num_ribs, :), ...
        extract_node(combined_nodes, -1, stringer_index + 1), ...
        extract_node(combined_nodes, -1, stringer_index), ...
        stringer_index, stringer_index + 1, current_stringer_nodes(num_ribs, :).rib_index, ...
        -1, surface_counter, "quad fuselaje root");

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
