function [updated_node_vector, inserted_nodes] = adjust_nodos_larguerillos_v2(...
    node_vector, slope, perpendicular_slope, ribs_total, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance)
% Adjusts nodes by removing or inserting nodes based on geometry, tracking inserted nodes separately.

    %% Validate Inputs
    if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 4
        error('Node vector must be a 1xNx4 matrix ([x, y, rib_index, stringer_index]).');
    end
    
    % Initialize updated_node_vector
    updated_node_vector = node_vector;
    inserted_nodes = []; % Separate vector for inserted nodes
    
    %% Check Last Two Nodes for Proximity
    num_nodes = size(updated_node_vector, 2);
    if num_nodes < 2
        warning('Not enough nodes for adjustment.');
        return;
    end
    
    % Extract the last two nodes
    last_node = squeeze(updated_node_vector(1, end, 1:2));
    penultimate_node = squeeze(updated_node_vector(1, end-1, 1:2));
    
    % Calculate distance between the last two nodes
    distancia_nodos = sqrt(sum((last_node - penultimate_node).^2));
    
    if distancia_nodos < threshold_distance
        %% Case 1: Remove Last Node (Nodes too close)
        % updated_node_vector(:, end, :) = [];
        % disp('✅ Last node removed due to close proximity to the penultimate node.');
    else
        %% Case 2: Insert Perpendicular Node
        delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + perpendicular_slope^2);
        delta_y = perpendicular_slope * delta_x;
        
        % Calculate perpendicular point
        x2 = last_node(1) - delta_x;
        y2 = last_node(2) - delta_y;
        
        % Insert perpendicular node and save to `inserted_nodes`
        [inserted_node, was_inserted] = insert_perpendicular_node_v5(updated_node_vector, slope, [x2, y2], ribs_total);
        
        if was_inserted
            inserted_nodes = [inserted_nodes; inserted_node];
            % disp('✅ Perpendicular node successfully added to inserted_nodes.');
        end
    end
end
