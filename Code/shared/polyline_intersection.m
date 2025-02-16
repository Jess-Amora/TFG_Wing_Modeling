% Example alternative using numerical methods (without Mapping Toolbox)
function [xi, yi] = polyline_intersection(x1, y1, x2, y2)
    % Fit lines using polyfit
    p1 = polyfit(x1, y1, 1);
    p2 = polyfit(x2, y2, 1);

    % Find intersection point
    A = [-p1(1), 1; -p2(1), 1];
    b = [p1(2); p2(2)];
    
    if det(A) ~= 0  % Check if lines are not parallel
        sol = A \ b;
        xi = sol(1);
        yi = sol(2);
    else
        xi = [];
        yi = [];
    end
end
% 
% % Usage:
% [x_intersect, y_intersect] = polyline_intersection(x1, y1, x2, y2);
