function [results] = generate_wing_v3(avion, datosEstructural, cargas, databasePath)

    %% Extract Parameters
    % Wing geometry
    Lf = avion.geometria.Lf; 
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1; 
    c2 = avion.geometria.c2; 
    b = avion.geometria.b; 
    MTOW = avion.MTOW;

    y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;
    flecha_radianes = avion.geometria.flecha_radian;

    % Structural data
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Distancia_larguero_posterior_cuerda_porcentaje = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje_de_referencia_estructural_cuerda = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_de_puntos_en_las_lineas = datosEstructural.numero_de_puntos_en_las_lineas;
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    n = datosEstructural.n;

    % Aerodynamic loads
    schrenk = cargas.schrenk;

    % Local spanwise coordinates
    x_local_ala = avion.coordenadas.x_local_ala;

    %% Lines Definitions
    linea_larguero_anterior = linspace(c1 * Distancia_larguero_anterior_cuerda_porcentaje, ...
        y_global_punta_ala_borde_ataque + Distancia_larguero_anterior_cuerda_porcentaje * c2, numero_de_puntos_en_las_lineas);

    linea_larguero_posterior = linspace(c1 * Distancia_larguero_posterior_cuerda_porcentaje, ...
        y_global_punta_ala_borde_ataque + Distancia_larguero_posterior_cuerda_porcentaje * c2, numero_de_puntos_en_las_lineas);

    linea_centro_aerodinamico = linspace(c1 * distancia_centro_aerodinamico, ...
        c1 * distancia_centro_aerodinamico + Lw * sin(flecha_radianes), numero_de_puntos_en_las_lineas);

    linea_eje_estructural = linspace(c1 * distancia_eje_de_referencia_estructural_cuerda, ...
        c2 * distancia_eje_de_referencia_estructural_cuerda + y_global_punta_ala_borde_ataque, numero_de_puntos_en_las_lineas);

    %% Calculate Slopes
    pendiente_larguero_anterior = (linea_larguero_anterior(end) - linea_larguero_anterior(1)) / Lw;
    pendiente_larguero_posterior = (linea_larguero_posterior(end) - linea_larguero_posterior(1)) / Lw;
    pendiente_eje_estructural = (linea_eje_estructural(end) - linea_eje_estructural(1)) / Lw;
    pendiente_perpendicular_larguero_posterior = -1 / pendiente_larguero_posterior;

    %% Spar and Rib Intersection Points
    % Calculate the rear spar length and the number of ribs
    longitud_larguero_posterior = norm([Lf + Lw, y_global_punta_ala_borde_ataque + c2 * Distancia_larguero_posterior_cuerda_porcentaje] ...
        - [Lf, c1 * Distancia_larguero_posterior_cuerda_porcentaje]);
    numero_costillas = floor(longitud_larguero_posterior / distancia_entre_costillas);

    % Ribs' coordinates
    coord_costillas_larguero_posterior_x = Lf: ...
        distancia_entre_costillas * cos(atan(pendiente_larguero_posterior)): ...
        Lf + (numero_costillas - 1) * distancia_entre_costillas * cos(atan(pendiente_larguero_posterior));
    coord_costillas_larguero_posterior_y = spline(x_local_ala, linea_larguero_posterior, coord_costillas_larguero_posterior_x);

    constante_perpendicular_larguero_posterior = coord_costillas_larguero_posterior_y ...
        - pendiente_perpendicular_larguero_posterior * coord_costillas_larguero_posterior_x;

    %% Generate Triangular Region Ribs
    % Adjust spacing for triangular ribs
    coord_costillas_larguero_posterior_y_triangulo = c1 * Distancia_larguero_posterior_cuerda_porcentaje: ...
        -distancia_entre_costillas / sin(atan(pendiente_larguero_posterior)): ...
        c1 * 0.25;
    coord_costillas_larguero_posterior_x_triangulo = Lf * ones(size(coord_costillas_larguero_posterior_y_triangulo));

    % Debugging: Ensure monotonicity of triangular ribs
    if any(diff(coord_costillas_larguero_posterior_y_triangulo) > 0)
        error('Triangular ribs are not descending properly in the rear spar.');
    end

    %% Combine Ribs for Entire Wing
    % Use triangular ribs and the main spar ribs
    costillas_triangulo = zeros(length(coord_costillas_larguero_posterior_y_triangulo), 2, numero_de_puntos_en_las_lineas);

    % Loop through triangular ribs to compute coordinates
    for i = 1:length(coord_costillas_larguero_posterior_y_triangulo)
        x_start = coord_costillas_larguero_posterior_x_triangulo(i);
        y_start = coord_costillas_larguero_posterior_y_triangulo(i);
        
        constante_linea_larguero_anterior = linea_larguero_anterior(1) - pendiente_larguero_anterior * Lf;

        % Intersection with anterior spar
        x_end = (constante_perpendicular_larguero_posterior(i) - constante_linea_larguero_anterior) / ...
            (pendiente_larguero_anterior - pendiente_perpendicular_larguero_posterior);
        y_end = pendiente_larguero_anterior * x_end + constante_linea_larguero_anterior;

        % Discretize the rib
        costillas_triangulo(i, 1, :) = linspace(x_start, x_end, numero_de_puntos_en_las_lineas);
        costillas_triangulo(i, 2, :) = linspace(y_start, y_end, numero_de_puntos_en_las_lineas);
    end

    %% Debugging
    assignin('base', 'coord_costillas_larguero_posterior_y_triangulo', coord_costillas_larguero_posterior_y_triangulo);
    assignin('base', 'costillas_triangulo', costillas_triangulo);

    %% Final Output
    results = struct();
    results.costillas = costillas_triangulo;
    results.numero_costillas = numero_costillas;
    results.coord_costillas_larguero_posterior_y_triangulo = coord_costillas_larguero_posterior_y_triangulo;
    results.coord_costillas_larguero_posterior_x_triangulo = coord_costillas_larguero_posterior_x_triangulo;

    disp('Wing generation complete.');


end
