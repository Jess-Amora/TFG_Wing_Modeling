function results = generateCostillas_1(geom_struct, cargas, avion)
%GENERATECOSTILLAS_1 Computes rib (costilla) geometry including a triangular zone.
%
%   Outputs are returned in a struct 'results' with fields:
%       .costillas
%       .costilla_medios
%       .load_data
%       .num_costillas_total
%       .num_costillas_tri
%       .costilla_costilla_medio

    %----- Extract key parameters -----
    datosEstructural = avion.datosEstructural;
    c1 = geom_struct.c1; Lf = geom_struct.Lf; Lw = geom_struct.Lw; numero_points = geom_struct.numero_points;
    x_local_ala = geom_struct.x_local_ala; linea_larg_posterior = geom_struct.linea_larg_posterior;
    linea_centro = geom_struct.linea_centro; pendiente_larg_anterior = geom_struct.pendiente_larg_anterior;
    const_larg_anterior = geom_struct.const_larg_anterior; pendiente_perp = geom_struct.pendiente_perp;
    alfa = geom_struct.alfa_larg_posterior; distancia_entre_costillas = datosEstructural.distancia_entre_costillas;
    n_val = datosEstructural.n; MTOW = avion.MTOW;
    Dist_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje;
    Dist_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje;

    %----- TRIANGULAR ZONE -----
    y_start_tri = c1 * Dist_posterior; y_end_tri = Dist_anterior * c1; delta_y = distancia_entre_costillas / sin(alfa);
    y_tri_all = y_start_tri : -delta_y : y_end_tri;
    
    if numel(y_tri_all) < 2
        num_costillas_tri = 0; costillas_tri = []; coord_aero_tri = []; l_tri = [];
    else
        y_tri = y_tri_all(2:end); num_costillas_tri = numel(y_tri);
        x_tri = Lf * ones(num_costillas_tri, 1); costillas_tri = zeros(num_costillas_tri, 2, numero_points);
        coord_aero_tri = zeros(num_costillas_tri, 2);
        
        for i = 1:num_costillas_tri
            b_tri = y_tri(i) - pendiente_perp * Lf;
            x_int = (b_tri - const_larg_anterior) / (pendiente_larg_anterior - pendiente_perp);
            y_int = pendiente_larg_anterior * x_int + const_larg_anterior;
            costillas_tri(i,1,:) = linspace(Lf, x_int, numero_points);
            costillas_tri(i,2,:) = linspace(y_tri(i), y_int, numero_points);
            x_intersect = (geom_struct.const_centro - b_tri) / (pendiente_perp - geom_struct.pendiente_centro);
            y_intersect = geom_struct.pendiente_centro * x_intersect + geom_struct.const_centro;
            coord_aero_tri(i,:) = [x_intersect, y_intersect];
        end
        
        num_mid_tri = num_costillas_tri - 1; coord_aero_tri_mid = zeros(num_mid_tri, 2); l_tri = zeros(num_mid_tri, 1);
        for i = 1:num_mid_tri
            coord_aero_tri_mid(i,:) = (coord_aero_tri(i,:) + coord_aero_tri(i+1,:)) / 2;
            l_tri(i) = spline(x_local_ala, cargas.schrenk, coord_aero_tri_mid(i,1)) * n_val * MTOW * 2 / (Lw^2);
        end
    end
    %----- NORMAL ZONE -----
    % Determine the starting point for normal ribs.
    if num_costillas_tri > 0
        y_threshold = y_tri(end);
    else
        y_threshold = -Inf;
    end
    x_candidates = linspace(Lf, Lf+Lw, 1000);
    y_candidates = interp1(x_local_ala, linea_larg_posterior, x_candidates, 'spline');
    idx_start = find(y_candidates > y_threshold, 1, 'first');
    if isempty(idx_start)
        x_normal_start = Lf + 1e-6;
    else
        x_normal_start = x_candidates(idx_start);
    end
    normal_length = (Lf+Lw) - x_normal_start;
    num_costillas_norm = floor(normal_length / (distancia_entre_costillas * cos(alfa)));
    

    % %----- NORMAL ZONE -----
    % y_threshold = (num_costillas_tri > 0) * c1 * Dist_posterior + (num_costillas_tri == 0) * -Inf;
    % x_candidates = linspace(Lf, Lf+Lw, 1000);
    % y_candidates = interp1(x_local_ala, linea_larg_posterior, x_candidates, 'spline');
    % idx_start = find(y_candidates > y_threshold, 1, 'first');
    % x_normal_start = Lf + 1e-6 * isempty(idx_start) + (idx_start > 0) * x_candidates(idx_start);
    % normal_length = (Lf+Lw) - x_normal_start; num_costillas_norm = floor(normal_length / (distancia_entre_costillas * cos(alfa)));
    % 
    if num_costillas_norm > 0
        x_norm = x_normal_start + (0:(num_costillas_norm-1))' * distancia_entre_costillas * cos(alfa);
        y_norm = interp1(x_local_ala, linea_larg_posterior, x_norm, 'spline');
        costillas_norm = zeros(num_costillas_norm, 2, numero_points); coord_aero_norm = zeros(num_costillas_norm, 2);
        
        for i = 1:num_costillas_norm
            b_norm = y_norm(i) - pendiente_perp * x_norm(i);
            x_int = (b_norm - const_larg_anterior) / (pendiente_larg_anterior - pendiente_perp);
            y_int = pendiente_larg_anterior * x_int + const_larg_anterior;
            costillas_norm(i,1,:) = linspace(x_norm(i), x_int, numero_points);
            costillas_norm(i,2,:) = linspace(y_norm(i), y_int, numero_points);
            x_intersect = (geom_struct.const_centro - b_norm) / (pendiente_perp - geom_struct.pendiente_centro);
            y_intersect = geom_struct.pendiente_centro * x_intersect + geom_struct.const_centro;
            coord_aero_norm(i,:) = [x_intersect, y_intersect];
        end
        
        num_mid_norm = num_costillas_norm - 1; coord_aero_norm_mid = zeros(num_mid_norm, 2); l_norm = zeros(num_mid_norm, 1);
        for i = 1:num_mid_norm
            coord_aero_norm_mid(i,:) = (coord_aero_norm(i,:) + coord_aero_norm(i+1,:)) / 2;
            l_norm(i) = spline(x_local_ala, cargas.schrenk, coord_aero_norm_mid(i,1)) * n_val * MTOW * 2 / (Lw^2);
        end
    else
        costillas_norm = []; coord_aero_norm = []; l_norm = [];
    end

    %----- COMBINE ZONES -----
    if ~isempty(costillas_norm)
        costillas = [costillas_tri; costillas_norm];
        combined_aero = [coord_aero_tri; coord_aero_norm];
        l_combined = [l_tri; l_norm];
    else
        costillas = costillas_tri; combined_aero = coord_aero_tri; l_combined = l_tri;
    end
    num_costillas_total = size(costillas,1);
    
    if num_costillas_total > 1
        costilla_medios = zeros(num_costillas_total-1, 2);
        for i = 1:(num_costillas_total-1)
            costilla_medios(i,:) = (combined_aero(i,:) + combined_aero(i+1,:)) / 2;
        end
    else
        costilla_medios = [];
    end

    load_data = l_combined;
    costilla_costilla_medio = zeros(num_costillas_total*2 - 1, 4);
    idx = 1;
    for i = 1:(num_costillas_total-1)
        pt_start = [squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1))];
        pt_end = [squeeze(costillas(i,1,end)), squeeze(costillas(i,2,end))];
        costilla_costilla_medio(idx,:) = [pt_start, pt_end]; idx = idx + 1;
        pt_mid = ([squeeze(costillas(i,1,1)), squeeze(costillas(i,2,1))] + [squeeze(costillas(i+1,1,1)), squeeze(costillas(i+1,2,1))]) / 2;
        costilla_costilla_medio(idx,:) = [pt_mid, pt_mid]; idx = idx + 1;
    end
    pt_last = [squeeze(costillas(end,1,1)), squeeze(costillas(end,2,1))];
    pt_last_end = [squeeze(costillas(end,1,end)), squeeze(costillas(end,2,end))];
    costilla_costilla_medio(end,:) = [pt_last, pt_last_end];

    % Return all outputs in a struct
    results = struct();
    results.costillas = costillas;
    results.costilla_medios = costilla_medios;
    results.load_data = load_data;
    results.num_costillas_total = num_costillas_total;
    results.num_costillas_tri = num_costillas_tri;
    results.costilla_costilla_medio = costilla_costilla_medio;

end
