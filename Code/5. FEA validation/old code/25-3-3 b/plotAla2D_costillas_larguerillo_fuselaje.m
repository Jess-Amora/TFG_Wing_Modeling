function plotAla2D_costillas_larguerillo_fuselaje(avion, ax, closeflag)
    % 📈 Plot Costillas (Ribs) and Larguerillos (Stringers) in Fuselaje
    %
    % Parameters:
    %   avion: Struct with all necessary airplane data
    %   ax: Optional. Axis handle for plotting within tiledlayout or subplot
    %   closeflag: Optional. If true, the figure is closed after saving (default: false)

    if nargin < 3
        closeflag = false;
    end

    % ✅ Create a new figure if no axis is provided (standalone mode)
    if nargin < 2 || isempty(ax)
        fig = figure('Name', 'Costillas y Larguerillos en el Fuselaje', 'NumberTitle', 'off');
        ax = gca;
    else
        fig = ancestor(ax, 'figure'); % Get the parent figure of the axis
    end

    hold(ax, 'on');
    grid(ax, 'on');

    %% 🎯 **Extract Key Data**
    datosEstructural = avion.datosEstructural;
    fuselaje = avion.fuselaje;
    ala = avion.ala;

    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    y_punta_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    % Datos estructural
    Dist_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    dist_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    dist_eje_estructural = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    n_points = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    %% 📏 **Fuselaje Outline**
    plotFuselaje(ax, Lf, c1, n_points);

    %% 🟥 **Torsion Box**
    plotTorsionBox(ax, x_local_ala, c1, c2, y_punta_borde_ataque, ...
                   Dist_larguero_anterior, Dist_larguero_posterior, ...
                   Lf, Lw, n_points);

    %% 📐 **Ribs (Costillas)**
    plotRibs(ax, fuselaje);

    %% 🔩 **Stringers (Larguerillos)**
    plotStringers(ax, fuselaje, ala);

    %% 📊 **Finalize Plot**
    xlabel(ax, 'X (Envergadura)');
    ylabel(ax, 'Y (Cuerda)');
    title(ax, 'Costillas y Larguerillos en el Fuselaje');
    legend(ax, 'Location', 'southeast');

    hold(ax, 'off');

    %% 💾 **Save Plot and Data**
    savePlot(fig, avion, 'Plot_costillas_larguerillos_fuselaje');

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

function plotRibs(ax, fuselaje)
    % Plot ribs (costillas) in the fuselage
    numero_costillas = fuselaje.numero_costillas_fuselaje;
    costillas = fuselaje.costillas_fuselaje;

    for i = 1:numero_costillas
        if i == 1
            plot(ax, squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'DisplayName', 'Costillas');
        else
            plot(ax, squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'HandleVisibility', 'off');
        end
    end
end

function plotStringers(ax, fuselaje, ala)
    % Plot stringers (larguerillos) in the fuselage
    numero_larguerillo_total = ala.numero_larguerillos_total;
    larguerillos_fuselaje = fuselaje.larguerillos_fuselaje;

    for i = 1:numero_larguerillo_total
        if i == 1
            plot(ax, squeeze(larguerillos_fuselaje(i, 1, :)), squeeze(larguerillos_fuselaje(i, 2, :)), 'b', 'DisplayName', 'Larguerillos');
        else
            plot(ax, squeeze(larguerillos_fuselaje(i, 1, :)), squeeze(larguerillos_fuselaje(i, 2, :)), 'b', 'HandleVisibility', 'off');
        end
    end
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
