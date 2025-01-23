function [quad_surfaces, warnings] = create_surfaces_vertical_front_spar_wing_v1(combined_nodes_3D)
    
    %% 📝 Initialization    
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    warnings = {};
    surface_counter = 1;
    
    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data(combined_nodes_3D);
    start_rib = rib_ranges(1,2);
    %% 🔍 Filter Nodes by Stringer and Rib
    front_spar_extrados = [combined_nodes_3D(combined_nodes_3D.tag == 'OnlyNode' & combined_nodes_3D.h == 'extrados', :); 
                            sortrows(combined_nodes_3D(combined_nodes_3D.tag == 'front spars' & ...
                                             combined_nodes_3D.h == 'extrados', :), 5)];

    front_spar_intrados = [combined_nodes_3D(combined_nodes_3D.tag == 'OnlyNode' & combined_nodes_3D.h == 'intrados', :); 
                            sortrows(combined_nodes_3D(combined_nodes_3D.tag == 'front spars' & ...
                                             combined_nodes_3D.h == 'intrados', :), 5)];

    % Debug: Check filtered nodes
    if isempty(front_spar_extrados) || isempty(front_spar_intrados)
        warnings{end+1} = sprintf('No valid nodes found for rib_index %d and its neighbor.', rib_index);
        return;
    end
    
    %% 🔄 Loop Through Nodes to Create Surfaces
    num_ribs = min(height(front_spar_extrados), height(front_spar_intrados)) - 1;
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for rib_index %d in the rib range.', rib_index);
        return;
    end
    
    for i = 1:num_ribs - 1
        % Extract nodes for the quadrilateral
        node_1 = front_spar_extrados(i, :);          % Bottom-left
        node_2 = front_spar_intrados(i, :)   ;          % Top-left
        node_3 = front_spar_intrados(i + 1, :);         % Top-right
        node_4 = front_spar_extrados(i + 1, :);      % Bottom-right

        % Ensure nodes are not empty
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', start_rib + i - 1);
            % continue;
        end

        % Extract coordinates for surface property calculation
        surface_coords = [
            node_1.x, node_1.y, node_1.z;
            node_2.x, node_2.y, node_2.z;
            node_3.x, node_3.y, node_3.z;
            node_4.x, node_4.y, node_4.z
        ];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio_v2(surface_coords, 'quad');
        % if ~is_valid
        %     warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
        %     continue;
        % end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Append surface to table
        new_surface = table( ...
            surface_counter, ...        % local_id
            node_1.local_id, ...        % node_1
            node_2.local_id, ...        % node_2
            node_3.local_id, ...        % node_3
            node_4.local_id, ...        % node_4
            -1, ...         % stringer_1
            -1, ...     % stringer_2
            node_1.rib_index, ...       % rib_1
            node_3.rib_index, ...       % rib_2
            "quad vertical front", ...         % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'});
        quad_surfaces = [quad_surfaces; new_surface];

        % Increment surface counter
        surface_counter = surface_counter + 1;
    end


end