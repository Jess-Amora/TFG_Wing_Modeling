function lines_updated = process_lines_v2(combined_nodes_3D_processed, lines)
% PROCESS_LINES_V2: Map local node IDs in the lines table to global IDs,
% process lines based on their tags, and remove unprocessed lines.
%
% Inputs:
%   combined_nodes_3D_processed - Table containing node coordinates and global IDs
%                                 ('x', 'y', 'z', 'global_id', and other metadata expected).
%   lines - Table containing 'node_1', 'node_2', 'tag', and other metadata.
%
% Outputs:
%   lines_updated - Updated lines table with processed rows only.
%                   Rows with unprocessed lines are removed.
%
% Behavior:
%   - Adds 'Point1' and 'Point2' columns to map global IDs.
%   - Removes unprocessed lines (those with NaN in 'Point1' or 'Point2').
%   - Warns about lines that were skipped.

    % Step 1: Input Validation
    if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
        error('The combined_nodes_3D_processed table must contain a "global_id" column.');
    end
    if ~all(ismember({'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 'stringer_index'}, lines.Properties.VariableNames))
        error('The lines table must contain "local_id", "node_1", "node_2", "tag", "rib_1", and "stringer_index" columns.');
    end

    % Step 2: Add Point1 and Point2 columns to the lines table
    lines.Point1 = NaN(height(lines), 1); % Preallocate Point1
    lines.Point2 = NaN(height(lines), 1); % Preallocate Point2

    % Step 3: Process lines based on their tags
    unique_tags = unique(lines.tag); % Get all unique tags
    for i = 1:length(unique_tags)
        current_tag = unique_tags(i);
        fprintf('Processing tag: %s\n', current_tag);

        % Isolate lines with the current tag
        tag_filter = lines.tag == current_tag;
        tag_lines = lines(tag_filter, :);

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
                    lines.Point1(idx) = Point1;
                    lines.Point2(idx) = Point2;
                end

            % Add other tag cases ("barra costilla fuselaje", "barra costilla", etc.) as needed.

            otherwise
                sprintf('Unknown tag: %s. Skipping processing.', current_tag);
                % warning('Unknown tag: %s. Skipping processing.', current_tag);
        end
    end

    % Step 4: Remove unprocessed lines
    unprocessed_filter = isnan(lines.Point1) | isnan(lines.Point2); % Lines with NaN in Point1 or Point2
    num_unprocessed = sum(unprocessed_filter);

    if num_unprocessed > 0
        % warning('%d lines were not processed and will be removed.', num_unprocessed);
        unprocessed_lines = lines(unprocessed_filter, :); % Extract unprocessed lines for debugging

        % Log unprocessed lines (optional)
        % disp('Unprocessed lines:');
        % disp(unprocessed_lines(:, {'local_id', 'tag', 'Point1', 'Point2'}));
    end

    % Retain only processed lines
    lines_updated = lines(~unprocessed_filter, :);
    disp('Successfully processed all tags and removed unprocessed lines.');
end
