function spar_nodes = generate_spar_nodes(costillas)
%GENERATE_SPAR_NODES Generates the nodes along the anterior and posterior spars.
%
%   Inputs:
%       costillas                        - Array with rib coordinates.
%       puntos_medio_larguero_posterior_ala - Midpoints along the posterior spar.
%       puntos_medio_larguero_anterior_ala  - Midpoints along the anterior spar.
%
%   Output:
%       spar_nodes - Struct containing:
%                    .nodos_posterior (posterior spar nodes)
%                    .nodos_anterior  (anterior spar nodes)
%
    % % Creando las líneas en los larguer
    % puntos medio
    puntos_medio_larguero_posterior_ala = zeros(numero_costillas-1,2);
    puntos_medio_larguero_anterior_ala = zeros(numero_costillas-1,2);

    for i = 2:numero_costillas
        puntos_medio_larguero_posterior_ala(i-1,:) = (costillas(i,:,1)+costillas(i-1,:,1))/2;
        puntos_medio_larguero_anterior_ala(i-1,:) = (costillas(i,:,end)+costillas(i-1,:,end))/2;
    end

    % Calculate the number of ribs (costillas)
    numero_costillas = size(costillas, 1);
    
    % Preallocate arrays for spar nodes
    nodos_posterior = zeros(3, (numero_costillas * 2) - 1); % Posterior spar nodes
    nodos_anterior = zeros(3, (numero_costillas * 2) - 1);  % Anterior spar nodes
    
    % Generate nodes using interleave_matrices function
    nodos_posterior = interleave_matrices(costillas(:,:,1)', puntos_medio_larguero_posterior_ala');
    nodos_anterior = interleave_matrices(costillas(:,:,end)', puntos_medio_larguero_anterior_ala');
    
    % Store nodes in a structured output
    spar_nodes = struct();
    spar_nodes.nodos_posterior = nodos_posterior;
    spar_nodes.nodos_anterior = nodos_anterior;

end
