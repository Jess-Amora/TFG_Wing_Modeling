function OnlyPlotSurface_v6(combined_nodes,combined_nodes_fuselaje, quad_surfaces, tri_surfaces, rear_surfaces, plottitle, plotfilename,avion,datosEstructural)
% plot_stringer_irregular_surfaces_v9: Visualizes stringer surfaces with logic for irregular, triangular, pentagonal, and rear spar surfaces.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   quad_surfaces: Table for quadrilateral surfaces (irregular, P1 inserted, P4 inserted, etc.).
%   tri_surfaces: Table for triangular surfaces.
%   penta_surfaces: Table for pentagonal surfaces.
%   rear_surfaces: Table for "quad rear" surfaces created near the rear spar.
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%
% Output:
%   A plot visualizing the specified surfaces (triangular, quadrilateral, pentagonal, and rear spar).
%% cálculos previo
[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes);
%% 🎯 Initialize Plot
fig = figure('Name', 'Wing Surface Verification Plot', 'NumberTitle', 'off');
hold on;
axis equal;
grid on;
title(plottitle, 'Interpreter', 'none');
xlabel('X Coordinate');
ylabel('Y Coordinate');

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

% La línea del larguero anterior
linea_larguero_anterior=linspace(c1*Distancia_larguero_anterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);

% La línea del larguero posterior
linea_larguero_posterior=linspace(c1*Distancia_larguero_posterior_cuerda_porcentaje,y_global_punta_ala_borde_ataque+Distancia_larguero_posterior_cuerda_porcentaje*c2,numero_de_puntos_en_las_lineas);

% La línea de los centros aerodinámicos
linea_centro_aerodinamico=linspace(c1*distancia_centro_aerodinamico,c1*distancia_centro_aerodinamico+Lw*sin(flecha_radianes),numero_de_puntos_en_las_lineas);

linea_eje_estructural=linspace(c1*distancia_eje_de_referencia_estructural_cuerda,c2*distancia_eje_de_referencia_estructural_cuerda+y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas);
% Flag graph

