function [combined_nodes, Inserted_node] = add_perpendicular_node_to_root(combined_nodes, stringer_index, geometria,datosEstructural)
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
    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index & ...
                               combined_nodes.rib_index == -1, :);

    if isempty(end_point)
        warning('No end point found for stringer index %d near the front spar.', stringer_index + 1);
        return;
    end

    distancia_entre_larguerillo_vertical = distancia_entre_larguerillo/cos(alfa_larguero_posterior_radianes);

    delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + pendiente_perpendicular_larguero_posterior^2);
    delta_y = pendiente_perpendicular_larguero_posterior * delta_x;
    
    % Calculate perpendicular point
    x_new = end_point.x + delta_x;
    y_new = end_point.y + delta_y;
    
    % 🟢 Step 3: Insert New Node into Combined Nodes
    Inserted_node = table(1, x_new, y_new, 3e5, stringer_index + 1, "stringer", ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

    combined_nodes = add_nodes_to_combined_nodes_v2(combined_nodes, Inserted_node);
    % disp('✅ Perpendicular node successfully added to root.');

end
