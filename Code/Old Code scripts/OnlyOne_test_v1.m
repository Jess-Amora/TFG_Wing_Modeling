function OnlyOne_test_v1(combined_nodes_3D, lines)
    % MASTER FUNCTION TO CONTROL THE WORKFLOW
    % This function:
    % 1. Saves the combined_nodes_3D table to a CSV file.
    % 2. Processes the lines table, mapping it to the global_id from combined_nodes_3D.
    % 3. Saves the processed lines table to a CSV file.

    % Step 1: Save the combined_nodes_3D table to a CSV file
    combined_nodes_3D_processed = process_nodes(combined_nodes_3D)
    save_nodes_to_csv(combined_nodes_3D_processed);

    % Step 2: Map lines to global IDs from combined_nodes_3D
    lines = process_lines(combined_nodes_3D_processed, lines);
    save_lines_to_csv(lines);

end

%% Subfunction 1: Save nodes to CSV



% function OnlyOne_test_v1(nodes,lines)
%     % MASTER FUNCTION TO CONTROL THE WORKFLOW
%     % 1. Process nodes
%     % 2. Process surfaces
%     % 3. Process lines
% 
%     % Save points to a .csv file
%     points_table = array2table(nodes, 'VariableNames', {'x', 'y', 'z'});
%     writetable(points_table, './output/points.csv');
% 
%     % Save elements to a .csv file
%     elements_table = array2table(lines, 'VariableNames', {'Point1', 'Point2'});
%     writetable(elements_table, './output/elements.csv');
% end
