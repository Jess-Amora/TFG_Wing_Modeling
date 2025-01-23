function combined_nodes_3D_processed = process_nodes(combined_nodes_3D)
    % PROCESS_NODES: Add a global ID column and save the node data and organization info.
    % Input:
    %   combined_nodes_3D - Input table containing node coordinates (x, y, z).
    % Output:
    %   combined_nodes_3D_processed - Updated table with a global_id column.
    
    % Step 1: Assign a unique global ID
    num_nodes = size(combined_nodes_3D, 1);
    combined_nodes_3D.global_id = (1:num_nodes)'; % Add a new column for Global ID

    % Step 2: Organize nodes by structure parts
    % Define groups based on their indices (example: adjust as per your actual structure)
    node_groups = struct();
    node_groups.rear_spar_extrados = 90:400;
    node_groups.leading_edge = 401:800;
    % Add more groups as needed

    % Step 3: Save to CSV
    % Save the updated combined_nodes_3D table to a CSV file
    csv_filename = './output/nodes_output.csv';
    if ~exist('./output', 'dir')
        mkdir('./output'); % Create the output directory if it doesn't exist
    end
    writetable(combined_nodes_3D, csv_filename);
    disp(['Nodes saved to ', csv_filename]);

    % Step 4: Save organization information to TXT
    txt_filename = './output/nodes_organization.txt';
    fileID = fopen(txt_filename, 'w');
    fprintf(fileID, 'Global Node Organization\n\n');
    fprintf(fileID, 'Rear Spar Extrados: Nodes %d to %d\n', ...
        min(node_groups.rear_spar_extrados), max(node_groups.rear_spar_extrados));
    fprintf(fileID, 'Leading Edge: Nodes %d to %d\n', ...
        min(node_groups.leading_edge), max(node_groups.leading_edge));
    fclose(fileID);
    disp(['Node organization saved to ', txt_filename]);

    % Output the processed table
    combined_nodes_3D_processed = combined_nodes_3D;
end
