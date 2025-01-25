function lines_matrix = process_lines_v3(combined_nodes_3D_processed, lines)
% PROCESS_LINES_V3: Processes lines to follow the format required by write_bdf_lines.
%
% Inputs:
%   combined_nodes_3D_processed - Table containing node coordinates and global IDs.
%   lines - Table containing 'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 
%           'rib_2', 'stringer_index', and other metadata.
%
% Output:
%   lines_matrix - Nx4 matrix where each row corresponds to a line:
%                  [Line ID, Property ID, Point1 (Global ID), Point2 (Global ID)]
%
% Example:
%   lines_matrix = process_lines_v3(combined_nodes_3D_processed, lines);

    % Input Validation
    if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
        error('The combined_nodes_3D_processed table must contain a "global_id" column.');
    end
    if ~all(ismember({'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 'rib_2', 'stringer_index'}, lines.Properties.VariableNames))
        error('The lines table must contain "local_id", "node_1", "node_2", "tag", "rib_1", "rib_2", and "stringer_index" columns.');
    end

    % Initialize Result
    num_lines = height(lines);
    lines_matrix = NaN(num_lines, 4); % Preallocate [Line ID, Property ID, Point1, Point2]

    % Step 1: Process Each Line
    for i = 1:num_lines
        % Extract the current line
        current_line = lines(i, :);

        % Find Point1 (Global ID)
        node_result1 = combined_nodes_3D_processed( ...
            combined_nodes_3D_processed.rib_index == current_line.rib_1 & ...
            combined_nodes_3D_processed.h == "extrados" & ...
            combined_nodes_3D_processed.stringer_index == current_line.stringer_index & ...
            combined_nodes_3D_processed.tag == "stringer", :);

        % Find Point2 (Global ID)
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

        % Extract Global IDs for Point1 and Point2
        Point1 = node_result1.global_id;
        Point2 = node_result2.global_id;

        % Assign Line Data
        lines_matrix(i, :) = [...
            current_line.local_id, ... % Line ID
            1,...                        % Property ID (default to 1)
            Point1,...                  % Point1 (Global ID)
            Point2...                    % Point2 (Global ID)
        ];
    end

    % Step 2: Remove Unprocessed Lines
    unprocessed_filter = isnan(lines_matrix(:, 3)) | isnan(lines_matrix(:, 4)); % Lines with NaN in Point1 or Point2
    num_unprocessed = sum(unprocessed_filter);

    if num_unprocessed > 0
        warning('%d lines were not processed and will be removed.', num_unprocessed);
        unprocessed_lines = lines_matrix(unprocessed_filter, :); % Extract unprocessed lines for debugging

        % Log unprocessed lines (optional)
        disp('Unprocessed lines:');
        disp(unprocessed_lines);
    end

    % Keep only processed lines
    lines_matrix = lines_matrix(~unprocessed_filter, :);

    disp('Successfully processed all lines.');
end
