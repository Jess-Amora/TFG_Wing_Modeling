function plotAla2Dlarguerillo(avion)
    % plotAla2Dlarguerillo: Generates a 2D plot of the wing with stringers (larguerillos).
    %
    % Parameters:
    %   - avion: Structure containing wing and fuselage data

    %% 📦 **Extract Parameters**
    datosEstructural = avion.datosEstructural;
    geom = avion.geometria;
    ala = avion.ala;

    % Geometría del ala y fuselaje
    Lf = geom.Lf;
    Lw = geom.Lw;
    c1 = geom.c1;
    c2 = geom.c2;
    b = geom.b;

    y_borde_ataque_punta = geom.y_global_punta_ala_borde_ataque;
    flecha_radianes = geom.flecha_radian;

    % Datos estructurales
    dist_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    dist_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    dist_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    dist_eje_estructural = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    n_puntos = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    %% 🎨 **Set Up Plot**
    fig = figure('Name', 'Ala con Larguerillos', 'NumberTitle', 'off');
    hold on;
    grid on;
    axis equal;

    %% 🚀 **Plot Fuselaje**
    plotFuselaje(Lf, c1, n_puntos);

    %% 🟥 **Plot Torsion Box**
    plotTorsionBox(x_local_ala, c1, c2, y_borde_ataque_punta, ...
                   dist_larguero_anterior, dist_larguero_posterior, ...
                   Lf, Lw, n_puntos);

    %% 💨 **Plot Stringers (Larguerillos)**
    plotLarguerillos(ala.larguerillos);

    %% 📑 **Legend and Labels**
    xlabel('Envergadura [m]');
    ylabel('Cuerda [m]');
    title('Visualización del Ala 2D con Larguerillos');
    legend('Location', 'southeast');

    hold off;

    %% 💾 **Save Plot**
    savePlot(fig, avion, 'Plot_larguerillos');

    %% ❌ **Close the Figure**
    close(fig);
end

%% 🔲 **Helper Functions**

function plotFuselaje(Lf, c1, n_puntos)
    % Dibuja el contorno del fuselaje
    plot(linspace(0, Lf, n_puntos), zeros(1, n_puntos), 'k--', 'DisplayName', 'Traza del ala');
    plot(linspace(0, Lf, n_puntos), c1 * ones(1, n_puntos), 'k--', 'HandleVisibility', 'off');
    plot(Lf * ones(1, n_puntos), linspace(0, c1, n_puntos), 'k--', 'HandleVisibility', 'off');
    plot(zeros(1, n_puntos), linspace(0, c1, n_puntos), 'k--', 'HandleVisibility', 'off');
end

function plotTorsionBox(x_local_ala, c1, c2, y_borde_ataque_punta, ...
                        dist_larguero_anterior, dist_larguero_posterior, ...
                        Lf, Lw, n_puntos)
    % Dibuja el cajón de torsión
    anterior = linspace(c1 * dist_larguero_anterior, ...
                        y_borde_ataque_punta + dist_larguero_anterior * c2, n_puntos);
    posterior = linspace(c1 * dist_larguero_posterior, ...
                         y_borde_ataque_punta + dist_larguero_posterior * c2, n_puntos);

    plot(x_local_ala, anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    plot(x_local_ala, posterior, 'r', 'LineWidth', 2, 'HandleVisibility', 'off');
end

function plotLarguerillos(larguerillos)
    % Dibuja los larguerillos (stringers)
    for i = 1:size(larguerillos, 1)
        if i == 1
            plot(squeeze(larguerillos(i, 1, :)), squeeze(larguerillos(i, 2, :)), ...
                 'k', 'DisplayName', 'Larguerillos', 'LineWidth', 1.5);
        else
            plot(squeeze(larguerillos(i, 1, :)), squeeze(larguerillos(i, 2, :)), ...
                 'k', 'HandleVisibility', 'off', 'LineWidth', 1.5);
        end
    end
end

function savePlot(fig, avion, filename)
    % Guarda la figura en la carpeta especificada
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Carpeta creada: ', avion.folder.figures]);
        end

        saveas(fig, fullfile(avion.folder.figures, [filename, '.png']));
        saveas(fig, fullfile(avion.folder.figures, [filename, '.fig']));
        disp(['📊 Gráfico guardado en: ', fullfile(avion.folder.figures, [filename, '.png'])]);
    end
end
