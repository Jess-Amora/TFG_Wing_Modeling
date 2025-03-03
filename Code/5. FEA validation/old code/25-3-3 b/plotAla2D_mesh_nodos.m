function plotAla2D_mesh_nodos(avion, ax, closeflag)
    % plotAla2D_mesh_nodos: Generates a 2D plot of the wing showing
    % the mesh, nodes, torsion box, ribs, and stringers.
    %
    % Parameters:
    %   avion: Struct containing airplane data
    %   ax: Optional. Axis handle for tiledlayout or subplot (default: new figure)
    %   closeflag: Optional. Close the figure after saving (default: false)

    if nargin < 3
        closeflag = false;
    end

    if nargin < 2 || isempty(ax)
        fig = figure('Name', 'Ala 2D - Malla y Nodos', 'NumberTitle', 'off');
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

    % Datos estructurales
    Dist_larguero_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_larguero_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    n_points = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = avion.coordenadas.x_local_ala;

    %% 📏 **Draw Fuselaje Outline**
    plotFuselaje(ax, Lf, c1, n_points);

    %% 🟥 **Draw Torsion Box**
    plotTorsionBox(ax, x_local_ala, c1, c2, y_punta_borde_ataque, ...
                   Dist_larguero_anterior, Dist_larguero_posterior, ...
                   Lf, Lw, n_points);

    %% 🌐 **Draw Ribs (Costillas)**
    plotStructuralElements(ax, ala.costillas, 'Costillas', 'k--');

    %% 🧵 **Draw Stringers (Larguerillos)**
    plotStructuralElements(ax, ala.mesh.nodos_larguerillos, 'Larguerillos', 'b--');

    %% 🧮 **Draw Nodes and Number Them**
    counter_nodes = 0;
    counter_nodes = plotNodes(ax, ala.mesh.nodos_posterior', 'xr', counter_nodes, 'Nodos Posterior');
    counter_nodes = plotNodes(ax, ala.mesh.nodos_anterior', 'xg', counter_nodes, 'Nodos Anterior');
    counter_nodes = plotNodes(ax, reshape(ala.mesh.nodos_larguerillos, [], 2), ...
                              'ok', counter_nodes, 'Nodos Larguerillos');

    %% 📈 **Customize Plot**
    xlabel(ax, 'X (Envergadura)');
    ylabel(ax, 'Y (Cuerda)');
    title(ax, 'Visualización de la Malla y Nodos en el Ala');
    legend(ax, 'Location', 'southeast');

    hold(ax, 'off');

    %% 💾 **Save Plot and Data**
    savePlot(fig, avion, 'Plot_nodos');

    %% ❌ **Close Figure if Required**
    if closeflag
        close(fig);
    end
end

%% 🔲 **Helper Functions**

function plotFuselaje(ax, Lf, c1, n_points)
    plot(ax, linspace(0, Lf, n_points), zeros(1, n_points), 'k--', 'DisplayName', 'Fuselaje');
    plot(ax, linspace(0, Lf, n_points), c1 * ones(1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, Lf * ones(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
    plot(ax, zeros(1, n_points), linspace(0, c1, n_points), 'k--', 'HandleVisibility', 'off');
end

function plotTorsionBox(ax, x_local_ala, c1, c2, y_punta_borde_ataque, ...
                        Dist_larguero_anterior, Dist_larguero_posterior, ...
                        Lf, Lw, n_points)
    anterior = linspace(c1 * Dist_larguero_anterior, ...
                        y_punta_borde_ataque + Dist_larguero_anterior * c2, n_points);
    posterior = linspace(c1 * Dist_larguero_posterior, ...
                         y_punta_borde_ataque + Dist_larguero_posterior * c2, n_points);

    plot(ax, x_local_ala, anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    plot(ax, x_local_ala, posterior, 'r', 'LineWidth', 2, 'HandleVisibility', 'off');
end

function plotStructuralElements(ax, elements, label, style)
    for i = 1:size(elements, 1)
        if i == 1
            plot(ax, squeeze(elements(i, 1, :)), squeeze(elements(i, 2, :)), ...
                 style, 'DisplayName', label, 'LineWidth', 0.1);
        else
            plot(ax, squeeze(elements(i, 1, :)), squeeze(elements(i, 2, :)), ...
                 style, 'HandleVisibility', 'off', 'LineWidth', 0.1);
        end
    end
end

function counter_nodes = plotNodes(ax, nodes, marker, counter_nodes, label)
    for i = 1:size(nodes, 1)
        plot(ax, nodes(i, 1), nodes(i, 2), marker, ...
             'HandleVisibility', i == 1, 'DisplayName', label, 'LineWidth', 0.1);
        counter_nodes = counter_nodes + 1;
        text(nodes(i, 1), nodes(i, 2), sprintf('n %d', counter_nodes), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
end

function savePlot(fig, avion, filename)
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
