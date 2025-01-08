function superficie_horizontal_larguero_pasterior = create_rear_spar_surfaces_v2(...
    nodos_larguerillos, start_rib, end_rib, TEMP_ID_BASE_larguero_posterior)
% create_rear_spar_surfaces_v3: Creates horizontal stiffening panels near the rear spar.
%
% Inputs:
%   nodos_larguerillos: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   start_rib: Starting rib index for rear spar surface creation
%   end_rib: Ending rib index for rear spar surface creation
%   TEMP_ID_BASE_larguero_posterior: Base temporary ID for surfaces
%
% Outputs:
%   superficie_horizontal_larguero_pasterior: Matrix of surface definitions [TEMP_ID_1, TEMP_ID_2, Node_ID_1, Node_ID_2]

    %% 🛡️ Validate Inputs
    if ~istable(nodos_larguerillos)
        error('Input "nodos_larguerillos" must be a MATLAB table.');
    end
    
    required_vars = {'local_id', 'x', 'y', 'rib_index', 'stringer_index'};
    if ~all(ismember(required_vars, nodos_larguerillos.Properties.VariableNames))
        error('Table must have the following columns: %s', strjoin(required_vars, ', '));
    end
    
    %% 📝 Initialize Output
    superficie_horizontal_larguero_pasterior = [];
    
    %% 🔍 Filter Valid Nodes
    valid_nodes = nodos_larguerillos(~isnan(nodos_larguerillos.rib_index) & ...
                                     ~isnan(nodos_larguerillos.stringer_index), :);
    
    if isempty(valid_nodes)
        warning('No valid nodes available after filtering.');
        return;
    end
    
    %% 🔄 Loop Through Ribs to Create Surfaces
    for index_costilla = start_rib:end_rib
    target_ribs = [index_costilla, index_costilla + 1];
    target_stringers = 1; % Fixed stringer index for rear spar
    
    rib1_nodes = valid_nodes(valid_nodes.rib_index == target_ribs(1) & ...
                             valid_nodes.stringer_index == target_stringers, :);
    rib2_nodes = valid_nodes(valid_nodes.rib_index == target_ribs(2) & ...
                             valid_nodes.stringer_index == target_stringers, :);
    
    if isempty(rib1_nodes) || isempty(rib2_nodes)
        warning('Skipping rib %d: Insufficient nodes detected.', index_costilla);
        continue;
    end
    
    % Extract Node IDs
    node_id_rib1 = rib1_nodes.local_id(1);
    node_id_rib2 = rib2_nodes.local_id(1);
    
    % Create Surface Panel
    superficie_horizontal_larguero_pasterior = [
        superficie_horizontal_larguero_pasterior; 
        TEMP_ID_BASE_larguero_posterior - target_ribs(1), ...
        TEMP_ID_BASE_larguero_posterior - target_ribs(2), ...
        node_id_rib1, node_id_rib2
    ];
end

    
    %% ✅ Display Success Message
    disp('✅ Rear spar surfaces successfully created.');
end
