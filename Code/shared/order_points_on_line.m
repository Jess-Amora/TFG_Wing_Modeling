function ordered_coords = order_points_on_line(points)
    % Order randomly distributed points along a line based on their position.
    %
    % INPUT:
    % - points: Nx3 matrix of x, y, z coordinates
    %
    % OUTPUT:
    % - ordered_coords: Nx3 matrix of ordered coordinates

    % Number of points
    num_points = size(points, 1);

    % Initialize ordered list with the first point
    ordered_coords = points(1, :);
    
    % Remaining points
    remaining_coords = points(2:end, :);

    % Iteratively find the nearest neighbor
    while size(remaining_coords, 1) > 0
        % Get the last point in the ordered list
        last_point = ordered_coords(end, :);
        
        % Calculate Euclidean distance to all remaining points
        distances = vecnorm(remaining_coords - last_point, 2, 2);
        
        % Find the nearest point
        [~, nearest_idx] = min(distances);
        
        % Add the nearest point to the ordered list
        ordered_coords = [ordered_coords; remaining_coords(nearest_idx, :)];
        
        % Remove the nearest point from the remaining list
        remaining_coords(nearest_idx, :) = [];
    end
end
