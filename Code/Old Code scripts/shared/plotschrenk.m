function plotschrenk(avion,datosEstructural)
    % Extraer parámetros
    % Geometría
    Lw = avion.geometria.Lw;
    b = avion.geometria.b;
    superficie = avion.superficie;

    % Coordenadas
    x_cuerda = avion.coordenadas.x_cuerda;
    y = avion.coordenadas.y;
    x = avion.coordenadas.x;
    c = avion.coordenadas.c;

    % Datos estructural
    k_sust = datosEstructural.k_sust_a350_1000;

    % Cargas
    l_eliptica = 2*superficie/pi/(Lw)*sqrt(1-((x_cuerda)/(Lw)).^2); 
    l_cuerda =  k_sust * c ;
    schrenk=(l_eliptica+l_cuerda)/2;

    figure;
    plot(x_cuerda,l_cuerda)
    hold on
    plot(x_cuerda,l_eliptica)
    schrenk=(l_eliptica+l_cuerda)/2;
    plot(x_cuerda,schrenk)
    legend('cuerda','eliptica','schrenk')
end