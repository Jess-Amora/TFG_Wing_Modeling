
function results = generateCostillas_v0(geom, cargas, avion)
%GENERATECOSTILLAS_V1 Computes the rib geometry and aerodynamic load, returning all results in a struct.
%
% Outputs are returned in a struct 'results' with fields:
%   - costillas
%   - costilla_medios
%   - load_data
%   - num_costillas
%   - num_costillas_triangulo
%   - costilla_costilla_medio

    % Extract relevant parameters from geometry
    Lf = geom.Lf;
    Lw = geom.Lw;
    c1 = geom.c1;
    c2 = geom.c2;
    datosEstructural = avion.datosEstructural;
    numero_points = geom.numero_points;
    linea_larg_posterior = geom.linea_larg_posterior;
    linea_larg_anterior = geom.linea_larg_anterior;
    pendiente_larg_anterior = geom.pendiente_larg_anterior;
    alfa_larg_posterior = geom.alfa_larg_posterior;
    const_larg_anterior = geom.const_larg_anterior;
    
    % Structural parameter: spacing between ribs
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    
    % Estimate the length of the posterior stringer
    x_start = Lf;
    y_start = c1 * geom.Dist_larg_posterior;
    x_end = Lf + Lw;
    y_end = avion.geometria.y_global_punta_ala_borde_ataque + c2 * geom.Dist_larg_posterior;
    longitud_posterior = norm([x_end - x_start, y_end - y_start]);
    
    % Determine the number of ribs (costillas)
    num_costillas = floor(longitud_posterior / distancia_entre_costillas);
    
    % Preallocate costillas array
    costillas = zeros(num_costillas, 2, numero_points);
    
    % Compute the posterior rib points along the posterior stringer.
    x_cost_post = Lf + (0:(num_costillas-1))' * distancia_entre_costillas * cos(alfa_larg_posterior);
    y_cost_post = interp1(geom.x_local_ala, linea_larg_posterior, x_cost_post, 'spline');
    
    % Compute the line intercept for each rib
    m_perp = geom.pendiente_perp;
    b_cost = y_cost_post - m_perp * x_cost_post;
    
    % Intersection with the anterior stringer
    x_intersections = (const_larg_anterior - b_cost) ./ (m_perp - pendiente_larg_anterior);
    y_intersections = pendiente_larg_anterior * x_intersections + const_larg_anterior;
    
    % Build each rib line
    for i = 1:num_costillas
        costillas(i,1,:) = linspace(x_cost_post(i), x_intersections(i), numero_points);
        costillas(i,2,:) = linspace(y_cost_post(i), y_intersections(i), numero_points);
    end
    
    % Compute midpoints (costilla_medios)
    costilla_medios = zeros(num_costillas-1, 2);
    for i = 1:(num_costillas-1)
        costilla_medios(i,:) = ([x_intersections(i), y_intersections(i)] + [x_intersections(i+1), y_intersections(i+1)]) / 2;
    end
    
    % Compute aerodynamic load
    load_data = zeros(num_costillas-1, 1);
    for i = 1:(num_costillas-1)
        load_data(i) = interp1(geom.x_local_ala, cargas.schrenk, costilla_medios(i,1), 'spline');
    end
    n_val = datosEstructural.n;
    MTOW = avion.MTOW;
    load_data = load_data * n_val * MTOW * 2 / (Lw^2);
    
    % Triangular section ribs
    num_costillas_triangulo = max(0, floor(num_costillas * 0.3));
    
    % Build costilla_costilla_medio
    costilla_costilla_medio = zeros(num_costillas*2 - 1, 4);
    idx = 1;
    for i = 1:(num_costillas-1)
        costilla_costilla_medio(idx,:) = [ squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1)), ...
                                             squeeze(costillas(i,1,end)), squeeze(costillas(i,2,end)) ];
        idx = idx + 1;
        costilla_costilla_medio(idx,:) = [ (squeeze(costillas(i,1,1)) + squeeze(costillas(i+1,1,1)))/2, ...
                                           (squeeze(costillas(i,2,1)) + squeeze(costillas(i+1,2,1)))/2, ...
                                           (squeeze(costillas(i,1,end)) + squeeze(costillas(i+1,1,end)))/2, ...
                                           (squeeze(costillas(i,2,end)) + squeeze(costillas(i+1,2,end)))/2 ];
        idx = idx + 1;
    end
    costilla_costilla_medio(end,:) = [ squeeze(costillas(end,1,1)), squeeze(costillas(end,2,1)), ...
                                       squeeze(costillas(end,1,end)), squeeze(costillas(end,2,end)) ];

    % Return all outputs as a struct
    results = struct();
    results.costillas = costillas;
    results.costilla_medios = costilla_medios;
    results.load_data = load_data;
    results.num_costillas = num_costillas;
    results.num_costillas_triangulo = num_costillas_triangulo;
    results.costilla_costilla_medio = costilla_costilla_medio;

end