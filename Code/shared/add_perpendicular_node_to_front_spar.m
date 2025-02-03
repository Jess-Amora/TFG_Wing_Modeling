function [combined_nodes, Inserted_node] = add_perpendicular_node_to_front_spar(combined_nodes, stringer_index, geometria,datosEstructural)
    % ADD_PERPENDICULAR_NODE_TO_FRONT_SPAR: Adds a new node perpendicular 
    % to the front spar at a given stringer end point.
    %
    % Inputs:
    %   combined_nodes - Table containing existing nodes.
    %   stringer_index - Index of the stringer where we are inserting the node.
    %   Distancia_larguero_anterior_cuerda_porcentaje - Percentage distance for node placement.
    %   Lf - Reference length.
    %
    % Outputs:
    %   combined_nodes - Updated table with the new inserted node.
    
    % Initialización
    alfa_larguero_posterior_radianes = geometria.alfa_larguero_posterior_radianes;
    pendiente_perpendicular_larguero_posterior = geometria.pendiente_perpendicular_larguero_posterior;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;
    
    % 🟢 Step 1: Identify End Point Near Front Spar
    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                               combined_nodes.rib_index == -2, :);

    if isempty(end_point)
        warning('No end point found for stringer index %d near the front spar.', stringer_index + 1);
        return;
    end


    %% start

    distancia_entre_larguerillo_vertical = distancia_entre_larguerillo/cos(alfa_larguero_posterior_radianes);
    % 
    % slope = pendiente_larguero_posterior;
    % perpendicular_slope = pendiente_perpendicular_larguero_posterior;    
    % % llamar
    % [nodos_larguerillos inserted_nodes_temp]= adjust_nodos_larguerillos_v2( ...
    %     nodos_larguerillos, slope, perpendicular_slope, numero_costillas*2-1, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance);
    % % la function
    % [updated_node_vector, inserted_nodes] = adjust_nodos_larguerillos_v2(...
    % node_vector, slope, perpendicular_slope, ribs_total, distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, threshold_distance)
    % 
    % %% Case 2: Insert Perpendicular Node
    %     delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + perpendicular_slope^2);
    %     delta_y = perpendicular_slope * delta_x;
    % 
    %     % Calculate perpendicular point
    %     x2 = last_node(1) - delta_x;
    %     y2 = last_node(2) - delta_y;

        %% end
    delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + pendiente_perpendicular_larguero_posterior^2);
    delta_y = pendiente_perpendicular_larguero_posterior * delta_x;
    
    % Calculate perpendicular point
    x_new = end_point.x - delta_x;
    y_new = end_point.y - delta_y;
    
    % 🟢 Step 3: Insert New Node into Combined Nodes
    Inserted_node = table(1, x_new, y_new, 2e5, stringer_index, "stringer", ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

    combined_nodes = add_nodes_to_combined_nodes_v2(combined_nodes, Inserted_node);
    % disp('✅ Perpendicular node successfully added to front spar.');

end
