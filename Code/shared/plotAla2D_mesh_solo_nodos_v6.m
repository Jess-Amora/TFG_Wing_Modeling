function plotAla2D_mesh_solo_nodos_v6(avion, datosEstructural, ala, plotTitle, xAxisLabel, yAxisLabel, savePath)
    % plotAla2D: Genera la gráfica del ala en coordenadas globales.
    % Parámetros de entrada:
    %   - wingParams: Estructura con los siguientes campos:
    %       * Lf: Longitud del fuselaje en la unión del ala
    %       * c1: Cuerda en el encastre
    %       * c2: Cuerda en la punta
    %       * x_local_ala: Coordenadas locales de la envergadura
    %       * y_global_punta_ala_borde_ataque: Coordenada Y del borde de ataque en la punta
    %       * Distancia_larguero_anterior_cuerda_porcentaje: Porcentaje de la cuerda para el larguero anterior
    %       * Distancia_larguero_posterior_cuerda_porcentaje: Porcentaje de la cuerda para el larguero posterior
    %       * numero_de_puntos_en_las_lineas: Resolución de las líneas
    %       * distancia_centro_aerodinamico: Posición del centro aerodinámico
    %       * distancia_eje_de_referencia_estructural_cuerda: Posición del eje estructural
    %       * flecha_radianes: Ángulo de flecha en radianes
    %       * Lw: Longitud del ala (semienvergadura)

    % Extraer parámetros
    % Geometría
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    b = avion.geometria.b;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;
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

        fig = figure();
        ax1 = findall(fig, 'Type', 'axes');% Esta parte es para llevar los datos en el siguiente figure
        hold on
        for k = 1:length(ax1)
            % Copy each axis and its children to figure(3)
            new_ax = copyobj(ax1(k), fig);
            % Adjust position if needed to fit the layout in fig3
            set(new_ax, 'Position', get(ax1(k), 'Position'));
        end

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
        
        % Ala Costillas
        numero_costillas = ala.numero_costillas;
        costillas = ala.costillas;

        for i=1:numero_costillas
            if i == 1
                plot(squeeze(costillas(i,1,:)),squeeze(costillas(i,2,:)),'k--', 'DisplayName', 'Costillas', 'LineWidth', 0.1);
            else
                plot(squeeze(costillas(i,1,:)),squeeze(costillas(i,2,:)),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
            end
        end

        %Ala larguerillo
        numero_larguerillo_total = ala.numero_larguerillos_total;
        larguerillos = ala.larguerillos;

        for i=1:numero_larguerillo_total
            if i == 1
                plot(squeeze(larguerillos(i,1,:)),squeeze(larguerillos(i,2,:)),'k--', 'DisplayName', 'larguerillos', 'LineWidth', 0.1);
            else
                plot(squeeze(larguerillos(i,1,:)),squeeze(larguerillos(i,2,:)),'k--', 'HandleVisibility', 'off', 'LineWidth', 0.1);
            end
        end
        
        % Nodo posterior
        nodos_posterior = ala.mesh.nodos_posterior';
        % size(nodos_posterior)
        counter_nodes = 0;
        for i=1:size(nodos_posterior,1)
            if i == 1
                plot(nodos_posterior(i,1),nodos_posterior(i,2),'xr', 'DisplayName', 'Nodos Larguerillos', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodos_posterior(i,1),nodos_posterior(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 8);
            else
                plot(nodos_posterior(i,1),nodos_posterior(i,2),'xk', 'HandleVisibility', 'off', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodos_posterior(i,1),nodos_posterior(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 8);

            end
        end
        % counter_nodes

        % Nodo anterior
        nodos_anterior = ala.mesh.nodos_anterior';
        % size(nodos_anterior)
        for i=1:size(nodos_anterior,1)
            if i == 1
                plot(nodos_anterior(i,1),nodos_anterior(i,2),'xg', 'DisplayName', 'Nodos Larguerillos', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodos_anterior(i,1),nodos_anterior(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 8);
            else
                plot(nodos_anterior(i,1),nodos_anterior(i,2),'xk', 'HandleVisibility', 'off', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodos_anterior(i,1),nodos_anterior(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 8);

            end
        end

        % Nodos en los larguerillos
        % size(ala.mesh.nodos_larguerillos)
        nodes = squeeze(ala.mesh.nodos_larguerillos);
        % size(nodes)
        % counter_nodes
        for i=1:size(nodes,1)
            if i == 1
                plot(nodes(i,1),nodes(i,2),'ok', 'DisplayName', 'Nodos Larguerillos', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodes(i,1),nodes(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 10);
            else
                plot(nodes(i,1),nodes(i,2),'ok', 'HandleVisibility', 'off', 'LineWidth', 0.1);
                % Add a label with the node number
                counter_nodes = counter_nodes + 1;
                label = sprintf('n %d', counter_nodes); % Format the label
                text(nodes(i,1),nodes(i,2), label, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize', 10);

            end
        end

    % Title and Labels
    if exist('plotTitle', 'var') && ~isempty(plotTitle)
        title(plotTitle, 'Interpreter', 'none');
    end
    if exist('xAxisLabel', 'var') && ~isempty(xAxisLabel)
        xlabel(xAxisLabel);
    end
    if exist('yAxisLabel', 'var') && ~isempty(yAxisLabel)
        ylabel(yAxisLabel);
    end

    legend('Traza del ala', 'Borde de ataque', 'Borde de salida', ...
        'Larguero anterior', 'Larguero posterior', 'Location', 'best');

    hold off;

    %% 💾 Save Plot and Data
    if exist('savePath', 'var') && ~isempty(savePath)
        [filePath, fileName, ext] = fileparts(savePath);
        if isempty(ext)
            % Default: Save as .png, .fig, and .mat
            saveas(fig, fullfile(filePath, [fileName, '.png']));
            savefig(fig, fullfile(filePath, [fileName, '.fig']));
            save(fullfile(filePath, [fileName, '.mat']), ...
                'Lf', 'Lw', 'c1', 'c2', 'b', ...
                'y_global_punta_ala_borde_ataque', 'flecha_radianes', ...
                'Distancia_larguero_anterior_cuerda_porcentaje', ...
                'Distancia_larguero_posterior_cuerda_porcentaje', ...
                'distancia_centro_aerodinamico', ...
                'distancia_eje_de_referencia_estructural_cuerda', ...
                'numero_de_puntos_en_las_lineas', ...
                'x_local_ala', 'y', 'x', ...
                'linea_larguero_anterior', 'linea_larguero_posterior');
        elseif strcmp(ext, '.fig')
            savefig(fig, savePath);
        elseif strcmp(ext, '.mat')
            save(savePath, ...
                'Lf', 'Lw', 'c1', 'c2', 'b', ...
                'y_global_punta_ala_borde_ataque', 'flecha_radianes', ...
                'Distancia_larguero_anterior_cuerda_porcentaje', ...
                'Distancia_larguero_posterior_cuerda_porcentaje', ...
                'distancia_centro_aerodinamico', ...
                'distancia_eje_de_referencia_estructural_cuerda', ...
                'numero_de_puntos_en_las_lineas', ...
                'x_local_ala', 'y', 'x', ...
                'linea_larguero_anterior', 'linea_larguero_posterior');
        else
            saveas(fig, savePath);
            savefig(fig, fullfile(filePath, [fileName, '.fig']));
            save(fullfile(filePath, [fileName, '.mat']), ...
                'Lf', 'Lw', 'c1', 'c2', 'b', ...
                'y_global_punta_ala_borde_ataque', 'flecha_radianes');
        end
        fprintf('Plot and data saved to: %s\n', savePath);
    end

    close(fig); % Optional: Close the figure to avoid clutter
end