% Cajón fuselaje
traza_del_ala = plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala', 'LineWidth', 0.1);
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
caja_de_torsion = plot(x_local_ala,linea_larguero_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion', 'LineWidth', 0.1);
plot(x_local_ala,linea_larguero_posterior,'r','LineWidth',3, 'HandleVisibility', 'off', 'LineWidth', 0.1);
plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');
plot((Lf+Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');

aero = plot(x_local_ala,linea_centro_aerodinamico,'c','LineWidth',1, 'DisplayName', 'La línea de los centros aerodinámicos', 'LineWidth', 0.1);
eje = plot(x_local_ala,linea_eje_estructural,'g', 'DisplayName', 'El eje de referencia estructural', 'LineWidth', 0.1);

%% 🟢 Plot Nodes Wing
% Identify node tags
front_spar_idx = strcmp(combined_nodes.tag, 'front spars');
rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');
stringer_idx = strcmp(combined_nodes.tag, 'stringer');
% inserted_idx = strcmp(combined_nodes.tag, 'inserted');

front_spar_dots = combined_nodes(strcmp(combined_nodes.tag, 'front spars'),:);
rear_spar_dots = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'),:);
stringer_dots = combined_nodes(strcmp(combined_nodes.tag, 'stringer'),:);
% inserted_dots = combined_nodes(strcmp(combined_nodes.tag, 'inserted'),:);

% Plot nodes with unique markers and colors
front_spar_points = plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
     'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
rear_spar_points = plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
     'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
stringer_points = plot(combined_nodes.x(stringer_idx), combined_nodes.y(stringer_idx), ...
     'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');
% inserted_table_points = plot(combined_nodes.x(inserted_idx), combined_nodes.y(inserted_idx), ...
%      'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Inserted Nodes');

% Add Node Labels (Optional for Debugging)
for i = 1:height(front_spar_dots)
    text(front_spar_dots.x(i), front_spar_dots.y(i), sprintf('%d', front_spar_dots.local_id(i)), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'red');
end
% Add Node Labels (Optional for Debugging)
for i = 1:height(rear_spar_dots)
    text(rear_spar_dots.x(i), rear_spar_dots.y(i), sprintf('%d', rear_spar_dots.local_id(i)), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'blue');
end
% Add Node Labels (Optional for Debugging)
for i = 1:height(stringer_dots)
    text(stringer_dots.x(i), stringer_dots.y(i), sprintf('%d', stringer_dots.local_id(i)), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'black');
end
% % Add Node Labels (Optional for Debugging)
% for i = 1:height(inserted_dots)
%     text(inserted_dots.x(i), inserted_dots.y(i), sprintf('%d', inserted_dots.stringer_index(i)), ...
%          'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'black');
% end

% %% 🟢 Plot Nodes Fuselaje
% % Identify node tags
% front_spar_idx_fuselaje = strcmp(combined_nodes_fuselaje.tag, 'front spars fuselaje');
% rear_spar_idx_fuselaje = strcmp(combined_nodes_fuselaje.tag, 'rear spars fuselaje');
% stringer_idx_fuselaje = strcmp(combined_nodes_fuselaje.tag, 'stringer fuselaje');
% 
% front_spar_dots_fuselaje = combined_nodes_fuselaje(strcmp(combined_nodes_fuselaje.tag, 'front spars fuselaje'),:);
% rear_spar_dots_fuselaje = combined_nodes_fuselaje(strcmp(combined_nodes_fuselaje.tag, 'rear spars fuselaje'),:);
% stringer_dots_fuselaje = combined_nodes_fuselaje(strcmp(combined_nodes_fuselaje.tag, 'stringer fuselaje'),:);
% 
% 
% % Plot nodes with unique markers and colors
% front_spar_points_fuselaje = plot(combined_nodes_fuselaje.x(front_spar_idx_fuselaje), combined_nodes_fuselaje.y(front_spar_idx_fuselaje), ...
%      'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
% rear_spar_points_fuselaje = plot(combined_nodes_fuselaje.x(rear_spar_idx_fuselaje), combined_nodes_fuselaje.y(rear_spar_idx_fuselaje), ...
%      'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
% stringer_points_fuselaje = plot(combined_nodes_fuselaje.x(stringer_idx_fuselaje), combined_nodes_fuselaje.y(stringer_idx_fuselaje), ...
%      'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');
% 
% % Add Node Labels (Optional for Debugging)
% for i = 1:height(front_spar_dots_fuselaje)
%     text(front_spar_dots_fuselaje.x(i), front_spar_dots_fuselaje.y(i), sprintf('%d', front_spar_dots_fuselaje.local_id(i)), ...
%          'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'red');
% end
% % Add Node Labels (Optional for Debugging)
% for i = 1:height(rear_spar_dots_fuselaje)
%     text(rear_spar_dots_fuselaje.x(i), rear_spar_dots_fuselaje.y(i), sprintf('%d', rear_spar_dots_fuselaje.local_id(i)), ...
%          'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'blue');
% end
% % Add Node Labels (Optional for Debugging)
% for i = 1:height(stringer_dots_fuselaje)
%     text(stringer_dots_fuselaje.x(i), stringer_dots_fuselaje.y(i), sprintf('%d', stringer_dots_fuselaje.local_id(i)), ...
%          'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'black');
% end


%% 🔵 Plot Quadrilateral Surfaces for Different Tags
if ~isempty(quad_surfaces)
    for i = 1:height(quad_surfaces)
        % Determine nodes based on the surface tag
        surface_tag = quad_surfaces.tags(i);

        if strcmp(surface_tag, "quad irregular P1 inserted")
            % P1 from inserted_table, other nodes from combined_nodes
            node_1 = combined_nodes(combined_nodes.stringer_index == quad_surfaces.stringer_1(i) & combined_nodes.rib_index ==2e5 & strcmp(combined_nodes.tag, 'stringer'), :);
            node_2 = combined_nodes(combined_nodes.stringer_index == quad_surfaces.stringer_2(i) & combined_nodes.rib_index ==-2, :);
            node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
            node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :);

        elseif strcmp(surface_tag, "quad irregular P4 inserted")
            % P4 from inserted_table, other nodes from combined_nodes
            node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.stringer_index == quad_surfaces.stringer_2(i) & combined_nodes.rib_index ==-2, :);
            node_4 = combined_nodes(combined_nodes.stringer_index == quad_surfaces.stringer_1(i) & combined_nodes.rib_index ==2e5 & strcmp(combined_nodes.tag, 'stringer'), :);

        elseif strcmp(surface_tag, "quad irregular")
            % P2 and P3 from front spar nodesquad irr root
            node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i) & strcmp(combined_nodes.tag, 'front spars'), :);
            node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
            node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :);
        elseif strcmp(surface_tag, "quad regular")
            % P2 and P3 from front spar nodes
            node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i)& strcmp(combined_nodes.tag, 'stringer'), :);
            node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i)& strcmp(combined_nodes.tag, 'stringer'), :);
            node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i)& strcmp(combined_nodes.tag, 'stringer'), :);
            node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i)& strcmp(combined_nodes.tag, 'stringer'), :);
            
        elseif strcmp(surface_tag, "quad irregular root")
            % Extract nodes
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == -1 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == -1 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right
            
            node_3 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :); % Top-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Top-left

        elseif strcmp(surface_tag, "quad irregular root corner")

            % Extract nodes
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right
            
            node_3 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :); % Top-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Top-left

        elseif strcmp(surface_tag, "quad irregular root P2 inserted")

            % Extract nodes
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == -1 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i) ...
                , :); % Bottom-left
            
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == 3e5 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i) & ...
                combined_nodes.tag == 'stringer', :); % Bottom-right
            
            node_3 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i) & ...
                combined_nodes.tag == 'stringer' , :); % Top-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i) & ...
                combined_nodes.tag == 'stringer' , :); % Top-right
            
        elseif strcmp(surface_tag, "quad irregular root P3 inserted")

            % Extract nodes
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes.stringer_index == -2 &...
                combined_nodes.tag == 'rear spars', :); % Bottom-left        
                        
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i) & ...
                combined_nodes.tag == 'stringer', :); % Top-right

            node_3 = combined_nodes( ...
                combined_nodes.rib_index == 3e5 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i) & ...
                combined_nodes.tag == 'stringer', :); % Bottom-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == -1 & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Top-left

        elseif strcmp(surface_tag, "quad OnlyNode1")

            % Extract nodes
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == 1e5 & ...
                combined_nodes.tag == 'front spars', :); % Bottom-right
            
            node_3 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :); % Top-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :); % Top-left
            
        elseif strcmp(surface_tag, "quad fuselaje front root")

            % Extract nodes
            node_1 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right
            
            node_3 = combined_nodes(combined_nodes.rib_index == 1e5 & combined_nodes.tag == 'front spars', :); % Top-right
            
            node_4 = combined_nodes(combined_nodes.rib_index == -1 & combined_nodes.stringer_index == max_stringer_index, :); % Top-left
            
        elseif strcmp(surface_tag, "quad fuselaje front")
        
            % Extract nodes
            node_1 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right
            
            node_3 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Top-right
            
            node_4 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Top-left

        elseif strcmp(surface_tag, "quad fuselaje rear root")
            
            % Extract nodes
            start_rib = rib_ranges(1,2);
            num_ribs = height(combined_nodes_fuselaje(combined_nodes_fuselaje.stringer_index == 1, :))-1;

            node_1 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == num_ribs & combined_nodes_fuselaje.tag == 'rear spars fuselaje', :);          % Top-left

            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_3 = combined_nodes(combined_nodes.rib_index == -1 & combined_nodes.stringer_index == 1, :); % Top-right

            node_4 = combined_nodes(combined_nodes.rib_index == start_rib & combined_nodes.tag == 'rear spars', :); % Top-left
        
        elseif strcmp(surface_tag, "quad fuselaje rear")
            
            % Extract nodes
            start_rib = rib_ranges(1,2);
            num_ribs = height(combined_nodes_fuselaje(combined_nodes_fuselaje.stringer_index == 1, :))-1;

            node_1 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & combined_nodes_fuselaje.tag == 'rear spars fuselaje', :);          % Top-left

            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_3 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_4 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & combined_nodes_fuselaje.tag == 'rear spars fuselaje', :);          % Top-left

         elseif strcmp(surface_tag, "quad fuselaje root")

            % Extract nodes
            start_rib = rib_ranges(1,2);
            num_ribs = height(combined_nodes_fuselaje(combined_nodes_fuselaje.stringer_index == 1, :))-1;

            node_1 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-right

            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_3 = combined_nodes(combined_nodes.rib_index == -1 & combined_nodes.stringer_index == quad_surfaces.stringer_2(i), :);

            node_4 = combined_nodes(combined_nodes.rib_index == -1 & combined_nodes.stringer_index == quad_surfaces.stringer_1(i), :);
        

        elseif strcmp(surface_tag, "quad fuselaje")

            % Extract nodes
            start_rib = rib_ranges(1,2);
            num_ribs = height(combined_nodes_fuselaje(combined_nodes_fuselaje.stringer_index == 1, :))-1;

            node_1 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-right

            node_2 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_1(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_3 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_2(i), :); % Bottom-right

            node_4 = combined_nodes_fuselaje( ...
                combined_nodes_fuselaje.rib_index == quad_surfaces.rib_2(i) & ...
                combined_nodes_fuselaje.stringer_index == quad_surfaces.stringer_1(i), :); % Bottom-right

        else
            % Unknown tag, skip this surface
            warning('Unknown surface tag: %s. Skipping surface %d.', surface_tag, i);
            continue;
        end

        % Ensure nodes are valid
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            % Extract relevant information for the missing nodes
            % Construct a detailed warning message
            quad_surfaces(i,:)
            node_1
            node_2
            node_3
            node_4
            warning('Skipping surface %d due to missing nodes. Missing nodes have tags: %s and local_ids: %s.', ...
                i, strjoin(string(surface_tag), ', '), strjoin(string(i), ', '));
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
             'EdgeColor', 'k', 'LineWidth', 1.2 );

        % Optional: Add metadata as text annotations
        center_x = mean(surface_coords(:, 1));
        center_y = mean(surface_coords(:, 2));
        % annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
        %     quad_surfaces.area(i), ...
        %     quad_surfaces.aspect_ratio(i));
        % text(center_x, center_y, annotation_text, 'FontSize', 8, ...
        %      'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
    end
end

%% 🔺 Plot Triangular Surfaces
if ~isempty(tri_surfaces)
    for i = 1:height(tri_surfaces)
        % Extract surface tag
        surface_tag = tri_surfaces.tags(i);

        % Tag-specific logic for triangular surfaces
        switch surface_tag
            case "tri front"
                % Extract nodes for "tri front"
                node_1 = combined_nodes( ...
                    combined_nodes.rib_index == -2 & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_1(i), :); % Bottom-left

                node_2 = find_max_rib_node_v2(combined_nodes, tri_surfaces.stringer_1(i)); % Bottom-right

                node_3 = combined_nodes( ...
                    combined_nodes.rib_index == node_2.rib_index & ...
                    strcmp(combined_nodes.tag, 'front spars'), :); % Top (on front spar)

                % Assign color for "tri front"
                % fill_color = [0, 1, 1]; % Cyan

            case "tri corner root"
                stringer_index =1;
                current_stringer_nodes = combined_nodes( ...
                    combined_nodes.stringer_index == stringer_index, :);
            
                next_stringer_nodes = combined_nodes( ...
                    combined_nodes.stringer_index == stringer_index + 1, :);
            
                start_rib = rib_ranges(1,2);

                % Triangulo
                node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
                node_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib,:); % Bottom-left
                node_3 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);


                % Assign color for "tri front"
                % fill_color = [0, 1, 1]; % Cyan

            case "tri root"
                % Extract nodes for "tri root"
                node_1 = combined_nodes( ...
                    combined_nodes.rib_index == tri_surfaces.rib_2(i)  & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_2(i), :); % Bottom-left

                node_2 = combined_nodes( ...
                    combined_nodes.rib_index == tri_surfaces.rib_2(i)  & ...
                    strcmp(combined_nodes.tag, 'rear spars'), :); % Bottom-right

                node_3 = combined_nodes( ...
                    combined_nodes.rib_index == -1 & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_2(i), :); % Top

                % Assign color for "tri root"
                % fill_color = [1, 0.5, 0]; % Orange
            case "tri last front"
                % Extract nodes for "tri root"
                node_1 = combined_nodes( ...
                    combined_nodes.rib_index ==  - 2 & ...
                    combined_nodes.stringer_index == max_stringer_index, :); 

                node_2 = combined_nodes( ...
                    combined_nodes.rib_index ==  rib_ranges(max_stringer_index,3) & ...
                    combined_nodes.stringer_index == max_stringer_index, :); 

                node_3 = combined_nodes( ...
                    combined_nodes.rib_index ==  rib_ranges(max_stringer_index,3) & ...
                    combined_nodes.tag == 'front spars', :); % Top


            otherwise
                warning('Unknown triangular surface tag: %s. Skipping surface %d.', surface_tag, i);
                continue;
        end

        % Validate nodes
        if isempty(node_1) || isempty(node_2) || isempty(node_3)
            warning('Skipping triangular surface %d due to missing nodes.', i);
            continue;
        end

        % Extract coordinates
        surface_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y
        ];

        % Plot the triangular surface
        fill(surface_coords(:, 1), surface_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
             'EdgeColor', 'k', 'LineWidth', 1.2 );
    end
