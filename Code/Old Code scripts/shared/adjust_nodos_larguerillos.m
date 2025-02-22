function updated_node_vector = adjust_nodos_larguerillos(node_vector, slope, perpendicular_slope, ribs_total, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance)
% Adjusts nodos_larguerillos by removing or inserting nodes based on proximity and geometry.
%
% Inputs:
%   node_vector: 1xNx4 matrix of node data [x, y, rib_index, stringer_index]
%   slope: Desired slope of the rear spar
%   perpendicular_slope: Slope perpendicular to the rear spar
%   ribs_total: Number of ribs to check for insertion
%   distancia_entre_larguerillo_vertical: Distance between stringers
%   alfa_larguero_posterior_radianes: Angle for perpendicular node calculation
%   threshold_distance: Minimum distance threshold to avoid duplicate nodes
%
% Outputs:
%   updated_node_vector: 1xMx4 matrix with nodes adjusted

    %% Validate Inputs
    if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 4
        error('Node vector must be a 1xNx4 matrix ([x, y, rib_index, stringer_index]).');
    end
    
    % Initialize updated_node_vector
    updated_node_vector = node_vector;
    
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
        updated_node_vector(:, end, :) = [];
        disp('✅ Last node removed due to close proximity to the penultimate node.');
    else
        %% Case 2: Insert Perpendicular Node
        % Calculate delta x and delta y for perpendicular node
        delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + perpendicular_slope^2);
        delta_y = perpendicular_slope * delta_x;
        
        % Calculate perpendicular point
        x2 = last_node(1) - delta_x;
        y2 = last_node(2) - delta_y;
        
        % Insert new perpendicular node using the existing function
        updated_node_vector = insert_perpendicular_node_v4(updated_node_vector, slope, [x2, y2], ribs_total);
        disp('✅ Perpendicular node successfully inserted.');
    end
end
