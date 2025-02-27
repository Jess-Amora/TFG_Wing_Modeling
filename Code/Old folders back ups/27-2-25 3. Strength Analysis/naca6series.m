function airfoil = naca6series(m, p, t, c, num_points, show_graph)
    % Computes a NACA 6-series airfoil and returns the data as a struct.
    %
    % Inputs:
    %   - m: Maximum camber (fraction of chord)
    %   - p: Position of maximum camber (fraction of chord)
    %   - t: Maximum thickness (fraction of chord)
    %   - c: Chord length
    %   - num_points: Number of points along the chord
    %   - show_graph: Boolean flag to display the airfoil plot
    %
    % Output:
    %   - airfoil: Struct containing x, y_upper, y_lower, and other parameters

    % x-coordinates along the chord (linear spacing)
    x = linspace(0, c, num_points);

    % Thickness distribution (NACA 6-series)
    y_t = 5 * t * c * (0.2969 * sqrt(x / c) - 0.1260 * (x / c) - ...
                       0.3516 * (x / c).^2 + 0.2843 * (x / c).^3 - ...
                       0.1015 * (x / c).^4);

    % Camber line (aft-loaded mean camber line for 6-series)
    y_c = zeros(size(x));
    dyc_dx = zeros(size(x));
    for i = 1:length(x)
        if x(i) <= p * c
            y_c(i) = (m / p^2) * (2 * p * (x(i) / c) - (x(i) / c)^2);
            dyc_dx(i) = (2 * m / p^2) * (p - x(i) / c);
        else
            y_c(i) = (m / (1 - p)^2) * ((1 - 2 * p) + 2 * p * (x(i) / c) - (x(i) / c)^2);
            dyc_dx(i) = (2 * m / (1 - p)^2) * (p - x(i) / c);
        end
    end

    % Angle of camber slope (theta)
    theta = atan(dyc_dx);

    % Upper and lower surface coordinates
    y_u = y_c + y_t .* cos(theta); % Upper surface
    y_l = y_c - y_t .* cos(theta); % Lower surface

    % Compute the maximum thickness height
    h_max = max(y_u - y_l); % Maximum thickness

    % Store results in a struct
    airfoil = struct( ...
        'type', 'NACA 6-Series', ...
        'm', m, ...
        'p', p, ...
        't', t, ...
        'c', c, ...
        'num_points', num_points, ...
        'x', x, ...
        'y_upper', y_u, ...
        'y_lower', y_l, ...
        'h_max', h_max ...
    );

    % Plot the airfoil if requested
    if show_graph
        figure;
        plot(x, y_u, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Upper Surface');
        hold on;
        plot(x, y_l, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Lower Surface');
        xlabel('Chordwise position (x)');
        ylabel('Thickness (y)');
        title('NACA 6-Series Airfoil');
        legend show;
        grid on;
        axis equal;
    end
end
