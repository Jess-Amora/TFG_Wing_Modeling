function triangles_matrix = process_tri(combined_nodes_3D, triangles)
% PROCESS_TRIANGLES: Processes triangular elements and assigns unique global IDs.
%
% Inputs:
%   combined_nodes_3D - Table containing node coordinates and global IDs.
%   triangles - Table containing 'local_id', 'node_1', 'node_2', 'node_3', 'tags'.
%
% Output:
%   triangles_matrix - Nx7 matrix where each row corresponds to a triangle:
%                      [Triangle ID, Property ID, G1, G2, G3, THETA, ZOFFS].

    % Validate input structure
    required_vars = {'local_id', 'node_1', 'node_2', 'node_3', 'tags'};
    if ~all(ismember(required_vars, triangles.Properties.VariableNames))
        error('The triangles table must contain columns: %s', strjoin(required_vars, ', '));
    end
    
    % Initialize Result
    num_triangles = height(triangles);
    triangles_matrix = NaN(num_triangles, 7); % [Tri ID, PID, G1, G2, G3, THETA, ZOFFS]

    global_triangle_id = 1; % Unique Triangle ID counter
    processed_count = 0; 

    % Process each triangle
    for i = 1:num_triangles
        % Extract current triangle
        current_triangle = triangles(i, :);

        % Find Global Node IDs
        [G1, G2, G3] = find_global_tri_ids(current_triangle, combined_nodes_3D);

        % Store data in matrix
        processed_count = processed_count + 1;
        triangles_matrix(processed_count, :) = [...  
            global_triangle_id, ...  % Unique Triangle ID
            1, ...                  % Property ID (default: 1)
            G1, ...                 % G1 (Global ID)
            G2, ...                 % G2 (Global ID)
            G3, ...                 % G3 (Global ID)
            0, ...                  % THETA (default: 0)
            0 ...                   % ZOFFS (default: 0)
        ];

        % Increment unique ID
        global_triangle_id = global_triangle_id + 1;
    end

    % Remove unprocessed rows (if any)
    triangles_matrix = triangles_matrix(~any(isnan(triangles_matrix), 2), :);

    % Display summary
    num_unprocessed = num_triangles - processed_count;
    if num_unprocessed > 0
        warning('%d triangles were not processed and have been removed.', num_unprocessed);
    end

    fprintf('Successfully processed %d triangles.\n', processed_count);
end

% Helper function to find global IDs based on the tag
function [G1, G2, G3] = find_global_tri_ids(current_tri, combined_nodes_3D)
    % FIND_GLOBAL_QUAD_IDS: Determines the Global IDs for G1, G2, G3, and G4 based on the tag.
    %
    % Inputs:
    %   current_tri - Row from the quads table (current quad being processed).
    %   combined_nodes_3D - Table containing node data and their metadata.
    %
    % Outputs:
    %   G1, G2, G3, G4 - Global IDs for the 4 nodes of the quad.

        % Analyze
    [num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes_3D);
    

    switch current_tri.tags

        case "tri front"
            node_result1 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_1 & ...
                                             combined_nodes_3D.rib_index == -2 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
            
            node_result2 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_1 & ...
                                             combined_nodes_3D.rib_index == rib_ranges(current_tri.stringer_1,3) & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
            node_result3 = combined_nodes_3D(combined_nodes_3D.stringer_index == -1 & ...
                                             combined_nodes_3D.rib_index == rib_ranges(current_tri.stringer_1,3) & ...
                                             combined_nodes_3D.tag == 'front spars' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
        case "tri root"
            % P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib-1, :); % Top-right
            % P_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib-1,:);       % Bottom-right                   % Top-left
            % P_6 = next_stringer_nodes(next_stringer_nodes.rib_index == -1, :);  

            node_result1 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_2 & ...
                                             combined_nodes_3D.rib_index == rib_ranges(current_tri.stringer_1,2)-1 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
            
            node_result2 = combined_nodes_3D(combined_nodes_3D.stringer_index == -2 & ...
                                             combined_nodes_3D.rib_index == rib_ranges(current_tri.stringer_1,2)-1 & ...
                                             combined_nodes_3D.tag == 'rear spars' & ...
                                             combined_nodes_3D.h == current_tri.h, :);

            node_result3 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_2 & ...
                                             combined_nodes_3D.rib_index == -1 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
        case "tri corner root"
            
            % node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
            % node_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib,:); % Bottom-left
            % node_3 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);
            % 
            %     -2, ...            % stringer_1
            %     1, ...        % stringer_2
            %      -1, ...                 % rib_1
            %      start_rib, ...                        % rib_2

            node_result1 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_2 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_2 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
            
            node_result2 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_1 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_2 & ...
                                             combined_nodes_3D.tag == 'rear spars' & ...
                                             combined_nodes_3D.h == current_tri.h, :);

            node_result3 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_2 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_1 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
        case "tri last front"
            
            
            % node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -2,:);
            % node_2 = current_stringer_nodes(current_stringer_nodes.rib_index == rib_ranges(max_stringer_index,3),:);       % Bottom-right
            % node_3 = combined_nodes(combined_nodes.rib_index == rib_ranges(max_stringer_index,3) & combined_nodes.tag == 'front spars',:);  
            % 
            % max_stringer_index, ...            % stringer_1
            % -1, ...        % stringer_2
            % rib_ranges(max_stringer_index,3), ...                 % rib_1
            % -2, ...                        % rib_2
            node_result1 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_1 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_2 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
            
            node_result2 = combined_nodes_3D(combined_nodes_3D.stringer_index == current_tri.stringer_1 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_1 & ...
                                             combined_nodes_3D.tag == 'stringer' & ...
                                             combined_nodes_3D.h == current_tri.h, :);

            node_result3 = combined_nodes_3D(combined_nodes_3D.stringer_index == -1 & ...
                                             combined_nodes_3D.rib_index == current_tri.rib_1 & ...
                                             combined_nodes_3D.tag == 'front spars' & ...
                                             combined_nodes_3D.h == current_tri.h, :);
        otherwise
            error('Unknown tag: %s', current_tri.tags);
    end

    % Extract the Global IDs
    if height(node_result1) == 1 && height(node_result2) == 1 && ...
       height(node_result3) == 1
        G1 = node_result1.global_id;
        G2 = node_result2.global_id;
        G3 = node_result3.global_id;
        
    else
        current_tri
        node_result1
        node_result2
        node_result3
        warning('Ambiguity or missing nodes for quad tag %s. Skipping this quad.', current_tri.tags);
        G1 = NaN; G2 = NaN; G3 = NaN; 
    end
end

