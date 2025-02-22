function [avion, cargas, results] = adjust_k_sust(ala, avion)
    % adjust_k_sust iteratively adjusts the structural scaling factor k_sust so that 
    % the computed lift-to-weight ratio equals 1.
    %
    % Inputs:
    %   ala   - structure containing wing data including:
    %           - coord_aerodinamica_costillas_punto_medio (rib midpoints)
    %           - numero_costillas
    %           - (other fields used by calculate_lift_distribution)
    %   avion - structure containing aircraft parameters (MTOW, n, etc.) and
    %           a nested field datosEstructural with k_sust_a350_1000.
    %
    % Outputs:
    %   avion   - updated avion structure with adjusted k_sust in datosEstructural.
    %   cargas  - structure from schrenk_1 with the adjusted load distribution.
    %   results - structure from calculate_lift_distribution containing:
    %             l, L, x_L, y_L, and cociente_L_W_inicial.
    
    % Convergence parameters
    tol      = 1e-6;  % tolerance for the lift-to-weight ratio convergence
    max_iter = 50;    % maximum number of iterations allowed
    iter     = 0;
    
    % Initial computation of loads using current k_sust
    cargas  = schrenk_1(avion);
    results = calculate_lift_distribution(ala, avion, cargas);
    
    % Iteratively adjust k_sust until the lift-to-weight ratio converges to 1
    while abs(results.cociente_L_W_inicial - 1) > tol && iter < max_iter
        iter = iter + 1;
        
        % Compute scaling factor from the current lift-to-weight ratio.
        % Since l_cuerda = k_sust * c, k_sust scales linearly with the chord-based load.
        scale_factor = 1 / results.cociente_L_W_inicial;
        
        % Update k_sust in the avion structure.
        avion.datosEstructural.k_sust_a350_1000 = avion.datosEstructural.k_sust_a350_1000 * scale_factor;
        
        % Recalculate the load distribution with the new k_sust.
        cargas  = schrenk_1(avion);
        results = calculate_lift_distribution(ala, avion, cargas);
    end
    
    if iter == max_iter
        warning('adjust_k_sust: Maximum iterations reached without convergence.');
    else
        fprintf('adjust_k_sust: Converged in %d iterations.\n', iter);
    end
end
