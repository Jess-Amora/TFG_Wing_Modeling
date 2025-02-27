function [tri_surfaces, quad_surfaces, warnings, combined_nodes] = create_surfaces_root(combined_nodes, stringer_index, geometria, datosEstructural)
% CREATE_SURFACES_ROOT - Generates quadrilateral and triangular surfaces at the wing root.
%
% Inputs:
%   combined_nodes  - Table containing node data.
%   stringer_index  - Index of the current stringer.
%   geometria       - Geometric parameters of the aircraft.
%   datosEstructural - Structural parameters of the aircraft.
%
% Outputs:
%   tri_surfaces    - Table with triangular surface data.
%   quad_surfaces   - Table with quadrilateral surface data.
%   warnings        - Cell array with warnings about skipped surfaces.
%   combined_nodes  - Updated node data (if new nodes were inserted).

    %% 🔹 Initialization
    tri_surfaces = tri_initialize();
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;
    distancia_media = datosEstructural.distancia_entre_costillas / 2;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = filter_nodes_by_stringer(combined_nodes, stringer_index);
    next_stringer_nodes = filter_nodes_by_stringer(combined_nodes, stringer_index + 1);
    
    [~, ~, ~, rib_ranges] = analyze_stringer_rib_data(combined_nodes);
    start_rib = rib_ranges(stringer_index, 2);

    %% 📏 Compute Distances for Case Selection
    [distance_A, distance_B] = compute_root_distances(current_stringer_nodes, next_stringer_nodes, start_rib);
    [case_quad, case_penta, case_special] = determine_surface_case(distance_A, distance_B, distancia_media);

    %% 🏗️ Construct Surfaces Based on Case
    if all_nodes_exist({current_stringer_nodes, next_stringer_nodes})
        if case_quad
            % ✅ Standard Quadrilateral Surface
            [quad_surface, warnings_i] = create_quad_surface_entry( ...
                extract_node(current_stringer_nodes, -1), extract_node(next_stringer_nodes, -1), ...
                extract_node(next_stringer_nodes, start_rib), extract_node(current_stringer_nodes, start_rib), ...
                stringer_index, stringer_index + 1, -1, start_rib, surface_counter, "quad irregular root");

            quad_surfaces = [quad_surfaces; quad_surface];
            warnings = [warnings; warnings_i];
            surface_counter = surface_counter + 1;
        
        elseif case_penta
            % ✅ Pentagonal Surface (With Inserted Node)
            [quad_surfaces, warnings, combined_nodes, surface_counter] = create_penta_root_surface( ...
                combined_nodes, current_stringer_nodes, next_stringer_nodes, stringer_index, start_rib, geometria, datosEstructural, quad_surfaces, warnings, surface_counter);
        
        elseif case_special
            % ✅ Special Case (Two Quadrilaterals)
            [quad_surfaces, warnings, surface_counter] = create_special_root_surfaces( ...
                current_stringer_nodes, next_stringer_nodes, stringer_index, start_rib, quad_surfaces, warnings, surface_counter);
        end
    end

    % %% 🔺 Construct Final Triangular Surface if Needed
    % if is_tri_surface_needed(combined_nodes, stringer_index)
    %     [tri_surface, warnings_i] = create_tri_surface_entry( ...
    %         extract_node(combined_nodes, -1, stringer_index), find_max_rib_node(combined_nodes, stringer_index), ...
    %         % extract_node(combined_nodes, stringer_index), find_max_rib_node(combined_nodes, stringer_index), ...
    %         extract_node_by_tag(combined_nodes, 'front spars', find_max_rib_node(combined_nodes, stringer_index).rib_index), ...
    %         stringer_index, stringer_index + 1, start_rib - 1, -1, surface_counter, "tri root");
    % 
    %     tri_surfaces = [tri_surfaces; tri_surface];
    %     warnings = [warnings; warnings_i];
    % end
    %% 🔺 Construct Final Triangular Surface if Needed
    if is_tri_surface_needed(combined_nodes, stringer_index)
        [tri_surface, warnings_i] = create_tri_surface_entry( ...
            extract_node(combined_nodes, -1), find_max_rib_node(combined_nodes, stringer_index), ...
            extract_node_by_tag(combined_nodes, 'front spars', find_max_rib_node(combined_nodes, stringer_index).rib_index), ...
            stringer_index, stringer_index + 1, start_rib - 1, -1, surface_counter, "tri root");

        tri_surfaces = [tri_surfaces; tri_surface];
        warnings = [warnings; warnings_i];
    end
