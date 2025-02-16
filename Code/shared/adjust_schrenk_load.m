function [cargas, results] = adjust_schrenk_load(ala, avion, cargas)
    % adjust_schrenk_load iteratively scales the Schrenk load distribution so
    % that the computed lift-to-weight ratio equals 1.
    %
    % Inputs:
    %   ala    - structure containing wing data including:
    %            - coord_aerodinamica_costillas_punto_medio (rib midpoints)
    %            - numero_costillas
    %            - (other fields used by calculate_lift_distribution)
    %   avion  - structure containing aircraft parameters (MTOW, n, etc.)
    %   cargas - structure output from schrenk_1 containing the initial schrenk load.
    %
    % Outputs:
    %   cargas  - updated structure with the adjusted schrenk load distribution.
    %   results - structure output from calculate_lift_distribution containing:
    %             - l, L, x_L, y_L, cociente_L_W_inicial, etc.
    
    % Set convergence parameters
    tol      = 1e-6;  % tolerance for lift-to-weight ratio convergence
    max_iter = 50;    % maximum number of iterations allowed
    iter     = 0;
    
    % Compute the initial lift distribution
    results = calculate_lift_distribution(ala, avion, cargas);
    
    % Loop until the lift-to-weight ratio is within tolerance of 1
    while abs(results.cociente_L_W_inicial - 1) > tol && iter < max_iter
        iter = iter + 1;
        
        % Compute scaling factor.
        % Because the integrated lift scales linearly with the Schrenk load,
        % we can simply use the inverse of the current ratio to adjust.
        scale_factor = 1 / results.cociente_L_W_inicial;
        
        % Update the Schrenk load distribution by scaling it
        cargas.schrenk = cargas.schrenk * scale_factor;
        
        % Recompute the lift distribution with the new Schrenk load
        results = calculate_lift_distribution(ala, avion, cargas);
    end
    
    if iter == max_iter
        warning('adjust_schrenk_load: Maximum iterations reached without convergence.');
    else
        fprintf('adjust_schrenk_load: Converged in %d iterations.\n', iter);
    end
end
