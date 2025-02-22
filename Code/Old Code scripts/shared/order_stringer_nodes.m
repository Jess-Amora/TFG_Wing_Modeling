function sorted_nodes = order_stringer_nodes(nodes_3D)
    % Function to order combined_nodes_3D based on y-coordinates and slope (dy/dx),
    % while excluding x for sorting but considering it for grouping.
    %
    % INPUT:
    % - nodes_3D: Table containing x, y, z, and other node properties
    %
    % OUTPUT:
    % - sorted_nodes: Table of nodes ordered based on stringer orientation.

    % Extract x, y, z for processing
    x_coords = nodes_3D.x;
    y_coords = nodes_3D.y;
    z_coords = nodes_3D.z;

    % Create an array to hold the sorting index
    n_nodes = height(nodes_3D);
    sorting_index = zeros(n_nodes, 1);
    
    % Determine orientation
    if is_vertical_stringer(x_coords)
        % Vertical stringer (dy/dx undefined)
        [~, sorting_index] = sort(y_coords); % Sort by y
    elseif is_horizontal_stringer(y_coords)
        % Horizontal stringer (dy/dx = 0)
        [~, sorting_index] = sort(x_coords); % Sort by x (for continuity)
    else
        % Diagonal stringer (dy/dx > 0 or dy/dx < 0)
        % Calculate slopes
        slopes = diff(y_coords) ./ diff(x_coords);
        
        % Sort nodes by slopes and y-coordinates for diagonal continuity
        % (Tie-break by y-coordinates)
        [~, sorting_index] = sortrows([slopes, y_coords(1:end-1)], [1, 2]);
    end

    % Return the ordered nodes
    sorted_nodes = nodes_3D(sorting_index, :);
end

% Helper functions
function is_vertical = is_vertical_stringer(x_coords)
    % Check if the stringer is vertical (all x-coordinates are the same)
    is_vertical = all(abs(diff(x_coords)) < 1e-6);
end

function is_horizontal = is_horizontal_stringer(y_coords)
    % Check if the stringer is horizontal (all y-coordinates are the same)
    is_horizontal = all(abs(diff(y_coords)) < 1e-6);
end
