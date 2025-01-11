function [updated_node_vector, inserted_nodes] = adjust_nodos_larguerillos_v3(...
    node_vector, slope, perpendicular_slope, ribs_total, distancia_entre_larguerillo_vertical, ...
    alfa_larguero_posterior_radianes, threshold_distance, stringer_index)
% Adjusts nodes by removing or inserting nodes based on geometry, tracking inserted nodes separately.
%
% Inputs:
%   node_vector: Original vector of nodes [x, y, rib_index, stringer_index].
%   slope: Slope of the main structure.
%   perpendicular_slope: Perpendicular slope to the main structure.
%   ribs_total: Total number of ribs in the structure.
%   distancia_entre_larguerillo_vertical: Distance between stringers.
%   alfa_larguero_posterior_radianes: Angle in radians for orientation adjustment.
%   threshold_distance: Minimum allowed distance between nodes.
%   stringer_index: Index of the stringer being processed.
%
% Outputs:
%   updated_node_vector: Updated vector of nodes after adjustments.
%   inserted_nodes: Table of inserted nodes with columns [x, y, rib_index, stringer_index].

    %% Validate Inputs
    if size(node_vector, 2) < 2
        error('Node vector must have at least two nodes for adjustment.');
    end
    
    % Initialize updated_node_vector and inserted_nodes
    updated_node_vector = node_vector;
    inserted_nodes = table([], [], [], [], ...
        'VariableNames', {'x', 'y', 'rib_index', 'stringer_index'});
    
    %% Check Last Two Nodes for Proximity
    num_nodes = size(updated_node_vector, 1);
    last_node = updated_node_vector(end, :); % Last node [x, y, rib_index, stringer_index]
    penultimate_node = updated_node_vector(end-1, :); % Second-to-last node
    
    % Calculate distance between the last two nodes
    distancia_nodos = sqrt((last_node(1) - penultimate_node(1))^2 + ...
                           (last_node(2) - penultimate_node(2))^2);
    
    if distancia_nodos < threshold_distance
        %% Case 1: Remove Last Node (Nodes too close)
        updated_node_vector(end, :) = [];
        disp('✅ Last node removed due to close proximity to the penultimate node.');
    else
        %% Case 2: Insert Perpendicular Node
        delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + perpendicular_slope^2);
        delta_y = perpendicular_slope * delta_x;
        
        % Calculate perpendicular point
        x2 = last_node(1) - delta_x;
        y2 = last_node(2) - delta_y;
        
        % Create the inserted node
        inserted_node = table(x2, y2, -3, stringer_index, ...
            'VariableNames', {'x', 'y', 'rib_index', 'stringer_index'});
        
        % Append the inserted node to inserted_nodes
        inserted_nodes = [inserted_nodes; inserted_node];
        
        % Append the inserted node to updated_node_vector
        updated_node_vector = [updated_node_vector; [x2, y2, -3, stringer_index]];
        
        disp('✅ Perpendicular node successfully added to the updated node vector.');
    end
end
