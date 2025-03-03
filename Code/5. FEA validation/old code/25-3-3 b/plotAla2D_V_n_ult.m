function plotAla2D_V_n_ult(avion, ax, closeflag)
    % Default closeflag to false if not provided
    if nargin < 3
        closeflag = false;
    end

    % Create a new figure if no axis is provided (standalone mode)
    if nargin < 2 || isempty(ax)
        fig1 = figure('Name', 'Fuerzas V N Ult', 'NumberTitle', 'off');
        ax = gca;
    else
        fig1 = ancestor(ax, 'figure'); % Get the parent figure of the axis
    end

    hold(ax, 'on');
    grid(ax, 'on');

    % 🛠️ Extract Data
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;
    y_punta_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    datosEstructural = avion.datosEstructural;
    Dist_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    dist_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    dist_eje_estructural = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    n_points = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    % 🧮 Plot Structural Geometry
    plot(ax, linspace(0, Lf, n_points), zeros(1, n_points), 'k--', 'DisplayName', 'Fuselaje');
    plot(ax, linspace(0, Lf, n_points), c1 * ones(1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, Lf * ones(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, x_local_ala, linspace(0, y_punta_borde_ataque, n_points), 'k--', 'HandleVisibility', 'off');

    % 🟥 Torsion Box Visualization
    larguero_anterior = linspace(c1 * Dist_larguero_anterior, ...
                                 y_punta_borde_ataque + Dist_larguero_anterior * c2, ...
                                 n_points);

    larguero_posterior = linspace(c1 * Dist_larguero_posterior, ...
                                  y_punta_borde_ataque + Dist_larguero_posterior * c2, ...
                                  n_points);

    plot(ax, x_local_ala, larguero_anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    plot(ax, x_local_ala, larguero_posterior, 'r', 'LineWidth', 2, 'HandleVisibility', 'off');

    % 💨 Aerodynamic Center and Structural Axis
    centro_aerodinamico = linspace(c1 * dist_centro_aerodinamico, ...
                                   c1 * dist_centro_aerodinamico + Lw * sin(flecha_radianes), ...
                                   n_points);

    eje_estructural = linspace(c1 * dist_eje_estructural, ...
                               c2 * dist_eje_estructural + y_punta_borde_ataque, ...
                               n_points);

    plot(ax, x_local_ala, centro_aerodinamico, 'c', 'LineWidth', 1, 'DisplayName', 'Centro Aerodinámico');
    plot(ax, x_local_ala, eje_estructural, 'g', 'DisplayName', 'Eje Estructural');

    % 📈 Shear Forces Visualization (3D Plot)
    ala = avion.ala;
    anterior = squeeze(ala.costillas(:, :, end));  % Anterior spar intersections
    posterior = squeeze(ala.costillas(:, :, 1));   % Posterior spar intersections

    V_rear = avion.forces_n_ult.V.rear;
    V_front = avion.forces_n_ult.V.front;

    % Enhanced Visualization with Colors and Markers
    stem3(ax, anterior(2:end-1, 1), anterior(2:end-1, 2), V_front, ...
          'filled', 'DisplayName', 'Fuerzas V Front Spar', 'MarkerFaceColor', 'b');
    stem3(ax, posterior(2:end-1, 1), posterior(2:end-1, 2), V_rear, ...
          'filled', 'DisplayName', 'Fuerzas V Rear Spar', 'MarkerFaceColor', 'm');

    view(ax, 3);
    xlabel(ax, 'X (Envergadura)');
    ylabel(ax, 'Y (Cuerda)');
    zlabel(ax, 'Magnitud de la Fuerza V');
    title(ax, 'Distribución de Fuerzas Cortantes V en el Ala (N Ult)');
    legend(ax, 'Location', 'southeast');

    % 🧷 Save Figure
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.png'));
        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.png')]);
    end

    % ❌ Close the figure if required
    if closeflag
        close(fig1);
    end
end
