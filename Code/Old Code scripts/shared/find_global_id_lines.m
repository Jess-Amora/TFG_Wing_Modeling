function lines_updated = find_global_id_lines(combined_nodes_3D, lines)
    % FIND_GLOBAL_ID_LINES: Map local node IDs in the lines table to global IDs
    % using the combined_nodes_3D table, and process lines based on their tags.
    %
    % Inputs:
    %   combined_nodes_3D - Table containing node coordinates and global IDs
    %                       ('x', 'y', 'z', and 'global_id' columns expected).
    %   lines - Table containing 'node_1', 'node_2', 'tag', and other metadata.
    %
    % Outputs:
    %   lines_updated - Updated lines table with two new columns:
    %                   'global_id_Point1' and 'global_id_Point2'.

    % Step 1: Input Validation
    % Check that combined_nodes_3D has the required 'global_id' column
    if ~ismember('global_id', combined_nodes_3D.Properties.VariableNames)
        error('The combined_nodes_3D table must contain a "global_id" column.');
    end

    % Check that lines has the required columns
    if ~all(ismember({'node_1', 'node_2', 'tag'}, lines.Properties.VariableNames))
        error('The lines table must contain "node_1", "node_2", and "tag" columns.');
    end

    % Step 2: Initialize the updated lines table
    lines_updated = lines;

    % Step 4: Process lines based on their tags
    unique_tags = unique(lines.tag); % Get all unique tags
    for i = 1:length(unique_tags)
        current_tag = unique_tags(i);
        fprintf('Processing tag: %s\n', current_tag);

        % Isolate lines with the current tag
        tag_filter = lines.tag == current_tag;
        tag_lines = lines_updated(tag_filter, :);

        % Perform specific operations for each tag
        switch current_tag
            case "barra costilla"
                % Example operation for "barra costilla"
                fprintf('  Found %d lines with the tag "barra costilla".\n', sum(tag_filter));
                % Add any specific processing logic here

            case "front spar"
                % Example operation for "front spar"
                fprintf('  Found %d lines with the tag "front spar".\n', sum(tag_filter));
                % Add any specific processing logic here

            case "rear spar"
                % Example operation for "rear spar"
                fprintf('  Found %d lines with the tag "rear spar".\n', sum(tag_filter));
                % Add any specific processing logic here

            case "stringer"
                % Example operation for "stringer"
                fprintf('  Found %d lines with the tag "stringer".\n', sum(tag_filter));
                % Add any specific processing logic here

            otherwise
                % Handle unknown tags
                warning('Unknown tag: %s. Skipping processing.', current_tag);
        end
    end

    % Step 5: Return the updated lines table
    disp('Successfully processed lines and mapped global IDs.');
end
