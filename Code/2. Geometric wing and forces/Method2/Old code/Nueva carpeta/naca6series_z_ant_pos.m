function airfoil = naca6series_z_ant_pos(m, p, t, c, num_points,datosEstructural, show_graph)
% Computes a NACA 6-series airfoil and returns the data as a struct, including
% thickness at the front and rear spar positions (z_anterior, z_posterior).
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
%   - airfoil: Struct containing:
%       .type
%       .m, .p, .t, .c
%       .num_points
%       .x          - array of x-coordinates along the chord
%       .y_upper    - array of upper surface y-values
%       .y_lower    - array of lower surface y-values
%       .h_max      - maximum thickness across the chord
%       .z_anterior - thickness at the front spar (default 15% chord)
%       .z_posterior- thickness at the rear spar (default 65% chord)
%
% Example:
%   airfoil = naca6series(0.02, 0.4, 0.12, 1.0, 100, true);

    % Default chordwise fractions for front/rear spar:
    front_spar_fraction = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    rear_spar_fraction  = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;

    % 1) x-coordinates along the chord (linear spacing)
    x = linspace(0, c, num_points);

    % 2) Thickness distribution (NACA 6-series)
    y_t = 5 * t * c .* ( ...
          0.2969*sqrt(x/c) - 0.1260*(x/c) ...
        - 0.3516*(x/c).^2 + 0.2843*(x/c).^3 ...
        - 0.1015*(x/c).^4 );

    % 3) Compute camber line (y_c) & slope (dyc_dx)
    y_c = zeros(size(x));
    dyc_dx = zeros(size(x));
    for i = 1:length(x)
        if x(i) <= p*c
            y_c(i) = (m / p^2) * (2*p*(x(i)/c) - (x(i)/c)^2);
            dyc_dx(i) = (2*m / p^2) * (p - x(i)/c);
        else
            y_c(i) = (m / (1 - p)^2) * ((1 - 2*p) + 2*p*(x(i)/c) - (x(i)/c)^2);
            dyc_dx(i) = (2*m / (1 - p)^2) * (p - x(i)/c);
        end
    end

    % 4) Angle of camber slope (theta)
    theta = atan(dyc_dx);

    % 5) Upper & lower surface coordinates
    y_u = y_c + y_t .* cos(theta);
    y_l = y_c - y_t .* cos(theta);

    % 6) Maximum thickness
    h_max = max(y_u - y_l);

    % 7) Interpolate thickness at front_spar_fraction & rear_spar_fraction
    %    (Use interp1 so you get exact thickness at x_fs & x_rs.)
    x_fs = front_spar_fraction * c;  % front spar location
    x_rs = rear_spar_fraction  * c;  % rear spar location

    y_u_fs = interp1(x, y_u, x_fs, 'linear', 'extrap');
    y_l_fs = interp1(x, y_l, x_fs, 'linear', 'extrap');
    z_anterior = y_u_fs - y_l_fs;

    y_u_rs = interp1(x, y_u, x_rs, 'linear', 'extrap');
    y_l_rs = interp1(x, y_l, x_rs, 'linear', 'extrap');
    z_posterior = y_u_rs - y_l_rs;

    % 8) Store results in a struct
    airfoil = struct( ...
        'type',         'NACA 6-Series', ...
        'm',            m, ...
        'p',            p, ...
        't',            t, ...
        'c',            c, ...
        'num_points',   num_points, ...
        'x',            x, ...
        'y_upper',      y_u, ...
        'y_lower',      y_l, ...
        'h_max',        h_max, ...
        'z_anterior',   z_anterior, ...
        'z_posterior',  z_posterior ...
    );

    % 9) (Optional) Plot the airfoil if requested
    if show_graph
        figure;
        plot(x, y_u, 'b-', 'LineWidth',1.5, 'DisplayName','Upper Surface');
        hold on;
        plot(x, y_l, 'r-', 'LineWidth',1.5, 'DisplayName','Lower Surface');

        % Mark the front and rear spar points
        plot(x_fs, y_u_fs, 'ko','MarkerFaceColor','k','DisplayName','Front Spar (upper)');
        plot(x_fs, y_l_fs, 'ko','MarkerFaceColor','g','DisplayName','Front Spar (lower)');
        plot(x_rs, y_u_rs, 'ks','MarkerFaceColor','k','DisplayName','Rear Spar (upper)');
        plot(x_rs, y_l_rs, 'ks','MarkerFaceColor','g','DisplayName','Rear Spar (lower)');

        xlabel('Chordwise position (x)');
        ylabel('Thickness (y)');
        title('NACA 6-Series Airfoil');
        legend('Location','best');
        grid on;
        axis equal;
    end
end
