function plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular, plottitle, plotfilename,avion,datosEstructural)
% plot_stringer_regular_surfaces: Verifies and visualizes stringer surfaces (regular zones).
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   quad_surfaces_regular: Table with columns:
%       - local_id: Unique surface identifier
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface
%       - stringer_1, stringer_2: Stringers defining the surface
%       - rib_1, rib_2: Ribs defining the surface
%       - tags: Surface type (e.g., 'quad_regular')
%       - area: Area of the surface
%       - aspect_ratio: Aspect ratio of the surface
%   plottitle: Custom title for the plot (string)
%   plotfilename: Path to save the resulting plot (optional)
    % Extraer parámetros
    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha.radian;
    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    % Coordenadas
    x_local_ala = avion.coordenadas.x_local_ala;
    y = avion.coordenadas.y;
    x = avion.coordenadas.y;

    %% 🎯 Initialization
    fig = figure('Name', 'Stringer Regular Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none'); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');

% fig = figure;
% ax1 = findall(fig, 'Type', 'axes');% Esta parte es para llevar los datos en el siguiente figure
% 
% % % Está parte es para dibujar el cajón de torsión en el fuselaje que está
% % parte del ala
% hold on
% plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k');
% plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k');
% plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k');
% plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k');
% 
% % La línea de los bordes de ataque
% plot(x_local_ala,linspace(0,y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas),'k');
% % La línea de los bordes de salida
% plot(x_local_ala,linspace(c1,y_global_punta_ala_borde_ataque + c2,numero_de_puntos_en_las_lineas),'k');

%NOTA----------------------------------------------------------------
% en este código en los borde de salida sólo conecté el borde de salida en
% el encastre x el borde de salida en la sección final haciendo borde de
% ataque en la sección final = b*cos(flecha) -> borde de ataque +
% c2---------------------------------------------------------------------

% La línea de la cuerda final/en la punta
% plot(b/2*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque,y_global_punta_ala_borde_ataque+c2,numero_de_puntos_en_las_lineas),'k');

% La línea del larguero anterior
linea_larguero_anterior=linspace(c1*Distancia_larguero_anterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);
% cajon_plot_1=plot(x_local_ala,linea_larguero_anterior,'r','LineWidth',3);

% La línea del larguero posterior
linea_larguero_posterior=linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_posterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);
% cajon_plot_2=plot(x_local_ala,linea_larguero_posterior,'r','LineWidth',3);

% Cerrando un cajón entre los largueros en el ala (líneas verticales)
% cajon_plot_3=plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3);
% cajon_plot_4=plot((Lf+Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3);


% La línea de los centros aerodinámicos
linea_centro_aerodinamico=linspace(c1*distancia_centro_aerodinamico,c1*distancia_centro_aerodinamico+Lw*sin(flecha_radianes),numero_de_puntos_en_las_lineas);
% f1=plot(x_local_ala,linea_centro_aerodinamico,'c','LineWidth',1);
% coord_centro_aerodinamico = [x; linea_centro_aerodinamico]';

% % La línea del eje de referencia estructural

linea_eje_estructural=linspace(c1*distancia_eje_de_referencia_estructural_cuerda,c2*distancia_eje_de_referencia_estructural_cuerda+y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas);
% Flag graph

        % Cajón fuselaje
        plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala', 'LineWidth', 0.1);
        plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
        plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
        plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);

        % La línea de los bordes de ataque
        plot(x_local_ala,linspace(0,y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
        % La línea de los bordes de salida
        plot(x_local_ala,linspace(c1,y_global_punta_ala_borde_ataque + c2,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
        
        % La línea de la cuerda final/en la punta
        plot(b/2*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque,y_global_punta_ala_borde_ataque+c2,numero_de_puntos_en_las_lineas),'k', 'LineWidth', 0.1);

        % legend([f1 f2],{'Linea de los Centros Aerodinámico','Eje estructural'},'Location','best')
        
        % Cajón de torsión
        plot(x_local_ala,linea_larguero_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion', 'LineWidth', 0.1);
        plot(x_local_ala,linea_larguero_posterior,'r','LineWidth',3, 'HandleVisibility', 'off', 'LineWidth', 0.1);
        plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');
        plot((Lf+Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');

        plot(x_local_ala,linea_centro_aerodinamico,'c','LineWidth',1, 'DisplayName', 'La línea de los centros aerodinámicos', 'LineWidth', 0.1);
        plot(x_local_ala,linea_eje_estructural,'g', 'DisplayName', 'El eje de referencia estructural', 'LineWidth', 0.1);
        
    
    
    %% 🟢 Plot Combined Nodes with Color Codes for Spars

    % Assuming 'combined_nodes' has a column 'type' with values 'front' or 'rear'
    % Example: combined_nodes.type = {'front', 'rear', 'front', ...};
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars'); % Logical index for front spar nodes
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');  % Logical index for rear spar nodes
    stringers_idx = strcmp(combined_nodes.tag, 'stringers');  % Logical index for rear spar nodes

    % Plot Front Spar Nodes in Red
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
    
    % Plot Rear Spar Nodes in Blue
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
    
    % Plot stringers Nodes in black
    plot(combined_nodes.x(stringers_idx), combined_nodes.y(stringers_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'stringers');


    % Add Node Labels (Optional for Debugging)
    for i = 1:height(combined_nodes)
        text(combined_nodes.x(i), combined_nodes.y(i), sprintf('%d', combined_nodes.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% 🟦 Plot Regular Quadrilateral Surfaces
    if ~isempty(quad_surfaces_regular)
        for i = 1:height(quad_surfaces_regular)
            % Extract node coordinates by matching local_id
            surface_nodes = combined_nodes(ismember(combined_nodes.local_id, ...
                [quad_surfaces_regular.node_1(i), ...
                 quad_surfaces_regular.node_2(i), ...
                 quad_surfaces_regular.node_3(i), ...
                 quad_surfaces_regular.node_4(i)]), {'local_id', 'x', 'y'});

            % Ensure nodes are ordered top-left, counterclockwise
            ordered_coords = [
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_1(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_1(i)); % Top-left (node_1)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_2(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_2(i)); % Lower-left (node_2)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_3(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_3(i)); % Lower-right (node_3)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_4(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_4(i))  % Top-right (node_4)
            ];

            % Plot quadrilateral surface
            fill(ordered_coords(:, 1), ordered_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'b', 'LineWidth', 1.2);
            
            % Optional: Add metadata as text annotations
            center_x = mean(ordered_coords(:, 1));
            center_y = mean(ordered_coords(:, 2));
            annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
                quad_surfaces_regular.area(i), ...
                quad_surfaces_regular.aspect_ratio(i));
            text(center_x, center_y, annotation_text, 'FontSize', 8, ...
                 'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
        end
    else
        warning('No regular stringer surfaces available to plot.');
    end

    %% 📌 Legend and Styling
    legend({'Combined Nodes', 'Regular Quadrilateral Surfaces'}, 'Location', 'best');
    hold off;
    
    %% 💾 Save Plot
    if exist('plotfilename', 'var') && ~isempty(plotfilename)
        [fileDir, fileName, ~] = fileparts(plotfilename);
        if ~exist(fileDir, 'dir')
            mkdir(fileDir);
        end
        saveas(fig, fullfile(fileDir, sprintf('%s.png', fileName)));
        savefig(fig, fullfile(fileDir, sprintf('%s.fig', fileName)));
    end
    
    disp('✅ Stringer regular surfaces plot completed and saved successfully.');
end
