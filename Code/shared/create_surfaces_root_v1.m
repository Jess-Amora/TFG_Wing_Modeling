function [tri_surfaces, quad_surfaces, penta_surfaces, warnings] = create_surfaces_root_v1(combined_nodes, stringer_index,distancia_entre_costillas_media)
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
    tri_surfaces = table([], [], [], [], [], [], [], [], [], [], [], ...
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'});
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    penta_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', 'node_5', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    warnings = {};
    surface_counter = 1;

    %% 🔍 Extract Relevant Nodes
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index, :);
    
    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1, :);
    
    
    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data(combined_nodes);
    start_rib=rib_ranges(stringer_index,2);

    Point_1 = next_stringer_nodes(next_stringer_nodes.rib_index==-1,:);
    Point_2 = next_stringer_nodes(next_stringer_nodes.rib_index==start_rib,:);
    distance = norm([Point_1.x, Point_1.y] - [Point_2.x, Point_2.y]);

    % Check which case: quad or penta
    if (distance<distancia_entre_costillas_media)
        case_quad = true;
        case_penta = false;
    else%if(distance<distancia_entre_costillas_media)
        case_quad = false;
        case_penta = true;

    end

    %% Create First Surface
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes)
        if (case_quad) % Quad
            node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            node_2 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);       % Bottom-right
            node_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :); % Top-right
            node_4 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);                                                          % Top-left
    
            % Validate nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
                % continue;
            end
    
            % Extract coordinates for surface property calculation
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];
    
            % Compute area and aspect ratio
            [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
            if ~is_valid
                warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
                % continue;
            end
            area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
    
            % Append surface to quad_surfaces
            quad_surfaces = [quad_surfaces; table( ...
                surface_counter, ...        % local_id
                node_1.local_id, ...        % node_1
                node_2.local_id, ...        % node_2
                node_3.local_id, ...        % node_3
                node_4.local_id, ...        % node_4
                stringer_index, ...         % stringer_1
                stringer_index + 1, ...     % stringer_2
                -1, ...                % rib_1
                start_rib, ...            % rib_2
                "quad irregular root", ...       % tags
                area, ...                   % area
                aspect_ratio, ...           % aspect_ratio
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'})];
        elseif(case_penta)
            % penta
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            P_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib-1,:);       % Bottom-right
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib-1, :); % Top-right
            P_4 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :);                                                       % Top-left
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);  
            P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);  
            
            node_1 = P_1;
            node_2 = P_2;
            node_3 = P_3;
            node_4 = P_4;
            node_5 = P_5;
            % Validate nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4) || isempty(node_5)
                warnings{end+1} = sprintf('Skipping rib pair %d-%d due to missing nodes.', start_rib, start_rib + 1);
                % continue;
            end
            
            % Extract coordinates for surface property calculation
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y;
                node_5.x, node_5.y
            ];
            
            % Compute area and aspect ratio
            [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'penta');
            if ~is_valid
                warnings{end+1} = sprintf('Skipped pentagonal surface due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
                % continue;
            end
            area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            
            % Append surface to penta_surfaces
            penta_surfaces = [penta_surfaces; table( ...
                surface_counter, ...        % local_id
                node_1.local_id, ...        % node_1
                node_2.local_id, ...        % node_2
                node_3.local_id, ...        % node_3
                node_4.local_id, ...        % node_4
                node_5.local_id, ...        % node_5
                stringer_index, ...         % stringer_1
                stringer_index + 1, ...     % stringer_2
                -1, ...              % rib_1
                start_rib, ...                     % rib_2
                "penta root", ...      % tags
                area, ...                   % area
                aspect_ratio, ...           % aspect_ratio
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', 'node_5', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'})];
            % Triangulo
            node_1 = P_3; % Bottom-left
            node_2 = P_2;       % Bottom-right
            node_3 = P_6;     
            
            % Validate Nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warnings{end+1} = sprintf('Skipping final triangular surface due to missing nodes at stringer %d.', stringer_index);
                % return;
            end
        
            % Extract Coordinates for Surface Property Calculation
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];
        
            % Compute area and aspect ratio
            area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');
            if ~is_valid
                warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio at stringer %d.', stringer_index);
                % return;
            end
        
            % Append Surface to tri_surfaces
            tri_surfaces = [tri_surfaces; table( ...
                1, ...       % local_id
                node_1.local_id, ...           % node_1
                node_2.local_id, ...           % node_2
                node_3.local_id, ...           % node_3
                stringer_index, ...            % stringer_1
                stringer_index + 1, ...        % stringer_2
                 -1, ...                 % rib_1
                 start_rib, ...                        % rib_2
                "tri root", ...    % tags
                area, ...                      % area
                aspect_ratio, ...              % aspect_ratio
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'})];

        end
    end
end