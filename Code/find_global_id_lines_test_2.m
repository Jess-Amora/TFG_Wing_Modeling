function lines_updated = find_global_id_lines_test_2(combined_nodes_3D_processed, lines)
    % FIND_GLOBAL_ID_LINES: Map local node IDs in the lines table to global IDs
    % using the combined_nodes_3D_processed table, and process lines based on their tags.
    %
    % Inputs:
    %   combined_nodes_3D_processed - Table containing node coordinates and global IDs
    %                                 ('x', 'y', 'z', 'global_id', and other metadata expected).
    %   lines - Table containing 'node_1', 'node_2', 'tag', and other metadata.
    %
    % Outputs:
    %   lines_updated - Updated lines table with two new columns:
    %                   'global_id1' and 'global_id2'.

    % Step 1: Input Validation
    % Check that combined_nodes_3D_processed has the required 'global_id' column
    if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
        error('The combined_nodes_3D_processed table must contain a "global_id" column.');
    end

    % Check that lines has the required columns
    if ~all(ismember({'node_1', 'node_2', 'tag'}, lines.Properties.VariableNames))
        error('The lines table must contain "node_1", "node_2", and "tag" columns.');
    end

    % Step 2: Add global_id1 and global_id2 columns to the lines table
    lines.global_id1 = NaN(height(lines), 1); % Preallocate global_id1 as NaN
    lines.global_id2 = NaN(height(lines), 1); % Preallocate global_id2 as NaN

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
            case "barra costilla"
                % Example processing for "barra costilla"
                for j = 1:height(tag_lines)
                    % Extract the current line
                    current_line = tag_lines(j, :);

                    % Find nodes for Point1 and Point2
                    node_result1 = combined_nodes_3D_processed( ...
                        combined_nodes_3D_processed.rib_index == current_line.rib_1 & ...
                        combined_nodes_3D_processed.h == "extrados" & ...
                        combined_nodes_3D_processed.stringer_index == current_line.stringer_index & ...
                        combined_nodes_3D_processed.tag == "stringer", :);

                    node_result2 = combined_nodes_3D_processed( ...
                        combined_nodes_3D_processed.rib_index == current_line.rib_1 & ...
                        combined_nodes_3D_processed.h == "intrados" & ...
                        combined_nodes_3D_processed.stringer_index == current_line.stringer_index & ...
                        combined_nodes_3D_processed.tag == "stringer", :);

                    % Check if multiple or zero results are found
                    if height(node_result1) ~= 1 || height(node_result2) ~= 1
                        warning(['Ambiguity or missing nodes for line local_id %d with tag "barra costilla". ', ...
                                 'Skipping this line.'], current_line.local_id);
                        continue; % Skip to the next line
                    end

                    % Assign global IDs to the line
                    Point1 = node_result1.global_id;
                    Point2 = node_result2.global_id;

                    % Update the global_id columns in the lines table
                    idx = find(lines.local_id == current_line.local_id); % Get the index in the original table
                    lines.global_id1(idx) = Point1;
                    lines.global_id2(idx) = Point2;
                end

            case "front spar"
                % Example processing for "front spar"
                fprintf('  Found %d lines with the tag "front spar".\n', sum(tag_filter));
                % Add any specific processing logic here

            case "rear spar"
                % Example processing for "rear spar"
                fprintf('  Found %d lines with the tag "rear spar".\n', sum(tag_filter));
                % Add any specific processing logic here

            case "stringer"
                % Example processing for "stringer"
                fprintf('  Found %d lines with the tag "stringer".\n', sum(tag_filter));
                % Add any specific processing logic here

            otherwise
                % Handle unknown tags
                warning('Unknown tag: %s. Skipping processing.', current_tag);
        end
    end

    % Step 4: Return the updated lines table
    lines_updated = lines;
    disp('Successfully processed all tags and mapped global IDs.');
end
