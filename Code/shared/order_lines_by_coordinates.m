function ordered_lines_table = order_lines_by_coordinates(lines_table, distance_threshold)
    % order_lines_by_coordinates: Orders points in lines_table based on spatial continuity.
    %
    % INPUTS:
    % - lines_table: Table containing columns ['x', 'y', 'z'] representing points of different lines.
    % - distance_threshold: Maximum allowed distance between two consecutive points in a line before a warning is triggered.
    %
    % OUTPUT:
    % - ordered_lines_table: Table with ordered points per line.
    %
    % WARNINGS:
    % - If a point is detected outside the expected path of a line, a warning is displayed.
    % - If two consecutive points are further apart than the threshold, a warning is displayed.
    %
    % Example usage:
    % ordered_table = order_lines_by_coordinates(lines_table, 1.5);
    
    % Check if required columns exist
    required_columns = {'x', 'y', 'z', 'Line_ID'};
    for i = 1:length(required_columns)
        if ~ismember(required_columns{i}, lines_table.Properties.VariableNames)
            error('Table does not contain the required column: %s', required_columns{i});
        end
    end

    % Extract unique line IDs
    unique_lines = unique(lines_table.Line_ID);
    ordered_lines_table = table(); % Initialize output table

    % Loop through each unique line
    for i = 1:length(unique_lines)
        line_id = unique_lines(i);
        
        % Extract points for the current line
        line_points = lines_table(lines_table.Line_ID == line_id, :);
        
        % Convert x, y, z coordinates into a numeric matrix
        coords = [line_points.x, line_points.y, line_points.z];
        
        % Order points using Nearest-Neighbor method
        ordered_indices = order_points_nearest_neighbor(coords);
        ordered_line_points = line_points(ordered_indices, :);
        
        % Check for points that are outside the expected path
        if check_outside_points(coords(ordered_indices, :))
            warning('⚠️ Warning: Some points in Line_ID %d appear outside the expected path.', line_id);
        end

        % Check for unusually long gaps between points
        distances = vecnorm(diff(coords(ordered_indices, :)), 2, 2);
        if any(distances > distance_threshold)
            warning('⚠️ Warning: Large gap detected in Line_ID %d. Some points are further than %.2f units apart.', line_id, distance_threshold);
        end
        
        % Append ordered points to the output table
        ordered_lines_table = [ordered_lines_table; ordered_line_points];
    end
end

%% Helper function: Order points using Nearest-Neighbor method
function ordered_indices = order_points_nearest_neighbor(coords)
    % Orders a set of points in a line based on spatial continuity.
    num_points = size(coords, 1);
    ordered_indices = zeros(num_points, 1);
    ordered_indices(1) = 1; % Start from the first point
    remaining_indices = 2:num_points;
    
    for i = 2:num_points
        last_point = coords(ordered_indices(i-1), :);
        remaining_coords = coords(remaining_indices, :);
        distances = vecnorm(remaining_coords - last_point, 2, 2); % Euclidean distance
        [~, min_idx] = min(distances);
        
        ordered_indices(i) = remaining_indices(min_idx);
        remaining_indices(min_idx) = []; % Remove the selected index
    end
end

%% Helper function: Check for points outside the expected line path
function is_outside = check_outside_points(ordered_coords)
    % Checks if any points deviate significantly from the expected straight-line path.
    % If points are aligned correctly, they should follow a linear path.
    
    % Fit a plane to the ordered points
    [~, ~, V] = svd(ordered_coords - mean(ordered_coords, 1), 'econ');
    normal_vector = V(:, end); % The normal to the best-fit plane

    % Compute distances of all points to this plane
    distances_to_plane = abs((ordered_coords - mean(ordered_coords, 1)) * normal_vector);
    
    % Define a threshold for acceptable deviations (adjustable)
    deviation_threshold = 0.01; % Small tolerance for numerical precision
    is_outside = any(distances_to_plane > deviation_threshold);
end
