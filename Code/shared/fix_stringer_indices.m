function fixed_inserted_table = fix_stringer_indices(combined_nodes, inserted_table)
    % fix_stringer_indices: Corrects the stringer_index in the inserted_table by
    % finding the closest stringer_index from the combined_nodes table.
    %
    % Inputs:
    %   combined_nodes: Table containing all the nodes with correct stringer_index.
    %                   Columns: [local_id, x, y, rib_index, stringer_index, tag].
    %   inserted_table: Table containing the inserted nodes with potentially
    %                   incorrect stringer_index.
    %                   Columns: [local_id, x, y, rib_index, stringer_index, tag].
    %
    % Outputs:
    %   fixed_inserted_table: A copy of the inserted_table with corrected stringer_index.

    % Copy the original inserted_table to the output
    fixed_inserted_table = inserted_table;

    % Extract only the stringer nodes from combined_nodes for comparison
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);

    % Ensure that there are stringer nodes available
    if isempty(stringer_nodes)
        error('No stringer nodes found in combined_nodes. Cannot fix stringer_index.');
    end

    % Loop through each row in the inserted_table to correct its stringer_index
    for i = 1:height(inserted_table)
        % Get the x and y coordinates of the current inserted node
        inserted_x = inserted_table.x(i);
        inserted_y = inserted_table.y(i);

        % Calculate the Euclidean distance between this inserted node and all stringer nodes
        distances = sqrt((stringer_nodes.x - inserted_x).^2 + (stringer_nodes.y - inserted_y).^2);

        % Find the index of the closest stringer node
        [~, closest_idx] = min(distances);

        % Assign the stringer_index of the closest node to the current inserted node
        fixed_inserted_table.stringer_index(i) = stringer_nodes.stringer_index(closest_idx);
    end

    % Display success message
    disp('✅ Stringer indices in inserted_table have been successfully corrected.');
end
