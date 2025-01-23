function save_lines_to_csv(lines_table)

    % Save points (x, y, z) to a .csv file
    lines_csv_filename = './output/lines.csv';
    
    % Ensure the output directory exists
    if ~exist('./output', 'dir')
        mkdir('./output');
    end
    
    % Select only the x, y, and z columns from combined_nodes_3D_processed
    lines_table = lines_table(:, {'Point1', 'Point2'});
    
    % Write the table to a CSV file
    writetable(lines_table, lines_csv_filename);
    
    % % Display confirmation message
    % disp(['Points saved to ', lines_csv_filename]);
end
