function figure_plot = plotAla2D_weight_wing_n_ult(avion, ax, closeflag)
    % Default to not close the figure
    if nargin < 3
        closeflag = false;
    end

    % Create a new figure if no axis is provided (for standalone mode)
    if nargin < 2 || isempty(ax)
        fig1 = figure('Name', 'Weight Wing N Ult', 'NumberTitle', 'off');
        ax = gca;
    else
        fig1 = ancestor(ax, 'figure'); % Get the parent figure of the axis
    end

    hold(ax, 'on');
    grid(ax, 'on');

    % Data extraction
    Lf = avion.geometria.Lf;
    c1 = avion.geometria.c1;
    b = avion.geometria.b;
    x_local_ala = avion.coordenadas.x_local_ala;
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;

    numero_de_puntos_en_las_lineas = avion.datosEstructural.numero_de_puntos_en_las_lineas;

    % Plotting structural outline
    plot(ax, linspace(0, Lf, numero_de_puntos_en_las_lineas), zeros(1, numero_de_puntos_en_las_lineas), 'k--', 'DisplayName', 'Traza del ala');
    plot(ax, x_local_ala, linspace(0, y_global_punta_ala_borde_ataque, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');

    % Mass Wing Forces
    ala = avion.ala;
    anterior = squeeze(ala.costillas(:, :, end));  % Anterior spar intersections
    posterior = squeeze(ala.costillas(:, :, 1));   % Posterior spar intersections
    V_mass_wing = avion.weight_n_ult.V_mass_wing;

    % 3D Forces Plot
    stem3(ax, anterior(:,1), anterior(:,2), V_mass_wing.front, 'filled', 'DisplayName', 'Front Spar Forces');
    stem3(ax, posterior(:,1), posterior(:,2), V_mass_wing.rear, 'filled', 'DisplayName', 'Rear Spar Forces');
    view(ax, 3);

    % Axis Labels and Title
    xlabel(ax, 'X (Spanwise)');
    ylabel(ax, 'Y (Chordwise)');
    zlabel(ax, 'Force Magnitude');
    title(ax, 'Discrete Forces on the Wing');
    legend(ax, 'Location', 'southeast');

    % Save the figure if the directory exists
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig1, fullfile(avion.folder.figures, 'Plot_weight_wing_n_ult.png'));
        saveas(fig1, fullfile(avion.folder.figures, 'Plot_weight_wing_n_ult.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Plot_weight_wing_n_ult.png')]);
    end

    % Return figure handle
    figure_plot = fig1;

    % Close the figure if closeflag is true
    if closeflag
        close(fig1);
    end
end
