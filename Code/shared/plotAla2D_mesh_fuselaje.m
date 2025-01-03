function plotAla2D_mesh_fuselaje(avion,datosEstructural,fuselaje,ala)
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
    flecha_radianes = avion.geometria.flecha.radian;

    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;

    % Coordenadas
    x_local_ala = avion.coordenadas.x_local_ala;
    y = avion.coordenadas.y;
    x = avion.coordenadas.y;
    
    % Ala 
    numero_larguerillos_total = ala.numero_larguerillos_total;
    linea_larguero_anterior = ala.geometria.linea_larguero_anterior;
    linea_larguero_posterior = ala.geometria.linea_larguero_posterior;

    % Fuselaje
    numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);
    costillas_fuselaje = fuselaje.costillas_fuselaje;
    larguerillos_fuselaje = fuselaje.larguerillos_fuselaje;

    figure
    hold on
    % Cajón fuselaje
    plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala');
    plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
    % 
    % % Cajón fuselaje
    % plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'r--', 'DisplayName', 'Traza del ala');
    % plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');
    % plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');
    % plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');

    % Cajón fuselaje
    plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*Distancia_larguero_anterior_cuerda_porcentaje*ones(1,numero_de_puntos_en_las_lineas),'r--', 'DisplayName', 'Caja de torsion');
    plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*Distancia_larguero_posterior_cuerda_porcentaje*ones(1,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');
    plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(c1*Distancia_larguero_anterior_cuerda_porcentaje,c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');
    plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(c1*Distancia_larguero_anterior_cuerda_porcentaje,c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r--', 'HandleVisibility', 'off');

    % Cajón de torsión
    % plot(x_local_ala,linea_larguero_anterior,'r','LineWidth',3, 'DisplayName', 'Caja de torsion', 'LineWidth', 0.1);
    % plot(x_local_ala,linea_larguero_posterior,'r','LineWidth',3, 'HandleVisibility', 'off', 'LineWidth', 0.1);
    % plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(Distancia_larguero_anterior_cuerda_porcentaje*c1 , c1*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'DisplayName', 'Caja de torsion', 'LineWidth', 0.1);
    % plot((Lf+Lw)*ones(1,numero_de_puntos_en_las_lineas),linspace(y_global_punta_ala_borde_ataque+Distancia_larguero_anterior_cuerda_porcentaje*c2,y_global_punta_ala_borde_ataque+c2*Distancia_larguero_posterior_cuerda_porcentaje,numero_de_puntos_en_las_lineas),'r','LineWidth',3, 'HandleVisibility', 'off');

    % Costillas
    for i=1:numero_costillas_fuselaje
        if i == 1
            plot(squeeze(costillas_fuselaje(i,1,:)),squeeze(costillas_fuselaje(i,2,:)),'k', 'DisplayName', 'Costillas');
        else
            plot(squeeze(costillas_fuselaje(i,1,:)),squeeze(costillas_fuselaje(i,2,:)),'k', 'HandleVisibility', 'off');
        end

    end

    for i=1:numero_larguerillos_total
        if i == 1
            plot(squeeze(larguerillos_fuselaje(i,1,:)),squeeze(larguerillos_fuselaje(i,2,:)),'k', 'DisplayName', 'larguerillos_fuselaje');
        else
            plot(squeeze(larguerillos_fuselaje(i,1,:)),squeeze(larguerillos_fuselaje(i,2,:)),'k', 'HandleVisibility', 'off');
        end
    end
    
    nodos_larguerillos_fuselaje = squeeze(fuselaje.mesh.nodos_larguerillos_fuselaje); % larguerillos
    nodos_posterior_fuselaje = fuselaje.mesh.nodos_posterior_fuselaje; % Los nodos en el larguero posterior.
    nodos_anterior_fuselaje = fuselaje.mesh.nodos_anterior_fuselaje; % Los nodos en el larguero posterior.

   
    %nodos_larguerillos_fuselaje
    for i=1:size(nodos_larguerillos_fuselaje,1)
        if i == 1
            plot(nodos_larguerillos_fuselaje(i,1),nodos_larguerillos_fuselaje(i,2),'xk', 'DisplayName', 'Nodos Larguerillos');
        else
            plot(nodos_larguerillos_fuselaje(i,1),nodos_larguerillos_fuselaje(i,2),'xk', 'HandleVisibility', 'off');
        end
    end
    
    %nodos_posterior_fuselaje
    for i=1:size(nodos_posterior_fuselaje,1)
        if i == 1
            plot(nodos_posterior_fuselaje(i,1),nodos_posterior_fuselaje(i,2),'or', 'DisplayName', 'Nodos Posterior');
        else
            plot(nodos_posterior_fuselaje(i,1),nodos_posterior_fuselaje(i,2),'or', 'HandleVisibility', 'off');
        end
    end
    
    %nodos_anterior_fuselaje
    for i=1:size(nodos_anterior_fuselaje,1)
        if i == 1
            plot(nodos_anterior_fuselaje(i,1),nodos_anterior_fuselaje(i,2),'+r', 'DisplayName', 'Nodos Anterior');
        else
            plot(nodos_anterior_fuselaje(i,1),nodos_anterior_fuselaje(i,2),'+r', 'HandleVisibility', 'off');
        end
    end

    legend();
    hold off
        
end
