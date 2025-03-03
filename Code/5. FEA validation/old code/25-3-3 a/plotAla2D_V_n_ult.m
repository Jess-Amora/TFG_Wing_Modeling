function plotAla2D_V_n_ult(avion)
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
    datosEstructural = avion.datosEstructural;
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

% fig1 = figure;
% ax1 = findall(fig1, 'Type', 'axes');% Esta parte es para llevar los datos en el siguiente figure
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



fig1 = figure();
ax1 = findall(fig1, 'Type', 'axes');% Esta parte es para llevar los datos en el siguiente figure
hold on
for k = 1:length(ax1)
    % Copy each axis and its children to figure(3)
    new_ax = copyobj(ax1(k), fig1);
    % Adjust position if needed to fit the layout in fig3
    set(new_ax, 'Position', get(ax1(k), 'Position'));
end

% Cajón fuselaje
plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala');
plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');

% La línea de los bordes de ataque
plot(x_local_ala,linspace(0,y_global_punta_ala_borde_ataque,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
% La línea de los bordes de salida
plot(x_local_ala,linspace(c1,y_global_punta_ala_borde_ataque + c2,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');

% La línea de la cuerda final/en la punta
plot(b/2*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque,y_global_punta_ala_borde_ataque+c2,numero_de_puntos_en_las_lineas),'k');

% legend([f1 f2],{'Linea de los Centros Aerodinámico','Eje estructural'},'Location','best')

% Cajón de torsión
plot(x_local_ala,linea_larguero_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion');
plot(x_local_ala,linea_larguero_posterior,'r','LineWidth',3, 'HandleVisibility', 'off');
plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');
plot((Lf+Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');

plot(x_local_ala,linea_centro_aerodinamico,'c','LineWidth',1, 'DisplayName', 'La línea de los centros aerodinámicos');
plot(x_local_ala,linea_eje_estructural,'g', 'DisplayName', 'El eje de referencia estructural');

%%
ala = avion.ala;

anterior = squeeze(ala.costillas(:, :, end));  % anterior spar intersections
posterior = squeeze(ala.costillas(:, :, 1));   % posterior spar intersections



V_rear = avion.forces_n_ult.V.rear;
V_front = avion.forces_n_ult.V.front;

stem3(anterior(2:end-1,1), anterior(2:end-1,2), V_front, 'filled');
view(3)
stem3(posterior(2:end-1,1), posterior(2:end-1,2), V_rear, 'filled');
view(3)
% hold on
% stem3(anterior(:,1), anterior(:,2), V_mass_wing.front, 'filled');
% hold on
% stem3(posterior(:,1), posterior(:,2), V_mass_wing.rear, 'filled');
% xlabel('X (Spanwise)');
% ylabel('Y (Chordwise)');
% zlabel('Force Magnitude');
% title('Discrete Forces on the Wing');
grid on;
% stem3(x_coords, y_coords, F_z, 'filled');
% xlabel('X (Spanwise)');
% ylabel('Y (Chordwise)');
% zlabel('Force Magnitude');
% title('Discrete Forces on the Wing');
% grid on;


% stem3(ala.x_l, ala.y_l, ala.l, 'filled');
% view(3)

% anterior = squeeze(ala.costillas(:, :, end));  % anterior spar intersections
% posterior = squeeze(ala.costillas(:, :, 1));   % posterior spar intersections
% V_mass_wing = avion.weight_n1.V_mass_wing;
% V_mass_comb = avion.weight_n1.V_mass_wing;

        legend('Location', 'southeast');
        
        hold off

        %%
        
    if isfield(avion.folder, 'figures') && ~isempty(avion.folder.figures)
        if ~isfolder(avion.folder.figures)
            mkdir(avion.folder.figures);
            disp(['📁 Created folder: ', avion.folder.figures]);
        end

        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.png'));
        saveas(fig1, fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.fig'));
        disp(['📊 Saved plot to: ', fullfile(avion.folder.figures, 'Plot_forces_V_n_ult.png')]);
    end

    close(fig1); % Optional: Close the figure to avoid clutter
end
