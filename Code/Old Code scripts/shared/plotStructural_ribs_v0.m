
function plotStructural_ribs_v0(avion, geom_struct, ribs_struct)
    % plotStructural_ribs: Plots the wing with structural ribs.
    % 
    % Inputs:
    %   - avion: Structure containing aircraft data.
    %   - geom_struct: Structure containing geometric parameters.
    %   - costillas: Rib coordinates from generateCostillas_v0.
    %   - costilla_medios: Midpoints between ribs.
    %   - costilla_costilla_medio: Alternating endpoints and midpoints.

    datosEstructural = avion.datosEstructural;

    % Extract geometry
    Lf = geom_struct.Lf;
    Lw = geom_struct.Lw;
    c1 = geom_struct.c1;
    c2 = geom_struct.c2;
    b = avion.geometria.b;
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    costillas = ribs_struct.costillas;
    costilla_medios = ribs_struct.costilla_medios;
    costilla_costilla_medio = ribs_struct.costilla_costilla_medio;
    
    % Structural data
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;

    x_local_ala = geom_struct.x_local_ala;

    % Initialize figure
    figure;
    hold on;
    title('Wing Structure with Ribs');
    xlabel('Spanwise Coordinate (x)');
    ylabel('Chordwise Coordinate (y)');
    axis equal;
    grid on;

    %% Wing outline
    plot(linspace(0, Lf, numero_de_puntos_en_las_lineas), zeros(1, numero_de_puntos_en_las_lineas), 'k--', 'DisplayName', 'Wing Root');
    plot(linspace(0, Lf, numero_de_puntos_en_las_lineas), c1 * ones(1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(Lf * ones(1, numero_de_puntos_en_las_lineas), linspace(0, c1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(zeros(1, numero_de_puntos_en_las_lineas), linspace(0, c1, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');

    % Leading & trailing edges
    plot(x_local_ala, linspace(0, y_global_punta_ala_borde_ataque, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');
    plot(x_local_ala, linspace(c1, y_global_punta_ala_borde_ataque + c2, numero_de_puntos_en_las_lineas), 'k--', 'HandleVisibility', 'off');

    % Tip chord
    plot(b / 2 * ones(1, numero_de_puntos_en_las_lineas), linspace(y_global_punta_ala_borde_ataque, y_global_punta_ala_borde_ataque + c2, numero_de_puntos_en_las_lineas), 'k');

    %% Torsion Box
    plot(x_local_ala, geom_struct.linea_larg_anterior, 'r', 'LineWidth', 3, 'DisplayName', 'Torsion Box');
    plot(x_local_ala, geom_struct.linea_larg_posterior, 'r', 'LineWidth', 3, 'HandleVisibility', 'off');
    plot(Lf * ones(1, numero_de_puntos_en_las_lineas), linspace(Distancia_larguero_anterior_cuerda_porcentaje * c1, c1 * Distancia_larguero_posterior_cuerda_porcentaje, numero_de_puntos_en_las_lineas), 'r', 'LineWidth', 3, 'HandleVisibility', 'off');
    plot((Lf + Lw) * ones(1, numero_de_puntos_en_las_lineas), linspace(y_global_punta_ala_borde_ataque + Distancia_larguero_anterior_cuerda_porcentaje * c2, y_global_punta_ala_borde_ataque + c2 * Distancia_larguero_posterior_cuerda_porcentaje, numero_de_puntos_en_las_lineas), 'r', 'LineWidth', 3, 'HandleVisibility', 'off');

    %% Structural Reference Lines
    plot(x_local_ala, geom_struct.linea_centro, 'c--', 'LineWidth', 1, 'DisplayName', 'Aerodynamic Center');
    plot(x_local_ala, geom_struct.linea_eje, 'g--', 'LineWidth', 1, 'DisplayName', 'Structural Axis');

    %% Plot ribs (costillas)
    num_costillas = size(costillas, 1);
    for i = 1:num_costillas
        if i == 1
            plot(squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'DisplayName', 'Ribs');
        else
            plot(squeeze(costillas(i, 1, :)), squeeze(costillas(i, 2, :)), 'k', 'HandleVisibility', 'off');
        end
    end

    %% Midpoint connections
    num_costilla_medios = size(costilla_medios, 1);
    for i = 1:num_costilla_medios
        plot(costilla_medios(i, 1), costilla_medios(i, 2), 'bo', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
    end

    %% Midpoint-endpoint connections
    num_costilla_costilla_medio = size(costilla_costilla_medio, 1);
    for i = 1:num_costilla_costilla_medio
        plot([costilla_costilla_medio(i, 1), costilla_costilla_medio(i, 3)], [costilla_costilla_medio(i, 2), costilla_costilla_medio(i, 4)], 'b-', 'HandleVisibility', 'off');
    end

    %% Legend & Save
    legend('Location', 'best');
    hold off;

    % Save to Figures folder
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(gcf, fullfile(avion.folder.figures, 'Step_2_ribs_structure.png'));
        saveas(gcf, fullfile(avion.folder.figures, 'Step_2_ribs_structure.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Step_2_ribs_structure.png')]);
    end

    % Close figure
    close(gcf);
end
