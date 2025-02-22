function [tri_surfaces, quad_surfaces, warnings, combined_nodes] = create_surfaces_root(combined_nodes, stringer_index, geometria, datosEstructural)
    %% Initialization
    tri_surfaces = tri_initialize();
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;
    
    distancia_entre_costillas_media = datosEstructural.distancia_entre_costillas / 2;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1, :);
    
    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data(combined_nodes);
    start_rib = rib_ranges(stringer_index, 2);

    Point_1_A = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);
    Point_2_A = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
    distance_A = norm([Point_1_A.x, Point_1_A.y] - [Point_2_A.x, Point_2_A.y]);
    
    Point_1_B = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);
    Point_2_B = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :);
    distance_B = norm([Point_1_B.x, Point_1_B.y] - [Point_2_B.x, Point_2_B.y]);

    % Check which case: quad, penta or special (2 quads)
    if (distance_A < distancia_entre_costillas_media && distance_B < distancia_entre_costillas_media)
        case_quad = true;
        case_penta = false;
        case_special = false;
    elseif (distance_A < distancia_entre_costillas_media && distance_B > distancia_entre_costillas_media)
        case_quad = false;
        case_penta = true;
        case_special = false;
    elseif (distance_A > distancia_entre_costillas_media && distance_B > distancia_entre_costillas_media)
        case_quad = false;
        case_penta = false;
        case_special = true; % 2 quads
    end

    %% Create Surfaces
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes)
        if case_quad
            % --- QUAD CASE ---
            node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            node_2 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);       % Bottom-right
            node_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :); % Top-right
            node_4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :); % Top-left
            
            [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, node_1, node_2, node_3, node_4, ...
                stringer_index, -1, start_rib, surface_counter, "quad irregular root", warnings);
        
        elseif case_penta
            % --- PENTAGONAL CASE (R2 inserted root) ---
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            P_2 = combined_nodes(combined_nodes.tag == 'rear spars' & combined_nodes.rib_index == start_rib - 1, :); % Bottom-right
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib - 1, :); % Top-right
            P_4 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :); % Top-left
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
            P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);
            
            [combined_nodes, Inserted_node] = add_perpendicular_node_to_root(combined_nodes, stringer_index, geometria, datosEstructural);
            P_7 = Inserted_node;
            
            % Quad 1: Nodes = [P_1, P_7, P_4, P_5]
            [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, P_1, P_7, P_4, P_5, ...
                stringer_index, 3e5, start_rib, surface_counter, "quad irregular root P2 inserted", warnings);
            
            % Quad 2: Nodes = [P_2, P_3, P_7, P_1]
            [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, P_2, P_3, P_7, P_1, ...
                stringer_index, start_rib - 1, 3e5, surface_counter, "quad irregular root P3 inserted", warnings);
            
            % Triangular surface: Nodes = [P_3, P_2, P_6]
            node_1 = P_3; % Bottom-left
            node_2 = P_2; % Bottom-right
            node_3 = P_6;
            
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warnings{end+1} = sprintf('Skipping final triangular surface due to missing nodes at stringer %d.', stringer_index);
            else
                surface_coords = [node_1.x, node_1.y; node_2.x, node_2.y; node_3.x, node_3.y];
                area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
                [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');
                if ~is_valid
                    warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio at stringer %d.', stringer_index);
                else
                    tri_surfaces = [tri_surfaces; table( ...
                        1, ...                       % local_id
                        node_1.local_id, ...         % node_1
                        node_2.local_id, ...         % node_2
                        node_3.local_id, ...         % node_3
                        stringer_index, ...          % stringer_1
                        stringer_index + 1, ...      % stringer_2
                        -1, ...                    % rib_1
                        start_rib - 1, ...           % rib_2
                        "tri root", ...            % tag
                        area, ...                  % area
                        aspect_ratio, ...          % aspect_ratio
                        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                                          'area', 'aspect_ratio'})];
                end
            end
            
        elseif case_special
            % --- SPECIAL CASE (2 QUADS) ---
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib - 1, :); % Bottom-left
            P_2 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib - 1, :);
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :);
            P_4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);
            P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);
            
            % Quad 1: Nodes = [P_1, P_2, P_3, P_4]
            [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, P_1, P_2, P_3, P_4, ...
                stringer_index, start_rib - 1, start_rib, surface_counter, "quad regular", warnings);
            
            % Quad 2: Nodes = [P_5, P_6, P_2, P_1]
            [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, P_5, P_6, P_2, P_1, ...
                stringer_index, -1, start_rib - 1, surface_counter, "quad irregular root", warnings);
        end
    end
end

%% Helper Function: Append a Quadrilateral Surface Entry
function [quad_surfaces, warnings] = appendQuadSurface(quad_surfaces, node_1, node_2, node_3, node_4, ...
                                                     stringer_index, rib_1, rib_2, surface_counter, tag, warnings)
    [new_surface, is_valid_surface, local_warnings] = create_quad_surface_entry(...
        node_1, node_2, node_3, node_4, stringer_index, stringer_index + 1, rib_1, rib_2, surface_counter, tag);
    warnings = [warnings; local_warnings];
    if is_valid_surface
        quad_surfaces = [quad_surfaces; new_surface];
    end
end
