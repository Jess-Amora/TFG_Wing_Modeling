function [results] = calculate_lift_distribution(ala,avion,cargas)
    % Function to calculate aerodynamic loads `l` and lift distribution `L`
    % Inputs:
    %   - x_l, y_l: Coordinates of the aerodynamic center
    %   - schrenk: Schrenk's lift distribution
    %   - n: Load factor
    %   - MTOW: Maximum takeoff weight
    %   - Lw: Wing span (half-span)
    %   - numero_costillas: Number of ribs
    % Outputs:
    %   - l: Lift per unit span at each segment
    %   - L: Lift distribution along the span
    %   - x_L, y_L: Coordinates of the lift points
    %   - cociente_L_W_inicial: Ratio of total lift to weight
    

    % Loading data
    MTOW = avion.MTOW;
    n = avion.datosEstructural.n;
    Lw = avion.geometria.Lw;
    numero_costillas = ala.numero_costillas;
    x_l = ala.x_l;
    y_l = ala.y_l;
    x_local_ala = avion.coordenadas.x_local_ala;
    coord_aerodinamica_costillas_punto_medio = ala.coord_aerodinamica_costillas_punto_medio;
    schrenk = cargas.schrenk;

    % Initialize the aerodynamic load array
    l = zeros(numero_costillas - 1, 1);

     % Compute aerodynamic loads `l` at rib midpoints
    l = spline(x_local_ala, schrenk, coord_aerodinamica_costillas_punto_medio);  % Interpolate `schrenk`
    l = l * n * MTOW * 2 / Lw^2;  % Scale by load factor and weight

    % Compute lift distribution `L`
    L = zeros(numero_costillas - 3, 1);
    x_L = coord_aerodinamica_costillas_punto_medio(2:end-1);
    y_L = zeros(size(x_L));

    for i = 2:numero_costillas-2
        L(i-1) = (1/6) * (x_L(i+1) - x_L(i)) * (2*l(i) + l(i+1)) ...
               + (1/6) * (x_L(i) - x_L(i-1)) * (l(i) + 2*l(i-1));
    end

    % Calculate the lift-to-weight ratio
    cociente_L_W_inicial = 2 * sum(L) / (n * MTOW);



    % Results
    results = struct();
    results.l = l;
    results.L = L;
    results.x_L = x_L;
    results.y_L = y_L;
    results.cociente_L_W_inicial = cociente_L_W_inicial;

end