end




%% 🔶 Plot Rear Spar Surfaces ("quad rear")
if ~isempty(rear_surfaces)
    for i = 1:height(rear_surfaces)
        % Extract nodes for the rear spar surface
        rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'), :);
        stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1, :);
        
        % Ensure rear spar and stringer nodes are present
        if isempty(rear_spar_nodes) || isempty(stringer_nodes)
            warning('No valid rear spar or stringer nodes found for rear spar surface %d. Skipping.', i);
            continue;
        end

        % Extract nodes for the current rib
        a1 = rear_surfaces.rib_1(i);
        a2 = rear_surfaces.rib_2(i);
        a3 = rear_surfaces.rib_1(i);
        a4 = rear_surfaces.rib_2(i);
         
        rear_spar_rib1 = rear_spar_nodes(rear_spar_nodes.rib_index == a1, :); % Rear spar at rib 1
        rear_spar_rib2 = rear_spar_nodes(rear_spar_nodes.rib_index == a2, :); % Rear spar at rib 2
        stringer_rib1 = stringer_nodes(stringer_nodes.rib_index == a3, :);    % Stringer at rib 1
        stringer_rib2 = stringer_nodes(stringer_nodes.rib_index == a4, :);    % Stringer at rib 2

        % Ensure all four nodes are present
        if isempty(rear_spar_rib1) || isempty(rear_spar_rib2) || isempty(stringer_rib1) || isempty(stringer_rib2)
            warning('Skipping rear spar surface %d: Insufficient nodes for ribs %d and %d.', i, rear_surfaces.rib_1(i), rear_surfaces.rib_2(i));
            continue;
        end

        % Extract Node Coordinates
        surface_coords = [
            rear_spar_rib1.x(1), rear_spar_rib1.y(1); % Node 1 (rear spar, rib 1)
            stringer_rib1.x(1), stringer_rib1.y(1);   % Node 2 (stringer, rib 1)
            stringer_rib2.x(1), stringer_rib2.y(1);   % Node 3 (stringer, rib 2)
            rear_spar_rib2.x(1), rear_spar_rib2.y(1)  % Node 4 (rear spar, rib 2)
        ];

        % Plot the rear spar surface
        fill(surface_coords(:, 1), surface_coords(:, 2), 'blue', 'FaceAlpha', 0.5, ...
             'EdgeColor', 'k', 'LineWidth', 1.2);
    end
