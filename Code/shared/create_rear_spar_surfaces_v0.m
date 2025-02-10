function superficie_horizontal_larguero_pasterior = create_rear_spar_surfaces(...
    nodos_larguerillos, start_rib, end_rib, TEMP_ID_BASE_larguero_posterior)
    
    superficie_horizontal_larguero_pasterior = [];
    
    for index_costilla = start_rib:end_rib
        target_ribs = [index_costilla, index_costilla + 1];
        target_stringers = 1;
        
        % Filter nodes for ribs and stringers
        rib1_nodes = nodos_larguerillos(nodos_larguerillos(:, 3) == target_ribs(1) & ...
                                      nodos_larguerillos(:, 4) == target_stringers, :);
        rib2_nodes = nodos_larguerillos(nodos_larguerillos(:, 3) == target_ribs(2) & ...
                                      nodos_larguerillos(:, 4) == target_stringers, :);
        
        if isempty(rib1_nodes) || isempty(rib2_nodes)
            warning('Skipping rib %d: Insufficient nodes detected.', index_costilla);
            continue;
        end
        
        % Extract Node IDs
        node_id_rib1 = rib1_nodes(1, 5);
        node_id_rib2 = rib2_nodes(1, 5);
        
        % Create Surface Panel
        superficie_horizontal_larguero_pasterior = [
            superficie_horizontal_larguero_pasterior; 
            TEMP_ID_BASE_larguero_posterior - target_ribs(1), ...
            TEMP_ID_BASE_larguero_posterior - target_ribs(2), ...
            node_id_rib1, node_id_rib2
        ];
    end
end
