function quads_matrix = process_quads_v1(combined_nodes_3D, quads)
% PROCESS_QUADS_V1: Processes quads (and optionally triangles) to follow the format required by write_bdf_quads,
% ensuring unique global IDs for the nodes of each quad.
%
% Inputs:
%   combined_nodes_3D - Table containing node coordinates and global IDs.
%   quads - Table containing 'local_id', 'node_1', 'node_2', 'node_3', 'node_4', 'tag', 'rib_1',
%           'rib_2', and other metadata.
%
% Output:
%   quads_matrix - Nx8 matrix where each row corresponds to a quad:
%                  [Quad ID (unique), Property ID, G1 (Global ID), G2 (Global ID),
%                   G3 (Global ID), G4 (Global ID), THETA, ZOFFS].

    % Input Validation
    % Mejor tag que tags
    if ~all(ismember({'local_id', 'node_1', 'node_2', 'node_3', 'node_4', 'tags'}, quads.Properties.VariableNames))
        error('The quads table must contain "local_id", "node_1", "node_2", "node_3", "node_4", and "tag" columns.');
    end
    
    % Initialize Result
    num_quads = height(quads);
    quads_matrix = NaN(num_quads, 8); % Preallocate [Quad ID, PID, G1, G2, G3, G4, THETA, ZOFFS]

    global_quad_id = 1; % Initialize unique global Quad ID counter
    processed_count = 0; % Counter for successfully processed quads

    % Loop through each quad
    for i = 1:num_quads
        % Extract the current quad
        current_quad = quads(i, :);

        % Get G1, G2, G3, G4 using the helper function
        [G1, G2, G3, G4] = find_global_quad_ids(current_quad, combined_nodes_3D);

        % Increment the processed quad count and add to the matrix
        processed_count = processed_count + 1;
        quads_matrix(processed_count, :) = [...  % Add to the result matrix
            global_quad_id, ...     % Unique Quad ID
            1, ...                 % Property ID (default to 1)
            G1, ...                % G1 (Global ID)
            G2, ...                % G2 (Global ID)
            G3, ...                % G3 (Global ID)
            G4, ...                % G4 (Global ID)
            0, ...                 % THETA (default to 0)
            0 ...                  % ZOFFS (default to 0)
        ];

        % Increment the unique Quad ID
        global_quad_id = global_quad_id + 1;
    end

    % Step 2: Remove Unprocessed Rows
    quads_matrix = quads_matrix(~any(isnan(quads_matrix), 2), :);

    % Display Summary
    num_unprocessed = num_quads - processed_count;
    if num_unprocessed > 0
        warning('%d quads were not processed and have been removed.', num_unprocessed);
    end

    fprintf('Successfully processed %d quads.\n', processed_count);
end
