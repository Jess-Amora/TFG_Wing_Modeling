function save_nodes_to_csv(nodes_table)
    % Save points (x, y, z) to a .csv file
    points_csv_filename = './output/points.csv';
    
    % Ensure the output directory exists
    if ~exist('./output', 'dir')
        mkdir('./output');
    end
    
    % Select only the x, y, and z columns from combined_nodes_3D_processed
    points_table = nodes_table(:, {'x', 'y', 'z'});
    
    % Write the table to a CSV file
    writetable(points_table, points_csv_filename, 'WriteVariableNames', true, ...
        'FileType', 'text');
    % Display confirmation message
    disp(['Points saved to ', points_csv_filename]);

end