function combined_nodes_table = create_combined_node_table(nodos_larguerillos, nodos_largueros_anterior, nodos_largueros_posterior)
    % create_combined_node_table: Combines larguerillos, front spars, and rear spars nodes into a unified table.
    %
    % Inputs:
    %   nodos_larguerillos: Nx5 or Nx6 numeric matrix for larguerillo nodes
    %   nodos_largueros_anterior: Mx2 numeric matrix for front spar nodes
    %   nodos_largueros_posterior: Kx2 numeric matrix for rear spar nodes
    %
    % Output:
    %   combined_nodes_table: Table combining all nodes with standardized columns:
    %       - local_id: Unified node ID starting from 1 to N
    %       - x: X Coordinate
    %       - y: Y Coordinate
    %       - rib_index: Rib Index
    %       - stringer_index: Stringer Index (NaN if not applicable)
    %       - tag: Node Tag (e.g., 'stringer', 'front spars', 'rear spars')

    % Convert larguerillos (stringer nodes)
    larguerillos_table = convert_nodes_to_table(nodos_larguerillos);

    % Convert front spar nodes
    front_spars_table = convert_nodes_front_spars_to_table(nodos_largueros_anterior);

    % Convert rear spar nodes
    rear_spars_table = convert_nodes_rear_spars_to_table(nodos_largueros_posterior);

    % Combine all node tables
    combined_nodes_table = [
        larguerillos_table;  % Append stringer nodes
        front_spars_table;   % Append front spar nodes
        rear_spars_table     % Append rear spar nodes
    ];

    % Assign new unified local_id
    total_nodes = size(combined_nodes_table, 1);
    combined_nodes_table.local_id = (1:total_nodes)';

    % Display success message
    disp('✅ Combined node table successfully created with unified local IDs.');
end
