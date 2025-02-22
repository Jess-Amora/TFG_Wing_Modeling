function [index_larguerillos_anterior, index_counter_quitar_nodos_larguerillos_menor_Lf, intersecciones_costillas_larguerillos] = analyze_larguerillos_v1(...
    larguerillos, nodos_posterior, nodos_anterior, costilla_costilla_medio, Lf, linea_larg_anterior, avion, numero_costillas, numero_larguerillos_costilla_final)
% ANALYZE_LARGUERILLOS_V0 Analyzes stringer intersections and removes out‐of-bound ones.
%
%   This function examines the stringers (larguerillos) to:
%       - Determine, for each stringer, the index of the last node in the anterior
%         edge (nodos_anterior) that is valid based on the stringer’s endpoint.
%       - Compute intersections between the stringer “start points” and the rib
%         connection lines (costilla_costilla_medio).
%       - Count, for each stringer, how many intersections occur to the left of the
%         fuselage (x < Lf) or to the right of the front spar.
%
%   Inputs:
%       larguerillos               - 3D array of stringer coordinates (N x 2 x num_points)
%       nodos_posterior            - Node coordinates from the posterior edge (from ribs)
%       nodos_anterior             - Node coordinates from the anterior edge (from ribs)
%       costilla_costilla_medio    - Matrix of endpoints and midpoints between ribs (M x 4)
%       Lf                         - Fuselage half-length (starting from mid fuselage)
%       linea_larg_anterior        - Front spar line (vector of y-values corresponding to x_local_ala)
%       avion                      - Aircraft data (contains x_local_ala and geometry info)
%       numero_costillas           - Total number of ribs (costillas)
%       numero_larguerillos_costilla_final - Number of stringers associated with the rib domain
%
%   Outputs:
%       index_larguerillos_anterior                - 1 x N array of intersection indices per stringer.
%       index_counter_quitar_nodos_larguerillos_menor_Lf - N x 1 array counting intersections
%                                                        to remove (left of Lf or right of front spar).
%       intersecciones_costillas_larguerillos      - Intersection points array (N x numero_costillas x 2)
%
    %% Creando los nodos en los largueros anterior y posterior
    % Nodos largueros
    nodos_posterior = zeros(3,(numero_costillas*2)-1); % Los nodos en el borde de salida que son numero_costillas (costillas) + numero_costillas-1 (punto medio)
    nodos_anterior = zeros(3,(numero_costillas*2)-1);
    nodos_posterior = interleave_matrices(costillas(:,:,1)', puntos_medio_larguero_posterior_ala');
    nodos_anterior = interleave_matrices(costillas(:,:,end)', puntos_medio_larguero_anterior_ala');
    
    % Total number of stringers (larguerillos)
    numero_larguerillos_total = size(larguerillos, 1);
    
    % Initialize index for each stringer using the total number of posterior nodes.
    index_larguerillos_anterior = size(nodos_posterior, 2) * ones(1, numero_larguerillos_total);
    
    % For each stringer beyond the rib-based domain, find the last node in the anterior edge
    % that is less than or equal to the stringer’s endpoint.
    for i = numero_larguerillos_costilla_final+1 : numero_larguerillos_total
        endpoint = squeeze(larguerillos(i, :, end))';  % [x, y] endpoint of the stringer
        indices = find(nodos_anterior(1, :) <= endpoint(1) & nodos_anterior(2, :) <= endpoint(2));
        if ~isempty(indices)
            index_larguerillos_anterior(i) = max(indices);
        else
            index_larguerillos_anterior(i) = -1; % No valid connection found.
        end
    end
    
    % Compute the posterior stringer slope and its perpendicular.
    % (We assume these are not directly provided; so derive from the geometry.)
    x_local_ala = avion.coordenadas.x_local_ala;
    linea_larg_posterior = avion.geometria.linea_larg_posterior; % assumed available
    Lw = avion.geometria.Lw;
    pendiente_larguero_posterior = (linea_larg_posterior(end) - linea_larg_posterior(1)) / Lw;
    tol = 1e-8;
    if abs(pendiente_larguero_posterior) < tol
        pendiente_perpendicular_larguero_posterior = Inf;
    else
        pendiente_perpendicular_larguero_posterior = -1 / pendiente_larguero_posterior;
    end
    
    % Compute intersections between the stringers (using their first slice) and the rib
    % connection endpoints (first two columns of costilla_costilla_medio).
    intersecciones_costillas_larguerillos = cortes_de_dos_funciones_lineales_v3( ...
        squeeze(larguerillos(:,:,1)), pendiente_larguero_posterior, ...
        costilla_costilla_medio(:,1:2), pendiente_perpendicular_larguero_posterior);
    
    % Define the x-coordinate of the front spar end.
    % Here we assume the anterior spar is defined by the x-coordinates in x_local_ala.
    front_spar_x_end = max(x_local_ala);
    
    % For each stringer, count the intersections that are out-of-bound.
    % An intersection is considered out-of-bound if its x-coordinate is
    %   (a) less than Lf (i.e. to the left of the fuselage) OR
    %   (b) greater than the front spar end.
    index_counter_quitar_nodos_larguerillos_menor_Lf = zeros(numero_larguerillos_total, 1);
    
    for i = 1:numero_larguerillos_total
        counter = 0;
        for j = 1:numero_costillas
            x_int = intersecciones_costillas_larguerillos(i, j, 1);
            if x_int < Lf || x_int > front_spar_x_end
                counter = counter + 1;
            end
        end
        index_counter_quitar_nodos_larguerillos_menor_Lf(i) = counter;
    end
end
