function intersection_point = find_point_on_front_spar(x, y, ala, avion,datosEstructural)
% find_point_on_front_spar: Finds the intersection point on the front spar line.
%
% Inputs:
%   x, y: Coordinates of the starting point.
%   ala: Struct containing geometry information:
%        ala.geometria.pendiente_perpendicular_larguero_posterior: Slope of the line starting at (x, y).
%        ala.geometria.pendiente_larguero_anterior: Slope of the front spar line.
%        ala.geometria.Lf: X-coordinate of the front spar point.
%
% Output:
%   intersection_point: [x_intersect, y_intersect] coordinates of the intersection.

    %% Extract Geometry Parameters
    slope_perpendicular = ala.geometria.pendiente_perpendicular_larguero_posterior;
    slope_front_spar = ala.geometria.pendiente_larguero_anterior;
    Lf = avion.geometria.Lf;
    c1 = avion.geometria.c1;
    Distancia_larguero_anterior_cuerda_porcentaje = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;

    % Define the point on the front spar
    front_spar_point = [Lf, Distancia_larguero_anterior_cuerda_porcentaje*c1];

    %% Use cortes_de_dos_funciones_lineales_v3
    % Line 1: Starts at (x, y) with slope_perpendicular
    % Line 2: Starts at (Lf, 0) with slope_front_spar
    cortes = cortes_de_dos_funciones_lineales_v3([x, y], slope_perpendicular, ...
                                                 front_spar_point, slope_front_spar);

    % Extract the intersection point
    x_intersect = cortes(1, 1, 1);
    y_intersect = cortes(1, 1, 2);

    %% Return the Intersection Point
    intersection_point = [x_intersect, y_intersect];
end
