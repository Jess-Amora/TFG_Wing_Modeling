function [quad_surfaces,tri_surfaces, warnings, combined_nodes] = create_surfaces_for_stringer_irregular_v7( ...
    combined_nodes, stringer_index, start_rib, geometria,datosEstructural)
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
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;

    %% Analysis
    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data_v5(combined_nodes);

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index & ...
        combined_nodes.rib_index >= start_rib, :);

    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1 & ...
        combined_nodes.rib_index >= start_rib, :);
    
    % Check for the endpoint node (rib_index = -2) in the next stringer
    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                               combined_nodes.rib_index == -2, :);
    
    % Append the endpoint node to next_stringer_nodes if it exists
    if ~isempty(end_point)
        next_stringer_nodes = [next_stringer_nodes; end_point];
    end

    % Extract front spar nodes from combined_nodes
    front_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'front spars'), :);

    % Append front spar nodes to next stringer nodes
    if ~isempty(next_stringer_nodes)
        last_rib_index = max(next_stringer_nodes.rib_index);
        additional_nodes = front_spar_nodes(front_spar_nodes.rib_index >= last_rib_index, :);
        next_stringer_nodes = [next_stringer_nodes; additional_nodes];
    end

    [combined_nodes, Inserted_node] = add_perpendicular_node_to_front_spar(combined_nodes, stringer_index, geometria,datosEstructural);
    
    %% Create First Surface (inserted_nodes)
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes) && ~isempty(end_point) && ~isempty(Inserted_node)
        node1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :); % Bottom-left
        node2 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib & next_stringer_nodes.tag=='stringer', :);       % Bottom-right
        node3 = end_point;                                                               % Top-right
        node4 = Inserted_node;                                                          % Top-left

        % Extract Rib and Stringer Indices
        stringer_1 = stringer_index; % Fixed for rear spar
        stringer_2 = stringer_index+1;  % Fixed for first stringer
        rib_1 = start_rib;
        rib_2 = -2;
        tag = "quad irregular P4 inserted";
        
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
        %     start_rib, ...                % rib_1
        %     -2, ...            % rib_2
        %     "quad irregular P4 inserted", ...       % tags
        %     area, ...                   % area
        %     aspect_ratio, ...           % aspect_ratio
        %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
        %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
        %                       'area', 'aspect_ratio'})];
        % 
        % surface_counter = surface_counter + 1;
    end
    
    %% Create second Surface (inserted node)
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes) && ~isempty(end_point) && ~isempty(Inserted_node)
        node1 = Inserted_node; % Bottom-left
        node2 = end_point;       % Bottom-right
        node3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib+1 & next_stringer_nodes.tag=='front spars', :);                                                             % Top-right
        node4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib+1, :);
        
        % Extract Rib and Stringer Indices
        stringer_1 = stringer_index; % Fixed for rear spar
        stringer_2 = stringer_index+1;  % Fixed for first stringer
        rib_1 = -2;
        rib_2 = start_rib+1;
        tag = "quad irregular P1 inserted";
        
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
        %     stringer_index , ...         % stringer_1
        %     stringer_index + 1, ...     % stringer_2
        %     -2, ...                % rib_1
        %     start_rib+1, ...            % rib_2
        %     "quad irregular P1 inserted", ...       % tags
        %     area, ...                   % area
        %     aspect_ratio, ...           % aspect_ratio
        %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
        %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
        %                       'area', 'aspect_ratio'})];
        % 
        % surface_counter = surface_counter + 1;
    end

    %% El loop para guardar el resto de las superficies quadrilaterales
    start_rib_end = start_rib +1;
    for index_costilla = start_rib_end:max(current_stringer_nodes.rib_index)-1
        start_rib = index_costilla;
        node1 = current_stringer_nodes(current_stringer_nodes.rib_index == index_costilla, :); % Bottom-left
        node2 = next_stringer_nodes(next_stringer_nodes.rib_index == index_costilla & next_stringer_nodes.tag=='front spars', :);       % Bottom-right
        node3 = next_stringer_nodes(next_stringer_nodes.rib_index == index_costilla +1 & next_stringer_nodes.tag=='front spars', :);                                                             % Top-right
        node4 = current_stringer_nodes(current_stringer_nodes.rib_index == index_costilla + 1, :); % Top-left

        % Extract Rib and Stringer Indices
        stringer_1 = node1.stringer_index; % Fixed for rear spar
        stringer_2 = node3.stringer_index;  % Fixed for first stringer
        rib_1 = node1.rib_index;
        rib_2 = node3.rib_index;
        tag = "quad irregular surface";
        
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
        %     start_rib, ...                % rib_1
        %     start_rib+1, ...            % rib_2
        %     "quad irregular", ...       % tags
        %     area, ...                   % area
        %     aspect_ratio, ...           % aspect_ratio
        %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
        %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
        %                       'area', 'aspect_ratio'})];
        % 
        % surface_counter = surface_counter + 1;
        % 
    end
    

    %% Construir la superficie final en los larguerillos que es una triangular
    tri_surfaces = tri_initialize();
    
    % No se guarda el triangulo que sobre sale. See documentation R1.
    if num_stringers_last_rib ~= stringer_index

        node_1 = combined_nodes(combined_nodes.rib_index == -2 & combined_nodes.stringer_index==stringer_index, :); % Bottom-left
        node_2 = find_max_rib_node_v2(combined_nodes, stringer_index);       % Bottom-right
        node_3 = combined_nodes(node_2.rib_index == combined_nodes.rib_index  & combined_nodes.tag=='front spars' , :);     
        
       % Define stringer and rib indices
        stringer_1 = stringer_index;  % Rear spar
        stringer_2 = stringer_index+1;   % First stringer
        rib_1 =  max(current_stringer_nodes.rib_index);       % Root rib
        rib_2 = -2;        % Adjacent rib
        tag = "tri front";
        
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
        % 
        % % Append Surface to tri_surfaces
        % tri_surfaces = [tri_surfaces; table( ...
        %     1, ...       % local_id
        %     node_1.local_id, ...           % node_1
        %     node_2.local_id, ...           % node_2
        %     node_3.local_id, ...           % node_3
        %     stringer_index, ...            % stringer_1
        %     stringer_index + 1, ...        % stringer_2
        %      max(current_stringer_nodes.rib_index), ...                 % rib_1
        %     -2, ...                        % rib_2
        %     "tri front", ...    % tags
        %     area, ...                      % area
        %     aspect_ratio, ...              % aspect_ratio
        %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
        %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
        %                       'area', 'aspect_ratio'})];
    end
end