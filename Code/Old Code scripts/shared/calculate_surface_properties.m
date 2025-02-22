function [area, aspect_ratio] = calculate_surface_properties(surface_nodes, surface_type)
    % calculate_surface_properties: Computes area and aspect ratio for a surface.
    %
    % Inputs:
    %   surface_nodes: Nx2 matrix of node coordinates [x, y].
    %   surface_type: 'quad' for quadrilaterals, 'triangle' for triangles.
    %
    % Outputs:
    %   area: Calculated area of the surface.
    %   aspect_ratio: Aspect ratio of the surface.

    switch lower(surface_type)
        case 'quad'
            % Ensure 4 nodes
            if size(surface_nodes, 1) ~= 4
                error('Quadrilateral must have 4 nodes.');
            end
            % Diagonals
            d1 = norm(surface_nodes(1, :) - surface_nodes(3, :));
            d2 = norm(surface_nodes(2, :) - surface_nodes(4, :));
            % Aspect ratio
            aspect_ratio = max(d1, d2) / min(d1, d2);

            % Calculate area using the shoelace formula
            x = surface_nodes(:, 1);
            y = surface_nodes(:, 2);
            area = 0.5 * abs(sum(x .* circshift(y, -1)) - sum(y .* circshift(x, -1)));

        case 'triangle'
            % Ensure 3 nodes
            if size(surface_nodes, 1) ~= 3
                error('Triangle must have 3 nodes.');
            end
            % Edge lengths
            e1 = norm(surface_nodes(1, :) - surface_nodes(2, :));
            e2 = norm(surface_nodes(2, :) - surface_nodes(3, :));
            e3 = norm(surface_nodes(3, :) - surface_nodes(1, :));
            % Aspect ratio
            aspect_ratio = max([e1, e2, e3]) / min([e1, e2, e3]);

            % Calculate area using Heron's formula
            s = (e1 + e2 + e3) / 2;
            area = sqrt(s * (s - e1) * (s - e2) * (s - e3));

        otherwise
            error('Unsupported surface type: %s', surface_type);
    end
end
