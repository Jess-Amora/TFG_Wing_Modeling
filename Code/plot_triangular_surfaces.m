function plot_triangular_surfaces(tri_surfaces, combined_nodes)
    % Extract node coordinates from combined_nodes
    node_coords = table2array(combined_nodes(:, {'x', 'y', 'z'})); % Assuming x, y, z are the columns for coordinates

    % Plot the triangular surfaces
    figure;
    hold on;
    title('Triangular Surfaces');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    axis equal;

    % Loop through each triangular surface
    for i = 1:height(tri_surfaces)
        % Get the node indices for the current triangle
        node_ids = tri_surfaces{i, {'node_1', 'node_2', 'node_3'}};
        
        % Extract coordinates for the triangle vertices
        coords = node_coords(node_ids, :);
        
        % Close the triangle loop by repeating the first vertex
        coords = [coords; coords(1, :)];
        
        % Plot the triangle
        plot3(coords(:, 1), coords(:, 2), coords(:, 3), '-o', 'LineWidth', 1.5);
    end

    hold off;
end
