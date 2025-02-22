function [quad_surfaces, warnings] = create_surfaces_front_spar_fuselaje(combined_nodes_fuselaje, combined_nodes)
% CREATE_SURFACES_FRONT_SPAR_FUSELAJE - Generates quadrilateral surfaces for the front spar fuselage.
%
% Inputs:
%   combined_nodes_fuselaje - Table containing fuselage node data.
%   combined_nodes          - Table containing all structure nodes.
%
% Outputs:
%   quad_surfaces           - Table with quadrilateral surface data.
%   warnings                - Cell array with warnings about skipped surfaces.

    %% 🔹 Initialization
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    [~, ~, max_stringer, ~] = analyze_stringer_rib_data(combined_nodes);
    current_stringer_nodes = filter_nodes_by_stringer(combined_nodes_fuselaje, max_stringer);

    if isempty(current_stringer_nodes)
        warnings{end+1} = sprintf('No valid nodes found for stringer %d.', max_stringer);
        return;
    end

    %% 🔄 Create Quadrilateral Surfaces Along the Front Spar
    num_ribs = height(current_stringer_nodes) - 1;
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', max_stringer);
        return;
    end

    for i = 1:num_ribs - 1
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            current_stringer_nodes(i, :), ...
            extract_node(combined_nodes_fuselaje, i, 'front spars fuselaje'), ...
            extract_node(combined_nodes_fuselaje, i + 1, 'front spars fuselaje'), ...
            current_stringer_nodes(i + 1, :), ...
            max_stringer, -1, ...
            current_stringer_nodes(i, :).rib_index, ...
            extract_node(combined_nodes_fuselaje, i + 1, 'front spars fuselaje').rib_index, ...
            surface_counter, "quad fuselaje front");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i];
        surface_counter = surface_counter + 1;
    end

    %% 🔗 Connect Fuselage Stringer to Wing Root
    [quad_surface_root, warnings_i] = create_quad_surface_entry( ...
        current_stringer_nodes(num_ribs, :), ...
        extract_node(combined_nodes_fuselaje, num_ribs, 'front spars fuselaje'), ...
        extract_node(combined_nodes, 1e5, 'front spars'), ...
        extract_node(combined_nodes, -1, max_stringer), ...
        max_stringer, -1, num_ribs, -1, ...
        surface_counter, "quad fuselaje front root");

    quad_surfaces = [quad_surfaces; quad_surface_root];
    warnings = [warnings; warnings_i];
end
function nodes = filter_nodes_by_stringer(combined_nodes, stringer_index)
% FILTER_NODES_BY_STRINGER - Retrieves nodes for a given stringer.
    nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
end
function node = extract_node(combined_nodes, rib_index, tag)
% EXTRACT_NODE - Retrieves a node at a given rib index and tag.
    % node = combined_nodes(combined_nodes.rib_index == rib_index & combined_nodes.tag == tag, :);
    node = combined_nodes(combined_nodes.rib_index == rib_index & strcmp(combined_nodes.tag,tag), :);
end
