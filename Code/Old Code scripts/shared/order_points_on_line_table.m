function ordered_table = order_points_on_line_table(input_table)
    % Orders a table of points based on their position along a line.
    % The input and output are tables with columns similar to combined_nodes_3D.
    %
    % INPUT:
    % - input_table: A table with at least 'x', 'y', 'z' columns
    %
    % OUTPUT:
    % - ordered_table: A table with rows reordered based on the line position.

    % Extract the x, y, z coordinates from the table
    coords = [input_table.x, input_table.y, input_table.z];

    % Initialize the ordered list with the first point
    ordered_coords = coords(1, :);
    ordered_indices = 1; % Keep track of the row indices in the original table

    % Remaining points to process
    remaining_coords = coords(2:end, :);
    remaining_indices = 2:height(input_table);

    % Iteratively find the nearest neighbor
    while ~isempty(remaining_coords)
        % Get the last point in the ordered list
        last_point = ordered_coords(end, :);

        % Compute Euclidean distances to all remaining points
        distances = vecnorm(remaining_coords - last_point, 2, 2);

        % Find the index of the nearest neighbor
        [~, nearest_idx] = min(distances);

        % Add the nearest point to the ordered list
        ordered_coords = [ordered_coords; remaining_coords(nearest_idx, :)];
        ordered_indices = [ordered_indices; remaining_indices(nearest_idx)];

        % Remove the nearest point from the remaining list
        remaining_coords(nearest_idx, :) = [];
        remaining_indices(nearest_idx) = [];
    end

    % Reorder the table based on the computed order
    ordered_table = input_table(ordered_indices, :);
end
