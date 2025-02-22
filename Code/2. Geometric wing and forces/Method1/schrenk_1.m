function [cargas] = schrenk_1(avion)
    % Extraer parámetros
    
    % Datos estructural
    datosEstructural = avion.datosEstructural;
    flecha_radian = avion.geometria.flecha_radian;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    
    % Geometría
    Lf = avion.geometria.Lf;
    b = avion.geometria.b;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    superficie = avion.superficie;
    Lw = b/2 - Lf;

    y_global_punta_ala_borde_ataque = c1 * distancia_centro_aerodinamico + sin(flecha_radian) * Lw -c2 * distancia_centro_aerodinamico;
    
    % x_local_ala = linspace(Lf,Lw+Lf,numero_de_puntos_en_las_lineas); % Es la coordenada horizontal que empieza desde el encastre y termina en la punta del ala.
    x_cuerda = linspace(0,Lw,numero_de_puntos_en_las_lineas);
    c = ( c1 - ( (c1-c2) / Lw ) * x_cuerda ); % c(x) La función de la cuerda que es función de x

    y = linspace( 0 , y_global_punta_ala_borde_ataque , numero_de_puntos_en_las_lineas);
    x = linspace( 0 , b/2 , numero_de_puntos_en_las_lineas);
    
    % Coordenadas

    % Datos estructural
    k_sust = datosEstructural.k_sust_a350_1000;

    % Cargas
    l_eliptica = 2*superficie/pi/(b/2)*sqrt(1-((x_cuerda)/(b/2)).^2); 
    l_cuerda =  k_sust * c ;
    schrenk=(l_eliptica+l_cuerda)/2;
    cargas = struct('l_eliptica',l_eliptica,'l_cuerda',l_cuerda,'schrenk',schrenk);
end