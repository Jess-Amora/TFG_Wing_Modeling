function plotAla2D_fuerzas_l(avion, ax, closeflag)
    % Default closeflag to false if not provided
    if nargin < 3
        closeflag = false;
    end

    % Create a new figure if no axis is provided (standalone mode)
    if nargin < 2 || isempty(ax)
        fig1 = figure('Name', 'Fuerzas L', 'NumberTitle', 'off');
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

    % 📈 Forces Visualization (3D Plot)
    ala = avion.ala;
    stem3(ax, ala.x_l, ala.y_l, ala.l, 'filled', 'DisplayName', 'Fuerzas L');
    view(ax, 3);

    xlabel(ax, 'X (Envergadura)');
    ylabel(ax, 'Y (Cuerda)');
    zlabel(ax, 'Magnitud de la Fuerza');
    title(ax, 'Distribución de Fuerzas L en el Ala');
    legend(ax, 'Location', 'southeast');

    % 🧷 Save Figure
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_l.png'));
        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_l.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Plot_forces_l.png')]);
    end

    % ❌ Close the figure if required
    if closeflag
        close(fig1);
    end
end
