
%% ------------------------------------------------------------------------
function geom = computeStructuralGeometry_0(avion)
%computeStructuralGeometry_v0 Computes the key structural lines and parameters.
%
%   Uses aircraft geometry and structural percentages to calculate the chord
%   lines, slopes, intercepts, and related parameters.
%
    % Extract geometry parameters
    Lf = avion.geometria.Lf;
    Lw = avion.geometria.Lw;
    c1 = avion.geometria.c1;
    c2 = avion.geometria.c2;
    flecha = avion.geometria.flecha_radian; % in radians
    datosEstructural = avion.datosEstructural;
    distancia_centro_aerodinamico = datosEstructural.distancia_centro_aerodinamico;

    y_global_punta_ala_borde_ataque =  c1 * datosEstructural.distancia_centro_aerodinamico + sin(flecha) * (Lw) - c2 * datosEstructural.distancia_centro_aerodinamico;
    y_global = y_global_punta_ala_borde_ataque;
    
    % Structural percentages from datosEstructural
    Dist_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;
    Dist_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    distancia_centro = datosEstructural.distancia_centro_aerodinamico;
    distancia_eje = datosEstructural.distancia_eje_de_referencia_estructural_cuerda;
    numero_points = datosEstructural.numero_de_puntos_en_las_lineas;
    
    % x_local_ala provided in avion (assumed sorted)
    x_local_ala = avion.coordenadas.x_local_ala;
    
    % Compute chord lines (using linspace for a smooth distribution)
    linea_larg_anterior = linspace(c1*Dist_anterior, y_global + c2*Dist_anterior, numero_points);
    linea_larg_posterior = linspace(c1*Dist_posterior, y_global + c2*Dist_posterior, numero_points);
    linea_centro = linspace(c1*distancia_centro, c1*distancia_centro + Lw*sin(flecha), numero_points);
    linea_eje = linspace(c1*distancia_eje, c2*distancia_eje + y_global, numero_points);
    
    % Compute slopes (pendiente) of anterior and posterior stringers
    pendiente_larg_anterior = (linea_larg_anterior(end) - linea_larg_anterior(1)) / Lw;
    pendiente_larg_posterior = (linea_larg_posterior(end) - linea_larg_posterior(1)) / Lw;
    pendiente_eje = (linea_eje(end) - linea_eje(1)) / Lw;
    pendiente_centro = (linea_centro(end) - linea_centro(1)) / Lw;

    % Compute perpendicular slope to the posterior stringer (avoid division by zero)
    tol = 1e-8;
    if abs(pendiente_larg_posterior) < tol
        pendiente_perp = Inf;
    else
        pendiente_perp = -1 / pendiente_larg_posterior;
    end
    alfa_larg_posterior = atan(pendiente_larg_posterior);
    
    % Compute intercepts (ordenada al origen) at x = Lf
    const_larg_anterior = linea_larg_anterior(1) - pendiente_larg_anterior * Lf;
    const_larg_posterior = linea_larg_posterior(1) - pendiente_larg_posterior * Lf;
    const_eje = linea_eje(1) - pendiente_eje * Lf;
    const_centro = linea_centro(1) - pendiente_centro * Lf;

    % Package into a structure
    geom = struct();
    geom.Lf = Lf;
    geom.Lw = Lw;
    geom.c1 = c1;
    geom.c2 = c2;
    geom.flecha = flecha;
    geom.x_local_ala = x_local_ala;
    geom.linea_larg_anterior = linea_larg_anterior;
    geom.linea_larg_posterior = linea_larg_posterior;
    geom.linea_centro = linea_centro;
    geom.linea_eje = linea_eje;
    geom.pendiente_larg_anterior = pendiente_larg_anterior;
    geom.pendiente_larg_posterior = pendiente_larg_posterior;
    geom.pendiente_eje = pendiente_eje;
    geom.pendiente_perp = pendiente_perp;
    geom.pendiente_centro = pendiente_centro;
    geom.alfa_larg_posterior = alfa_larg_posterior;
    geom.const_larg_anterior = const_larg_anterior;
    geom.const_larg_posterior = const_larg_posterior;
    geom.const_eje = const_eje;
    geom.const_centro = const_centro;
    geom.numero_points = numero_points;
    geom.Dist_larg_anterior = Dist_anterior;
    geom.Dist_larg_posterior = Dist_posterior;
    
end