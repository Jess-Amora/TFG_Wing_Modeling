function [quad_surfaces, tri_surfaces, warnings, combined_nodes] = create_surfaces_for_stringer_irregular( ...
    combined_nodes, stringer_index, start_rib, geometria, datosEstructural)
% CREATE_SURFACES_FOR_STRINGER_IRREGULAR - Generates irregular quadrilateral and triangular surfaces.
%
% Inputs:
%   combined_nodes   - Table containing node information.
%   stringer_index   - Index of the current stringer.
%   start_rib        - Starting rib index for the irregular zone.
%   geometria        - Geometric parameters of the aircraft.
%   datosEstructural - Structural parameters of the aircraft.
%
% Outputs:
%   quad_surfaces    - Table of irregular quadrilateral surfaces.
%   tri_surfaces     - Table of irregular triangular surfaces.
%   warnings         - Cell array containing warnings.
%   combined_nodes   - Updated node table with inserted nodes.

    %% 📝 Initialize
    quad_surfaces = quad_initialize();
    tri_surfaces = tri_initialize();
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = filter_stringer_nodes(combined_nodes, stringer_index, start_rib);
    next_stringer_nodes = update_next_stringer_with_front_spar(combined_nodes, stringer_index);

    % Find the endpoint node (rib_index = -2)
    end_point = find_endpoint_node(combined_nodes, stringer_index + 1);

    if ~isempty(end_point)
        next_stringer_nodes = [next_stringer_nodes; end_point];
    end

    %% 🔧 Insert Perpendicular Node
    [combined_nodes, Inserted_node] = add_perpendicular_node_to_front_spar(combined_nodes, stringer_index, geometria, datosEstructural);

    %% 🟢 Create First Quad Surface (Inserted Node)
    if all_nodes_exist({current_stringer_nodes, next_stringer_nodes, end_point, Inserted_node})
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :), ...
            next_stringer_nodes(next_stringer_nodes.rib_index == start_rib & next_stringer_nodes.tag == "stringer", :), ...
            end_point, ...
            Inserted_node, ...
            stringer_index, stringer_index + 1, start_rib, -2, surface_counter, "quad irregular P4 inserted");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i(:)];
        surface_counter = surface_counter + 1;
    end

    %% 🟢 Create Second Quad Surface (Inserted Node)
    if all_nodes_exist({Inserted_node, end_point, next_stringer_nodes, current_stringer_nodes})
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            Inserted_node, ...
            end_point, ...
            next_stringer_nodes(next_stringer_nodes.rib_index == start_rib+1 & next_stringer_nodes.tag == "front spars", :), ...
            current_stringer_nodes(current_stringer_nodes.rib_index == start_rib+1, :), ...
            stringer_index, stringer_index + 1, -2, start_rib+1, surface_counter, "quad irregular P1 inserted");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i(:)];
        surface_counter = surface_counter + 1;
    end

    %% 🔄 Process Remaining Quadrilateral Surfaces
    for index_costilla = (start_rib+1):max(current_stringer_nodes.rib_index)-1
        [quad_surface, warnings_i] = create_quad_surface_entry( ...
            current_stringer_nodes(current_stringer_nodes.rib_index == index_costilla, :), ...
            next_stringer_nodes(next_stringer_nodes.rib_index == index_costilla & next_stringer_nodes.tag == "front spars", :), ...
            next_stringer_nodes(next_stringer_nodes.rib_index == index_costilla +1 & next_stringer_nodes.tag == "front spars", :), ...
            current_stringer_nodes(current_stringer_nodes.rib_index == index_costilla + 1, :), ...
            stringer_index, stringer_index + 1, index_costilla, index_costilla+1, surface_counter, "quad irregular");

        quad_surfaces = [quad_surfaces; quad_surface];
        warnings = [warnings; warnings_i(:)];
        surface_counter = surface_counter + 1;
    end

    %% 🔺 Create Final Triangular Surface
    num_stringers_last_rib = analyze_stringer_rib_data(combined_nodes);
    
    if num_stringers_last_rib ~= stringer_index
        node_1 = combined_nodes(combined_nodes.rib_index == -2 & combined_nodes.stringer_index == stringer_index, :);
        node_2 = find_max_rib_node(combined_nodes, stringer_index);
        node_3 = combined_nodes(node_2.rib_index == combined_nodes.rib_index & combined_nodes.tag == "front spars", :);

        if all_nodes_exist({node_1, node_2, node_3})
            [tri_surface, warnings_i] = create_tri_surface_entry( ...
                node_1, node_2, node_3, ...
                stringer_index, stringer_index + 1, ...
                max(current_stringer_nodes.rib_index), -2, surface_counter, "tri front");

            tri_surfaces = [tri_surfaces; tri_surface];
            warnings = [warnings; warnings_i(:)];
        end
    end
end
function end_point = find_endpoint_node(combined_nodes, stringer_index)
% FIND_ENDPOINT_NODE - Finds the endpoint node for a given stringer.
%
% Inputs:
%   combined_nodes  - Table containing node information.
%   stringer_index  - Index of the stringer to search for an endpoint.
%
% Output:
%   end_point       - The endpoint node if found, otherwise empty.

    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index & ...
                               combined_nodes.rib_index == -2, :);
end
function stringer_nodes = filter_stringer_nodes(combined_nodes, stringer_index, min_rib)
% FILTER_STRINGER_NODES - Extracts nodes for a given stringer above a rib threshold.
%
% Inputs:
%   combined_nodes  - Table containing node information.
%   stringer_index  - Index of the stringer to extract nodes from.
%   min_rib         - Minimum rib index to filter nodes.
%
% Output:
%   stringer_nodes  - Filtered table of nodes belonging to the given stringer.

    stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index & ...
        combined_nodes.rib_index >= min_rib, :);
end
