function lines_updated = process_lines_v1(combined_nodes_3D_processed, lines)
    % PROCESS_LINES: Map local node IDs in the lines table to global IDs
    % using the combined_nodes_3D_processed table, and process lines based on their tags.
    %
    % Inputs:
    %   combined_nodes_3D_processed - Table containing node coordinates and global IDs
    %                                 ('x', 'y', 'z', 'global_id', and other metadata expected).
    %   lines - Table containing 'node_1', 'node_2', 'tag', and other metadata.
    %
    % Outputs:
    %   lines_updated - Updated lines table with two new columns:
    %                   'Point1' and 'Point2'.

    % % Step 1: Input Validation
    % % Check that combined_nodes_3D_processed has the required 'global_id' column
    % if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
    %     error('The combined_nodes_3D_processed table must contain a "global_id" column.');
    % end
    % 
    % % Check that lines has the required columns
    % if ~all(ismember({'local_id', 'node_1', 'node_2', 'tag', 'rib_1', 'stringer_index'}, lines.Properties.VariableNames))
    %     error('The lines table must contain "local_id", "node_1", "node_2", "tag", "rib_1", and "stringer_index" columns.');
    % end

    % Step 2: Add Point1 and Point2 columns to the lines table
    % Add these columns initialized to NaN
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
                % Example processing for "barra costilla"
                for j = 1:height(tag_lines)
                    % Extract the current line
                    current_line = tag_lines(j, :);
                    
                    % combined_nodes_3D(combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);

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
                        warning(['Ambiguity or missing nodes for height(node_result1)  %d for height(node_result1)  %d', ...
                                 'Skipping this line.' ...
                                 ' rib 1 %d rib 2 %d stringer 1 %d'],height(node_result1),height(node_result2),current_line.rib_1,current_line.rib_2,current_line.stringer_index);
                        continue; % Skip to the next line
                    end

                    % Assign global IDs to the line
                    Point1 = node_result1.global_id;
                    Point2 = node_result2.global_id;

                    % Update the Point1 and Point2 columns in the lines table
                    idx = find(lines.local_id == current_line.local_id); % Get the index in the original table
                    lines.Point1(idx) = Point1;
                    lines.Point2(idx) = Point2;
                end

            case "barra costilla fuselaje"
                

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

                    % Update the Point1 and Point2 columns in the lines table
                    idx = find(lines.local_id == current_line.local_id); % Get the index in the original table
                    lines.Point1(idx) = Point1;
                    lines.Point2(idx) = Point2;
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
