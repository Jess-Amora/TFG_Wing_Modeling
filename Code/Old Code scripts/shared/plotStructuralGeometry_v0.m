
function plotStructuralGeometry_v0(geom, avion)
    % PLOTSTRUCTURALGEOMETRY_V0: Plots the key structural lines of the wing
    % based on computed geometry from computeStructuralGeometry_v0.
    %
    % Inputs:
    %   - geom: Structure containing all geometric parameters.
    %   - savePath: Folder path where the figure should be saved.
    %
    % Outputs:
    %   - Saves a .png file in the specified folder.

    % Initializing
    datosEstructural = avion.datosEstructural;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    x_local_ala = avion.coordenadas.x_local_ala;
    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    % Create figure
    figure;
    hold on;
    title('Structural Geometry of the Wing');
    xlabel('Spanwise Coordinate (x)');
    ylabel('Chordwise Coordinate (y)');
    axis equal;
    grid on;

    % Plot key lines
    % plot(geom.x_local_ala, geom.linea_larg_anterior, 'r', 'LineWidth', 2, 'DisplayName', 'Larguero Anterior');
    % plot(geom.x_local_ala, geom.linea_larg_posterior, 'b', 'LineWidth', 2, 'DisplayName', 'Larguero Posterior');
    plot(geom.x_local_ala, geom.linea_centro, 'c--', 'LineWidth', 1, 'DisplayName', 'Centro Aerodinámico');
    plot(geom.x_local_ala, geom.linea_eje, 'g--', 'LineWidth', 1, 'DisplayName', 'Eje Estructural');
    
    %% Cajón fuselaje
    plot(linspace(0,geom.Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala');
    plot(linspace(0,geom.Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(geom.Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');

    % La línea de los bordes de ataque
    plot(x_local_ala,linspace(0,y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    % La línea de los bordes de salida
    plot(x_local_ala,linspace(c1,y_global_punta_ala_borde_ataque + c2,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    
    % La línea de la cuerda final/en la punta
    plot(b/2* ones(1, numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque,y_global_punta_ala_borde_ataque+c2,numero_de_puntos_en_las_lineas),'k--');
    
    % Cajón de torsión
    plot(x_local_ala,geom.linea_larg_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion');
    plot(x_local_ala,geom.linea_larg_posterior,'r','LineWidth',3, 'HandleVisibility', 'off');
    plot(geom.Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');
    plot((geom.Lf+geom.Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');


    % Add legend
    legend('Location', 'best');
    hold off;

    % Save figure
    if nargin > 1 && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures); % ✅ Create folder if it does not exist
            disp(['📁 Created missing folder: ', avion.folder.figures]);
        end

        saveas(gcf, fullfile(avion.folder.figures, 'Step_1_wing_structural_geometry.png'));
        saveas(gcf, fullfile(avion.folder.figures, 'Step_1_wing_structural_geometry.fig'));
        disp(['Figure saved to: ', fullfile(avion.folder.figures, 'wing_structural_geometry.png')]);
    end

    close(gcf)
end