end

function nodes = filter_nodes_by_stringer(combined_nodes, stringer_index)
% FILTER_NODES_BY_STRINGER - Retrieves nodes for a given stringer.
    nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
end

function [distance_A, distance_B] = compute_root_distances(current_nodes, next_nodes, start_rib)
% COMPUTE_ROOT_DISTANCES - Calculates distances for surface classification.

    P1_A = extract_node(current_nodes, -1);
    P2_A = extract_node(current_nodes, start_rib);
    distance_A = norm([P1_A.x, P1_A.y] - [P2_A.x, P2_A.y]);

    P1_B = extract_node(next_nodes, -1);
    P2_B = extract_node(next_nodes, start_rib);
    distance_B = norm([P1_B.x, P1_B.y] - [P2_B.x, P2_B.y]);
end

function [case_quad, case_penta, case_special] = determine_surface_case(distance_A, distance_B, threshold)
% DETERMINE_SURFACE_CASE - Classifies the surface as quad, penta, or special.
    case_quad = (distance_A < threshold) && (distance_B < threshold);
    case_penta = (distance_A < threshold) && (distance_B > threshold);
    case_special = (distance_A > threshold) && (distance_B > threshold);
end

function is_needed = is_tri_surface_needed(combined_nodes, stringer_index)
% IS_TRI_SURFACE_NEEDED - Determines if a final triangular surface is necessary.
    [num_stringers_last_rib, ~, ~, ~] = analyze_stringer_rib_data(combined_nodes);
    is_needed = num_stringers_last_rib ~= stringer_index;
end

function node = extract_node(nodes, rib_index)
% EXTRACT_NODE - Retrieves a node at a given rib index.
    node = nodes(nodes.rib_index == rib_index, :);
end

function node = extract_node_by_tag(combined_nodes, tag, rib_index)
% EXTRACT_NODE_BY_TAG - Retrieves a node with a given tag at a specified rib index.
    node = combined_nodes(strcmp(combined_nodes.tag, tag) & combined_nodes.rib_index == rib_index, :);
end

function [quad_surfaces, warnings, combined_nodes, surface_counter] = create_penta_root_surface( ...
    combined_nodes, current_nodes, next_nodes, stringer_index, start_rib, geometria, datosEstructural, quad_surfaces, warnings, surface_counter)
% CREATE_PENTA_ROOT_SURFACE - Constructs pentagonal surfaces with an inserted node.

    % Insert perpendicular node
    [combined_nodes, inserted_node] = add_perpendicular_node_to_root(combined_nodes, stringer_index, geometria, datosEstructural);

    % Create two quadrilateral surfaces
    quad_surfaces = [quad_surfaces; create_quad_surface_entry( ...
        extract_node(current_nodes, -1), inserted_node, ...
        extract_node(next_nodes, start_rib), extract_node(current_nodes, start_rib), ...
        stringer_index, stringer_index + 1, -1, start_rib, surface_counter, "quad irregular root P2 inserted")];

    quad_surfaces = [quad_surfaces; create_quad_surface_entry( ...
        extract_node(combined_nodes, 'rear spars', start_rib - 1), extract_node(next_nodes, start_rib - 1), ...
        inserted_node, extract_node(current_nodes, -1), ...
        stringer_index, stringer_index + 1, start_rib - 1, 3e5, surface_counter, "quad irregular root P3 inserted")];
end
