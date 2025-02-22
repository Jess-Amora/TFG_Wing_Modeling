function [x_int, y_int] = point_slope_intersection(x1, y1, m1, x2, y2, m2)
    % Calculate intersection of two lines defined by a point and slope.
    %
    % Line 1: Passes through (x1, y1) with slope m1
    % Line 2: Passes through (x2, y2) with slope m2
    %
    % Outputs:
    %   x_int, y_int: Intersection coordinates (empty if lines are parallel)

    % Handle vertical lines by treating slopes as Inf
    if isinf(m1)
        % Line 1 is vertical: x = x1
        x_int = x1;
        y_int = m2 * (x1 - x2) + y2; % Line 2 equation
    elseif isinf(m2)
        % Line 2 is vertical: x = x2
        x_int = x2;
        y_int = m1 * (x2 - x1) + y1; % Line 1 equation
    else
        % General case: Solve using the equations
        % y = m1 * (x - x1) + y1
        % y = m2 * (x - x2) + y2

        % Solve for x
        x_int = (m1 * x1 - m2 * x2 + y2 - y1) / (m1 - m2);

        % Solve for y
        y_int = m1 * (x_int - x1) + y1;
    end

    % Check if the lines are parallel (m1 == m2)
    if abs(m1 - m2) < 1e-10
        x_int = [];
        y_int = [];
        warning('Lines are parallel and do not intersect.');
    end
end