end

%% 📌 Add Legend Using Placeholder Plots
% Add a legend entry for each surface type manually
% plot(NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
% plot(NaN, NaN, 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
% plot(NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');
% plot(NaN, NaN, 'magenta', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surfaces');
% plot(NaN, NaN, 'cyan', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surfaces')

% Add a legend entry for each surface type manually
h_quad = plot(NaN, NaN, 's', 'Color', 'magenta', 'MarkerFaceColor', 'magenta', 'DisplayName', 'Quadrilateral Surfaces');
h_tri = plot(NaN, NaN, '^', 'Color', 'cyan', 'MarkerFaceColor', 'cyan', 'DisplayName', 'Triangular Surfaces');
h_rear = plot(NaN, NaN, 's', 'Color', 'green', 'MarkerFaceColor', 'green', 'DisplayName', 'rear spar Surfaces');

% Show legend with placeholders
legend([traza_del_ala, caja_de_torsion, aero, eje, front_spar_points, rear_spar_points, stringer_points, h_rear, h_quad, h_tri], 'Location', 'best');


%% 💾 Save Plot
if exist('plotfilename', 'var') && ~isempty(plotfilename)
    saveas(fig, sprintf('%s.png', plotfilename));
    savefig(fig, sprintf('%s.fig', plotfilename));
end

disp('✅ Plotting complete and saved successfully.');
end
