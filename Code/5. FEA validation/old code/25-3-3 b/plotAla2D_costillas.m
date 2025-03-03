function plotAla2D_costillas(avion, ax, closeflag)
    % plotAla2D_costillas: Generates a 2D plot of the wing showing ribs (costillas),
    % torsion box, and structural lines.
    %
    % Parameters:
    %   avion: Struct containing airplane data
    %   ax: Optional. Axis handle for tiledlayout or subplot (default: new figure)
    %   closeflag: Optional. Close the figure after saving (default: false)

    if nargin < 3
        closeflag = false;
    end

    if nargin < 2 || isempty(ax)
        fig = figure('Name', 'Ala 2D - Costillas', 'NumberTitle', 'off');
        ax = gca;
    else
        fig = ancestor(ax, 'figure'); % Get the parent figure of the axis
    end

    hold(ax, 'on');
    grid(ax, 'on');

    %% 🎯 **Extract Data from `avion` Struct**
    datosEstructural = avion.datosEstructural;
    ala = avion.ala;

    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    y_punta_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    % Datos estructurales
    Dist_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_estructural = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    n_points = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    %% 📏 **Draw Fuselaje Outline**
    plotFuselaje(ax, Lf, c1, n_points);

    %% 🟥 **Draw Torsion Box**
    plotTorsionBox(ax, x_local_ala, c1, c2, y_punta_borde_ataque, ...
                   Dist_larguero_anterior, Dist_larguero_posterior, ...
                   Lf, Lw, n_points);

    %% 🌐 **Draw Ribs (Costillas)**
    plotStructuralElements(ax, ala.costillas, 'Costillas', 'k');

    %% 📊 **Structural Reference Lines**
    plotReferenceLines(ax, x_local_ala, c1, distancia_centro_aerodinamico, ...
                       distancia_eje_estructural, Lw, flecha_radianes, ...
                       y_punta_borde_ataque, 'c', 'g');

    %% 📈 **Customize Plot**
    xlabel(ax, 'X (Envergadura)');
    ylabel(ax, 'Y (Cuerda)');
    title(ax, 'Visualización de Costillas en el Ala');
    legend(ax, 'Location', 'southeast');

    hold(ax, 'off');

    %% 💾 **Save Plot and Data**
    savePlot(fig, avion, 'Plot_costillas');

    %% ❌ **Close Figure if Required**
    if closeflag
        close(fig);
    end
end

%% 🔲 **Helper Functions**

function plotFuselaje(ax, Lf, c1, n_points)
    % Draw the outline of the fuselage
    plot(ax, linspace(0, Lf, n_points), zeros(1, n_points), 'k--', 'DisplayName', 'Fuselaje');
    plot(ax, linspace(0, Lf, n_points), c1 * ones(1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, Lf * ones(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, zeros(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
end

function plotTorsionBox(ax, x_local_ala, c1, c2, y_punta_borde_ataque, ...
                        Dist_larguero_anterior, Dist_larguero_posterior, ...
                        Lf, Lw, n_points)
    % Draw the torsion box
    anterior = linspace(c1 * Dist_larguero_anterior, ...
                        y_punta_borde_ataque + Dist_larguero_anterior * c2, n_points);

    posterior = linspace(c1 * Dist_larguero_posterior, ...
                         y_punta_borde_ataque + Dist_larguero_posterior * c2, n_points);

    plot(ax, x_local_ala, anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    plot(ax, x_local_ala, posterior, 'r', 'LineWidth', 2, 'HandleVisibility', 'off');
end

function plotStructuralElements(ax, elements, label, color)
    % Plot ribs or other structural elements with specified label and color
    for i = 1:size(elements, 1)
        if i == 1
            plot(ax, squeeze(elements(i, 1, :)), squeeze(elements(i, 2, :)), ...
                 color, 'DisplayName', label);
        else
            plot(ax, squeeze(elements(i, 1, :)), squeeze(elements(i, 2, :)), ...
                 color, 'HandleVisibility', 'off');
        end
    end
end

function plotReferenceLines(ax, x_local_ala, c1, distancia_centro_aerodinamico, ...
                             distancia_eje_estructural, Lw, flecha_radianes, ...
                             y_punta_borde_ataque, color_ca, color_es)
    % Plot center of aerodynamic and structural reference lines
    centro_aerodinamico = linspace(c1 * distancia_centro_aerodinamico, ...
                                   c1 * distancia_centro_aerodinamico + Lw * sin(flecha_radianes), length(x_local_ala));
    eje_estructural = linspace(c1 * distancia_eje_estructural, ...
                               c2 * distancia_eje_estructural + y_punta_borde_ataque, length(x_local_ala));

    plot(ax, x_local_ala, centro_aerodinamico, color_ca, 'LineWidth', 1, 'DisplayName', 'Centro Aerodinámico');
    plot(ax, x_local_ala, eje_estructural, color_es, 'DisplayName', 'Eje Estructural');
end

function savePlot(fig, avion, filename)
    % Save the plot to the specified folder
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig, fullfile(avion.folder.figures, [filename, '.png']));
        saveas(fig, fullfile(avion.folder.figures, [filename, '.fig']));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, [filename, '.png'])]);
    end
end
