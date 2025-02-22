function lines_matrix = process_lines_v5(combined_nodes_3D_processed, lines)
% PROCESS_LINES_V4: Processes lines to follow the format required by write_bdf_lines,
% ensuring unique global Line IDs.
%
% Inputs:
%   combined_nodes_3D_processed - Table containing node coordinates and global IDs.
%   lines - Table containing 'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 
%           'rib_2', 'stringer_index', and other metadata.
%
% Output:
%   lines_matrix - Nx4 matrix where each row corresponds to a line:
%                  [Line ID (unique), Property ID, Point1 (Global ID), Point2 (Global ID)]
%
% Example:
%   lines_matrix = process_lines_v4(combined_nodes_3D_processed, lines);

    % Input Validation
    if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
        error('The combined_nodes_3D_processed table must contain a "global_id" column.');
    end
    if ~all(ismember({'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 'rib_2', 'stringer_index'}, lines.Properties.VariableNames))
        error('The lines table must contain "local_id", "node_1", "node_2", "tag", "rib_1", "rib_2", and "stringer_index" columns.');
    end

    % Initialize Result
    num_lines = height(lines);
    max_possible_lines = num_lines; % Maximum lines to preallocate
    lines_matrix = NaN(max_possible_lines, 4); % Preallocate [Line ID, Property ID, Point1, Point2]
    
    global_line_id = 1; % Initialize unique global Line ID counter
    processed_count = 0; % Counter for successfully processed lines

    % Step 1: Process Each Line
    for i = 1:num_lines
        % Extract the current line
        current_line = lines(i, :);
        current_tag = current_line.tag

        % Perform specific operations for each tag
        switch current_tag
            case "stringer wing"
                for j = 1:height(tag_lines)
                    current_line = tag_lines(j, :);

                    % Find nodes for Point1 and Point2
                    node_result1 = combined_nodes_3D_processed( ...
                        combined_nodes_3D_processed.rib_index == current_line.rib_1 & ...
                        combined_nodes_3D_processed.h == "extrados" & ...
                        combined_nodes_3D_processed.stringer_index == current_line.stringer_index & ...
                        combined_nodes_3D_processed.tag == "stringer", :);

                    node_result2 = combined_nodes_3D_processed( ...
                        combined_nodes_3D_processed.rib_index == current_line.rib_2 & ...
                        combined_nodes_3D_processed.h == "extrados" & ...
                        combined_nodes_3D_processed.stringer_index == current_line.stringer_index & ...
                        combined_nodes_3D_processed.tag == "stringer", :);

                    % Check if multiple or zero results are found
                    if height(node_result1) ~= 1 || height(node_result2) ~= 1
                        warning(['Ambiguity or missing nodes for line local_id %d. Skipping this line.\n' ...
                                 'rib_1: %d, rib_2: %d, stringer_index: %d'], ...
                                current_line.local_id, current_line.rib_1, ...
                                current_line.rib_2, current_line.stringer_index);
                        continue;
                    end

                    % Assign global IDs to the line
                    Point1 = node_result1.global_id;
                    Point2 = node_result2.global_id;

                    % Update the Point1 and Point2 columns in the lines table
                    idx = find(lines.local_id == current_line.local_id); % Get the index in the original table


                    lines_matrix(processed_count, :) = [... 
                            global_line_id, ...      % Unique Line ID
                            1, ...                  % Property ID (default to 1)
                            Point1, ...             % Point1 (Global ID)
                            Point2 ...              % Point2 (Global ID)
                        ];
                    
                    % Increment the unique Line ID
                    global_line_id = global_line_id + 1;

                end

            % Add other tag cases ("barra costilla fuselaje", "barra costilla", etc.) as needed.

            otherwise
                sprintf('Unknown tag: %s. Skipping processing.', current_tag);
                % warning('Unknown tag: %s. Skipping processing.', current_tag);
        end

        
    end

    % Step 2: Remove Unprocessed Rows
    lines_matrix = lines_matrix(~any(isnan(lines_matrix), 2), :);

    % Display Summary
    num_unprocessed = num_lines - processed_count;
    if num_unprocessed > 0
        warning('%d lines were not processed and have been removed.', num_unprocessed);
    end

    disp(sprintf('Successfully processed %d lines.', processed_count));
end
