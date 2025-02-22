function combined_nodes = create_combined_node_table(larguerillos, anterior, posterior)
    % Merge all node tables
    combined_nodes = [larguerillos; anterior; posterior];
    combined_nodes = sortrows(combined_nodes, {'rib_index', 'stringer_index', 'local_id'});
end
