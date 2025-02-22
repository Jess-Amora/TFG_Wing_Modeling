function plot_stringer_irregular_surfaces_v3(combined_nodes, inserted_table, quad_surfaces_irregular, tri_surfaces, plottitle, plotfilename, avion, datosEstructural)
% plot_stringer_irregular_surfaces: Visualizes stringer surfaces (irregular zones).
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   inserted_table: Table with additional nodes (for inserted points).
%   quad_surfaces_irregular: Table with irregular surface properties and metadata.
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%   avion, datosEstructural: Structs for geometric and structural data (used for plot styling).
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
    %% 🎯 Initialize Plot
    fig = figure('Name', 'Stringer Irregular Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none');
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
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars'); % Front spar nodes
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');   % Rear spar nodes
    stringers_idx = strcmp(combined_nodes.tag, 'stringer');     % Stringer nodes

    % Plot Front Spar Nodes in Red
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');

    % Plot Rear Spar Nodes in Blue
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');

    % Plot Stringer Nodes in Black
    plot(combined_nodes.x(stringers_idx), combined_nodes.y(stringers_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:height(combined_nodes)
        text(combined_nodes.x(i), combined_nodes.y(i), sprintf('%d', combined_nodes.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end

    %% 🔵 Plot Quadrilateral Surfaces for Different Tags
    if ~isempty(quad_surfaces_irregular)
        % legend_quad_plotted = false; % Flag to track legend entry for quad surfaces
        for i = 1:height(quad_surfaces_irregular)
            % Determine nodes based on the surface tag
            surface_tag = quad_surfaces_irregular.tags(i);

            if strcmp(surface_tag, "quad irregular P1 inserted")
                % P1 from inserted_table, other nodes from combined_nodes
                node_1 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.stringer_index == quad_surfaces_irregular.stringer_2(i) & combined_nodes.rib_index ==-2, :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i) & strcmp(combined_nodes.tag, 'stringer'), :);

            elseif strcmp(surface_tag, "quad irregular P4 inserted")
                % P4 from inserted_table, other nodes from combined_nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_3 = combined_nodes(combined_nodes.stringer_index == quad_surfaces_irregular.stringer_2(i) & combined_nodes.rib_index ==-2 & strcmp(combined_nodes.tag, 'stringer'), :);
                node_4 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_4(i), :);

            elseif strcmp(surface_tag, "quad irregular")
                % P2 and P3 from front spar nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i) & strcmp(combined_nodes.tag, 'stringer'), :);
            elseif strcmp(surface_tag, "quad regular")
                % P2 and P3 from front spar nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i) & strcmp(combined_nodes.tag, 'stringer'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i) & strcmp(combined_nodes.tag, 'stringer'), :);

            else
                % Unknown tag, skip this surface
                warning('Unknown surface tag: %s. Skipping surface %d.', surface_tag, i);
                continue;
            end

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the quadrilateral surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];

            % Plot the quadrilateral surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'magenta', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
            
            % if ~legend_quad_plotted
            %     fill(NaN, NaN, 'magenta', 'FaceAlpha', 0.3, ...
            %      'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
            %     legend_quad_plotted = true;
            % end

            % Optional: Add metadata as text annotations
            center_x = mean(surface_coords(:, 1));
            center_y = mean(surface_coords(:, 2));
            % annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
            %     quad_surfaces_irregular.area(i), ...
            %     quad_surfaces_irregular.aspect_ratio(i));
            % text(center_x, center_y, annotation_text, 'FontSize', 8, ...
            %      'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
        end
    else
        warning('No irregular stringer surfaces available to plot.');
    end
    
    %% 🔺 Plot Triangular Surfaces
    if ~isempty(tri_surfaces)
        for i = 1:height(tri_surfaces)
            % Extract nodes for the triangular surface
            node_1 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_3(i)  & strcmp(combined_nodes.tag, 'front spars'), :);

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warning('Skipping triangular surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the triangular surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];

            % Plot the triangular surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');

            % Optional: Add metadata as text annotations
            center_x = mean(surface_coords(:, 1));
            center_y = mean(surface_coords(:, 2));
            % annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
            %     tri_surfaces.area(i), ...
            %     tri_surfaces.aspect_ratio(i));
            % text(center_x, center_y, annotation_text, 'FontSize', 8, ...
            %      'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
        end
    else
        warning('No triangular stringer surfaces available to plot.');
    end
    %% 📌 Legend and Final Styling
    legend('Location', 'best');
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

    disp('✅ Stringer irregular surfaces plot completed and saved successfully.');
end
