function [avion, cargas, results] = adjust_k_sust_v1(ala, avion)
    % adjust_k_sust iteratively adjusts k_sust so that the lift-to-weight ratio = 1.
    %
    % Inputs:
    %   - ala   - structure containing wing data
    %   - avion - structure containing aircraft parameters
    %
    % Outputs:
    %   - avion   - updated with adjusted k_sust
    %   - cargas  - updated load distribution
    %   - results - final computed forces

    % Convergence parameters
    tol = 1e-6;  
    max_iter = 50;  
    iter = 0;

    % Initial computation of loads using current k_sust
    cargas  = schrenk_1(avion);
    results = calculate_final_forces(ala, avion, cargas);

    % Iteratively adjust k_sust until the lift-to-weight ratio converges to 1
    while abs(results.total_lift_required - sum(results.L)) > tol && iter < max_iter
        iter = iter + 1;
        
        % Compute scaling factor
        scale_factor = results.total_lift_required / sum(results.L);
        
        % Update k_sust
        avion.datosEstructural.k_sust_a350_1000 = avion.datosEstructural.k_sust_a350_1000 * scale_factor;
        
        % Recalculate load distribution
        cargas  = schrenk_1(avion);
        results = calculate_final_forces(ala, avion, cargas);
    end
    
    if iter == max_iter
        warning('adjust_k_sust: Maximum iterations reached without convergence.');
    else
        fprintf('adjust_k_sust: Converged in %d iterations.\n', iter);
    end
end
