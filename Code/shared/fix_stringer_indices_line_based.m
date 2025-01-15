function fixed_inserted_table = fix_stringer_indices_line_based(combined_nodes, inserted_table, tolerance)
    % fix_stringer_indices_line_based: Corrects the stringer_index in the
    % inserted_table by checking if nodes lie on defined stringer lines.
    %
    % Inputs:
    %   combined_nodes: Table with all nodes, including stringer definitions.
    %   inserted_table: Table with inserted nodes and potentially incorrect stringer_index.
    %   tolerance: Tolerance for checking if a node lies on a stringer line.
    %
    % Outputs:
    %   fixed_inserted_table: Updated inserted_table with corrected stringer_index.

    % Copy the inserted_table for output
    fixed_inserted_table = inserted_table;

    % Extract stringer nodes from combined_nodes
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);

    % Ensure there are stringer nodes
    if isempty(stringer_nodes)
        error('No stringer nodes found in combined_nodes.');
    end

    % Identify unique stringer indices
    unique_stringers = unique(stringer_nodes.stringer_index);

    % Loop through each node in the inserted_table
    for i = 1:height(inserted_table)
        % Get the coordinates of the current inserted node
        inserted_x = inserted_table.x(i);
        inserted_y = inserted_table.y(i);

        % Flag to track if a match is found
        match_found = false;

        % Loop through each unique stringer
        for stringer_index = unique_stringers'
            % Get all nodes belonging to the current stringer
            current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_index, :);

            % Ensure there are at least two points to define a line
            if height(current_stringer_nodes) < 2
                continue;
            end

            % Sort nodes by rib_index to define the stringer line
            current_stringer_nodes = sortrows(current_stringer_nodes, 'rib_index');

            % Loop through pairs of consecutive points defining segments of the stringer
            for j = 1:height(current_stringer_nodes) - 1
                % Get the endpoints of the current line segment
                x1 = current_stringer_nodes.x(j);
                y1 = current_stringer_nodes.y(j);
                x2 = current_stringer_nodes.x(j + 1);
                y2 = current_stringer_nodes.y(j + 1);

                % Check if the inserted node lies on this line segment
                [is_on_line, distance_to_line] = check_point_on_line_segment(x1, y1, x2, y2, inserted_x, inserted_y, tolerance);

                if is_on_line
                    % Assign the stringer_index and mark as matched
                    fixed_inserted_table.stringer_index(i) = stringer_index;
                    match_found = true;
                    break;
                end
            end

            % If a match is found, exit the loop
            if match_found
                break;
            end
        end

        % If no match is found, find the closest stringer line
        if ~match_found
            closest_distance = Inf;
            closest_stringer = NaN;

            for stringer_index = unique_stringers'
                current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_index, :);

                % Loop through pairs of consecutive points defining segments of the stringer
                for j = 1:height(current_stringer_nodes) - 1
                    x1 = current_stringer_nodes.x(j);
                    y1 = current_stringer_nodes.y(j);
                    x2 = current_stringer_nodes.x(j + 1);
                    y2 = current_stringer_nodes.y(j + 1);

                    % Calculate the distance to the current line segment
                    [~, distance_to_line] = check_point_on_line_segment(x1, y1, x2, y2, inserted_x, inserted_y, tolerance);

                    % Update the closest stringer if necessary
                    if distance_to_line < closest_distance
                        closest_distance = distance_to_line;
                        closest_stringer = stringer_index;
                    end
                end
            end

            % Assign the closest stringer index to the inserted node
            fixed_inserted_table.stringer_index(i) = closest_stringer;
        end
    end

    disp('✅ Stringer indices in inserted_table have been successfully corrected.');
end

function [is_on_line, distance] = check_point_on_line_segment(x1, y1, x2, y2, px, py, tolerance)
    % check_point_on_line_segment: Checks if a point lies on a line segment
    % within a given tolerance and calculates the perpendicular distance.
    %
    % Inputs:
    %   (x1, y1): Start point of the line segment.
    %   (x2, y2): End point of the line segment.
    %   (px, py): Point to check.
    %   tolerance: Distance tolerance for "on line" condition.
    %
    % Outputs:
    %   is_on_line: Boolean indicating if the point lies on the line segment.
    %   distance: Perpendicular distance from the point to the line.

    % Calculate the length of the line segment
    line_length = sqrt((x2 - x1)^2 + (y2 - y1)^2);

    % Handle degenerate case of zero-length line
    if line_length < eps
        distance = sqrt((px - x1)^2 + (py - y1)^2);
        is_on_line = distance <= tolerance;
        return;
    end

    % Project the point onto the line (parametric equation)
    t = ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / (line_length^2);

    % Clamp t to the range [0, 1] to stay within the line segment
    t = max(0, min(1, t));

    % Find the projection point on the line
    proj_x = x1 + t * (x2 - x1);
    proj_y = y1 + t * (y2 - y1);

    % Calculate the perpendicular distance to the line
    distance = sqrt((px - proj_x)^2 + (py - proj_y)^2);

    % Check if the point is within tolerance
    is_on_line = distance <= tolerance;
end
