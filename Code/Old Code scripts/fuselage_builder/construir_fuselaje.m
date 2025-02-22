function [results] = construir_fuselaje(avion,datosEstructural, showplot)

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
    MTOW = avion.MTOW;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha.radian;
    % Datos estructural
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    n = datosEstructural.n;

    numero_costillas_fuselaje = floor(Lf/distancia_entre_costillas);


    costillas_fuselaje = zeros(numero_costillas_fuselaje,2,numero_de_puntos_en_las_lineas);

    costillas_fuselaje(1,:,:) = [zeros(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';

    for i = 2:numero_costillas_fuselaje
        costillas_fuselaje(i,:,:) = [(Lf-distancia_entre_costillas*(numero_costillas_fuselaje-i+1))*ones(numero_de_puntos_en_las_lineas,1), linspace(Distancia_larguero_posterior_cuerda_porcentaje*c1,Distancia_larguero_anterior_cuerda_porcentaje*c1,numero_de_puntos_en_las_lineas)']';
    end
    
    % Larguerillos
    longitud_porcentaje_cuerda_largueros = Distancia_larguero_posterior_cuerda_porcentaje - Distancia_larguero_anterior_cuerda_porcentaje; % Es la longitud entre los largueros anterior y posterior
    numero_larguerillos_total = floor(c1*longitud_porcentaje_cuerda_largueros/distancia_entre_larguerillo);
    larguerillos_fuselaje = zeros (numero_larguerillos_total,2,numero_de_puntos_en_las_lineas);

    for i = 1:numero_larguerillos_total
        larguerillos_fuselaje(i,:,:) =[linspace(0,Lf,numero_de_puntos_en_las_lineas);ones(numero_de_puntos_en_las_lineas,1)*(c1*Distancia_larguero_posterior_cuerda_porcentaje-(i*distancia_entre_larguerillo))];
    end

    if showplot
        figure
        hold on
        % Cajón fuselaje
        plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),zeros(1,numero_de_puntos_en_las_lineas),'k--', 'DisplayName', 'Traza del ala');
        plot(linspace(0,Lf,numero_de_puntos_en_las_lineas),c1*ones(1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
        plot(Lf*ones(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');
        plot(zeros(1,numero_de_puntos_en_las_lineas),linspace(0,c1,numero_de_puntos_en_las_lineas),'k--', 'HandleVisibility', 'off');

        % Costillas
        for i=1:numero_costillas_fuselaje
            if i == 1
                plot(squeeze(costillas_fuselaje(i,1,:)),squeeze(costillas_fuselaje(i,2,:)),'k', 'DisplayName', 'Costillas');
            else
                plot(squeeze(costillas_fuselaje(i,1,:)),squeeze(costillas_fuselaje(i,2,:)),'k', 'HandleVisibility', 'off');
            end
        end
        
        hold off
    end

    

    results.larguerillos_fuselaje = larguerillos_fuselaje;
    results.costillas_fuselaje = costillas_fuselaje;
    results.numero_costillas_fuselaje = numero_costillas_fuselaje;
end