function plotAla2D_weight_wing_n1(avion, ax, closeflag)
    % Default the closeflag to false if not provided
    if nargin < 3
        closeflag = false;
    end

    % Create a new figure if no axis is provided (standalone mode)
    if nargin < 2 || isempty(ax)
        fig1 = figure('Name', 'Weight Wing N1', 'NumberTitle', 'off');
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
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    datosEstructural = avion.datosEstructural;
    Distancia_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_estructural = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    n_points = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    % 🧮 Plot Structural Geometry
    plot(ax, linspace(0, Lf, n_points), zeros(1, n_points), 'k--', 'DisplayName', 'Fuselaje');
    plot(ax, linspace(0, Lf, n_points), c1 * ones(1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, Lf * ones(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, x_local_ala, linspace(0, y_global_punta_ala_borde_ataque, n_points), 'k--', 'HandleVisibility', 'off');

    % 🟥 Torsion Box Visualization
    linea_larguero_anterior = linspace(c1 * Distancia_larguero_anterior, ...
                                       y_global_punta_ala_borde_ataque + Distancia_larguero_anterior * c2, ...
                                       n_points);

    linea_larguero_posterior = linspace(c1 * Distancia_larguero_posterior, ...
                                        y_global_punta_ala_borde_ataque + Distancia_larguero_posterior * c2, ...
                                        n_points);

    plot(ax, x_local_ala, linea_larguero_anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    plot(ax, x_local_ala, linea_larguero_posterior, 'r', 'LineWidth', 2, 'HandleVisibility', 'off');

    % 💨 Aerodynamic Center and Structural Axis
    linea_centro_aerodinamico = linspace(c1 * distancia_centro_aerodinamico, ...
                                         c1 * distancia_centro_aerodinamico + Lw * sin(flecha_radianes), ...
                                         n_points);

    linea_eje_estructural = linspace(c1 * distancia_eje_estructural, ...
                                     c2 * distancia_eje_estructural + y_global_punta_ala_borde_ataque, ...
                                     n_points);

    plot(ax, x_local_ala, linea_centro_aerodinamico, 'c', 'LineWidth', 1, 'DisplayName', 'Centro Aerodinámico');
    plot(ax, x_local_ala, linea_eje_estructural, 'g', 'DisplayName', 'Eje Estructural');

    % 📈 Mass Wing Forces (3D Plot)
    ala = avion.ala;
    anterior = squeeze(ala.costillas(:, :, end));  % Anterior spar intersections
    posterior = squeeze(ala.costillas(:, :, 1));   % Posterior spar intersections
    V_mass_wing = avion.weight_n1.V_mass_wing;

    stem3(ax, anterior(:, 1), anterior(:, 2), V_mass_wing.front, 'filled', 'DisplayName', 'Front Spar Forces');
    stem3(ax, posterior(:, 1), posterior(:, 2), V_mass_wing.rear, 'filled', 'DisplayName', 'Rear Spar Forces');
    view(ax, 3);

    xlabel(ax, 'X (Spanwise)');
    ylabel(ax, 'Y (Chordwise)');
    zlabel(ax, 'Force Magnitude');
    title(ax, 'Discrete Forces on the Wing (N1)');
    legend(ax, 'Location', 'southeast');

    % 🧷 Save Figure
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig1, fullfile(avion.folder.figures, 'Plot_weight_wing_n1.png'));
        saveas(fig1, fullfile(avion.folder.figures, 'Plot_weight_wing_n1.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Plot_weight_wing_n1.png')]);
    end

    % ❌ Close the figure if required
    if closeflag
        close(fig1);
    end
end
