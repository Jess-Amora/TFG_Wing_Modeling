function [tri_surfaces, quad_surfaces, warnings, combined_nodes] = create_surfaces_root_v3(combined_nodes, stringer_index,geometria, datosEstructural)
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

    %% Initialization
    tri_surfaces =tri_initialize();
    quad_surfaces = quad_initialize();
    
    warnings = {};
    surface_counter = 1;
    
    distancia_entre_costillas_media = datosEstructural.distancia_entre_costillas/2;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index, :);
    
    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1, :);
    
    
    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data_v5(combined_nodes);
    start_rib=rib_ranges(stringer_index,2);

    Point_1_A = current_stringer_nodes(current_stringer_nodes.rib_index==-1,:);
    Point_2_A = current_stringer_nodes(current_stringer_nodes.rib_index==start_rib,:);
    distance_A = norm([Point_1_A.x, Point_1_A.y] - [Point_2_A.x, Point_2_A.y]);
    
    Point_1_B = next_stringer_nodes(next_stringer_nodes.rib_index==-1,:);
    Point_2_B = next_stringer_nodes(next_stringer_nodes.rib_index==start_rib,:);
    distance_B = norm([Point_1_B.x, Point_1_B.y] - [Point_2_B.x, Point_2_B.y]);

    % Check which case: quad or penta
    if (distance_A<distancia_entre_costillas_media && distance_B<distancia_entre_costillas_media)
        case_quad = true;
        case_penta = false;
        case_special = false;

    elseif(distance_A<distancia_entre_costillas_media && distance_B>distancia_entre_costillas_media)
        case_quad = false;
        case_penta = true;
        case_special = false;
    elseif(distance_A>distancia_entre_costillas_media && distance_B>distancia_entre_costillas_media)
        case_quad = false;
        case_penta = false;
        case_special = true; % 2 quads
    end
    

    %% Create Surfaces
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes)
        if (case_quad) % Quad
            node1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            node2 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);       % Bottom-right
            node3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :); % Top-right
            node4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);                                                          % Top-left
    
            % Extract Rib and Stringer Indices
            stringer_1 = stringer_index; % Fixed for rear spar
            stringer_2 = stringer_index + 1;  % Fixed for first stringer
            rib_1 = -1;
            rib_2 = start_rib;
            tag = "quad irregular root";
            
            % Call the function
            [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                               node1, node2, node3, node4, ...
                                                                               stringer_1, stringer_2, rib_1, rib_2);

            % % Validate nodes
            % if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            %     warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % 
            % % Extract coordinates for surface property calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y;
            %     node_4.x, node_4.y
            % ];
            % 
            % % Compute area and aspect ratio
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % 
            % % Append surface to quad_surfaces
            % quad_surfaces = [quad_surfaces; table( ...
            %     surface_counter, ...        % local_id
            %     node_1.local_id, ...        % node_1
            %     node_2.local_id, ...        % node_2
            %     node_3.local_id, ...        % node_3
            %     node_4.local_id, ...        % node_4
            %     stringer_index, ...         % stringer_1
            %     stringer_index + 1, ...     % stringer_2
            %     -1, ...                % rib_1
            %     start_rib, ...            % rib_2
            %     "quad irregular root", ...       % tags
            %     area, ...                   % area
            %     aspect_ratio, ...           % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];
        elseif(case_penta)
            % See documentation: R2 inserted root 
            
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            P_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib-1,:);       % Bottom-right
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib-1, :); % Top-right
            P_4 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :);                                                       % Top-left
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);  
            P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);  
            
            [combined_nodes, Inserted_node] = add_perpendicular_node_to_root(combined_nodes, stringer_index, geometria,datosEstructural);

            P_7 = Inserted_node;
            
            % Quad 1
            node1 = P_1;
            node2 = P_7;
            node3 = P_4;
            node4 = P_5;

            % Extract Rib and Stringer Indices
            stringer_1 = stringer_index; % Fixed for rear spar
            stringer_2 = stringer_index + 1;  % Fixed for first stringer
            rib_1 = 3e5;
            rib_2 = start_rib;
            tag = "quad irregular root P2 inserted";
            
            % Call the function
            [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                               node1, node2, node3, node4, ...
                                                                               stringer_1, stringer_2, rib_1, rib_2);


            % % Validate nodes
            % if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            %     warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % 
            % % Extract coordinates for surface property calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y;
            %     node_4.x, node_4.y;
            % ];
            % 
            % % Compute area and aspect ratio
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % 
            % % Append surface to quad_surfaces
            % quad_surfaces = [quad_surfaces; table( ...
            %     surface_counter, ...        % local_id
            %     node_1.local_id, ...        % node_1
            %     node_2.local_id, ...        % node_2
            %     node_3.local_id, ...        % node_3
            %     node_4.local_id, ...        % node_4
            %     stringer_index, ...         % stringer_1
            %     stringer_index + 1, ...     % stringer_2
            %     3e5, ...                % rib_1
            %     start_rib, ...            % rib_2
            %     "quad irregular root P2 inserted", ...       % tags
            %     area, ...                   % area
            %     aspect_ratio, ...           % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];
            % Quad 2
            node1 = P_2;
            node2 = P_3;
            node3 = P_7;
            node4 = P_1;

            % Extract Rib and Stringer Indices
            stringer_1 = stringer_index; % Fixed for rear spar
            stringer_2 = stringer_index + 1;  % Fixed for first stringer
            rib_1 = start_rib-1;
            rib_2 = 3e5;
            tag = "quad irregular root P3 inserted";
            
            % Call the function
            [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                               node1, node2, node3, node4, ...
                                                                               stringer_1, stringer_2, rib_1, rib_2);


            % % Validate nodes
            % if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            %     warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % 
            % % Extract coordinates for surface property calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y;
            %     node_4.x, node_4.y;
            % ];
            % 
            % % Compute area and aspect ratio
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
            %     % continue;
            % end
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % 
            % % Append surface to quad_surfaces
            % quad_surfaces = [quad_surfaces; table( ...
            %     surface_counter, ...        % local_id
            %     node_1.local_id, ...        % node_1
            %     node_2.local_id, ...        % node_2
            %     node_3.local_id, ...        % node_3
            %     node_4.local_id, ...        % node_4
            %     stringer_index, ...         % stringer_1
            %     stringer_index + 1, ...     % stringer_2
            %     start_rib-1, ...                % rib_1
            %     3e5, ...            % rib_2
            %     "quad irregular root P3 inserted", ...       % tags
            %     area, ...                   % area
            %     aspect_ratio, ...           % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];
            % Triangulo
            node_1 = P_3; % Bottom-left
            node_2 = P_2;       % Bottom-right
            node_3 = P_6;     
            
                % Define stringer and rib indices
            stringer_1 = stringer_index;  % Rear spar
            stringer_2 = stringer_index+1;   % First stringer
            rib_1 = -1;       % Root rib
            rib_2 = start_rib-1;        % Adjacent rib
            tag = "tri root";
            
            % Append triangular surface
            [tri_surfaces, warnings] = append_tri_surface_3D(tri_surfaces, warnings, 1, ...
                                                         node_1, node_2, node_3, ...
                                                         stringer_1, stringer_2, rib_1, rib_2, tag);
            % % Validate Nodes
            % if isempty(node_1) || isempty(node_2) || isempty(node_3)
            %     warnings{end+1} = sprintf('Skipping final triangular surface due to missing nodes at stringer %d.', stringer_index);
            %     % return;
            % end
            % 
            % % Extract Coordinates for Surface Property Calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y
            % ];
            % 
            % % Compute area and aspect ratio
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio at stringer %d.', stringer_index);
            %     % return;
            % end
            % 
            % % Append Surface to tri_surfaces
            % tri_surfaces = [tri_surfaces; table( ...
            %     1, ...       % local_id
            %     node_1.local_id, ...           % node_1
            %     node_2.local_id, ...           % node_2
            %     node_3.local_id, ...           % node_3
            %     stringer_index, ...            % stringer_1
            %     stringer_index + 1, ...        % stringer_2
            %      -1, ...                 % rib_1
            %      start_rib-1, ...                        % rib_2
            %     "tri root", ...    % tags
            %     area, ...                      % area
            %     aspect_ratio, ...              % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];
        elseif(case_special)
            % 1st quad
            
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib-1, :); % Bottom-left
            P_2 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib-1, :);
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :);     
            P_4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :); % Bottom-lef                                                  % Top-left
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);  
            P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);  
            
            node1 = P_1;
            node2 = P_2;
            node3 = P_3;
            node4 = P_4;

            % Extract Rib and Stringer Indices
            stringer_1 = stringer_index; % Fixed for rear spar
            stringer_2 = stringer_index + 1;  % Fixed for first stringer
            rib_1 = start_rib-1;
            rib_2 = start_rib;
            tag = "quad regular";
            
            % Call the function
            [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                               node1, node2, node3, node4, ...
                                                                               stringer_1, stringer_2, rib_1, rib_2);


            % % Extract coordinates for surface property calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y;
            %     node_4.x, node_4.y
            % ];
            % 
            % % Compute area and aspect ratio
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib - 1, start_rib);
            %     % continue;
            % end
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % 
            % % Append surface to quad_surfaces
            % quad_surfaces = [quad_surfaces; table( ...
            %     surface_counter, ...        % local_id
            %     node_1.local_id, ...        % node_1
            %     node_2.local_id, ...        % node_2
            %     node_3.local_id, ...        % node_3
            %     node_4.local_id, ...        % node_4
            %     stringer_index, ...         % stringer_1
            %     stringer_index + 1, ...     % stringer_2
            %     start_rib-1, ...                % rib_1
            %     start_rib, ...            % rib_2
            %     "quad regular", ...       % tags
            %     area, ...                   % area
            %     aspect_ratio, ...           % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];

            % Quad 2 closer to root
            node1 = P_5;
            node2 = P_6;
            node3 = P_2;
            node4 = P_1;

            % Extract Rib and Stringer Indices
            stringer_1 = stringer_index; % Fixed for rear spar
            stringer_2 = stringer_index + 1;  % Fixed for first stringer
            rib_1 = -1;
            rib_2 = start_rib-1;
            tag = "quad irregular root";
            
            % Call the function
            [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                               node1, node2, node3, node4, ...
                                                                               stringer_1, stringer_2, rib_1, rib_2);



            % % Extract coordinates for surface property calculation
            % surface_coords = [
            %     node_1.x, node_1.y;
            %     node_2.x, node_2.y;
            %     node_3.x, node_3.y;
            %     node_4.x, node_4.y
            % ];
            % 
            % % Compute area and aspect ratio
            % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            % if ~is_valid
            %     warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', -1, start_rib-1);
            %     % continue;
            % end
            % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            % 
            % % Append surface to quad_surfaces
            % quad_surfaces = [quad_surfaces; table( ...
            %     surface_counter, ...        % local_id
            %     node_1.local_id, ...        % node_1
            %     node_2.local_id, ...        % node_2
            %     node_3.local_id, ...        % node_3
            %     node_4.local_id, ...        % node_4
            %     stringer_index, ...         % stringer_1
            %     stringer_index + 1, ...     % stringer_2
            %     -1, ...                % rib_1
            %     start_rib-1, ...            % rib_2
            %     "quad irregular root", ...       % tags
            %     area, ...                   % area
            %     aspect_ratio, ...           % aspect_ratio
            %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
            %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
            %                       'area', 'aspect_ratio'})];

        end
    end
end