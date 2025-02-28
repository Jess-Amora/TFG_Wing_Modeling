function [avion, cargas, results] = adjust_k_sust_final_forces(ala, avion)
    % adjust_k_sust_final_forces iteratively adjusts the structural scaling factor
    % k_sust (stored in avion.datosEstructural.k_sust_a350_1000) so that the 
    % aerodynamic forces computed in calculate_final_forces match the overall 
    % weight that the wing must lift.
    %
    % Inputs:
    %   ala   - structure containing wing geometry and rib data (including 
    %           coord_aerodinamica_costillas_punto_medio, numero_costillas, etc.)
    %   avion - structure with aircraft parameters (MTOW, n, etc.) and a nested
    %           field datosEstructural with k_sust_a350_1000.
    %
    % Outputs:
    %   avion   - updated avion structure with adjusted k_sust.
    %   cargas  - load distribution computed by schrenk_1.
    %   results - structure returned by calculate_final_forces that includes 
    %             the computed aerodynamic forces and the target total lift.
    
    % Set convergence parameters
    tol = 1e-3;         % tolerance for the difference in forces (in Newtons)
    max_iter = 50;      % maximum number of iterations allowed
    iter = 0;
    
    % Initial calculation of load distribution and final forces.
    cargas = schrenk_1(avion);
    results = calculate_final_forces_v1(ala, avion, cargas);
    
    % Compute the total aerodynamic force from the discrete rib intersections.
    % (Sum the forces from both the anterior and posterior sides.)
    total_aero_force = sum(results.R1_A_aero + results.R2_A_aero + ...
                            results.R1_R_aero + results.R2_R_aero);
    total_lift_required = results.total_lift_required;  % n*MTOW/2
    
    % Iteratively adjust k_sust until the computed aerodynamic force matches 
    % the required lift within tolerance.
    while abs(total_aero_force - total_lift_required) > tol && iter < max_iter
        iter = iter + 1;
        
        % Determine scaling factor so that aerodynamic force will increase if too low
        scale_factor = total_lift_required / total_aero_force;
        
        % Update k_sust in the avion structure.
        avion.datosEstructural.k_sust_a350_1000 = avion.datosEstructural.k_sust_a350_1000 * scale_factor;
        
        % Recompute the load distribution and final forces with the updated k_sust.
        cargas = schrenk_1(avion);
        results = calculate_final_forces_v1(ala, avion, cargas);
        
        % Recalculate the total aerodynamic force.
        total_aero_force = sum(results.R1_A_aero + results.R2_A_aero + ...
                                results.R1_R_aero + results.R2_R_aero);
        total_lift_required = results.total_lift_required;
    end
    
    if iter == max_iter
        warning('adjust_k_sust_final_forces: Maximum iterations reached without convergence.');
    else
        fprintf('adjust_k_sust_final_forces: Converged in %d iterations.\n', iter);
    end
end
