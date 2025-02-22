%% Fatigue Analysis Function (Simplified)
function fatigue_life = calcular_fatiga(stress, materialType, num_cycles)
    % CALCULAR_FATIGA Estimates fatigue life using S-N curves and Miner’s Rule.
    %
    % Inputs:
    %   stress: Applied stress amplitude (MPa)
    %   materialType: 'metal' or 'composite'
    %   num_cycles: Number of load cycles
    %
    % Outputs:
    %   fatigue_life: Estimated fatigue life (cycles until failure)

    %% Define S-N Curve Parameters
    if strcmp(materialType, 'metal')
        % Metal S-N curve approximation (Based on Aluminum 2024-T3)
        sigma_f = 300; % Fatigue strength at 1 cycle (MPa)
        b = -0.1;      % Slope of the S-N curve
    else
        % Composite materials have different fatigue behaviors
        sigma_f = 250; % Approximate fatigue strength for composites
        b = -0.15;     % Slope of S-N curve (steeper for composites)
    end

    % Calculate number of cycles to failure using Basquin’s equation
    N_f = 10.^((log10(sigma_f) - log10(stress)) / b);

    % Apply Miner’s Rule if num_cycles is provided
    if nargin == 3
        damage = num_cycles / N_f; % Damage accumulation
        if damage >= 1
            fprintf('⚠️ Fatigue failure expected after %.2f cycles!\n', num_cycles);
        else
            fprintf('✅ Structure should survive %.2f cycles (Damage = %.3f)\n', num_cycles, damage);
        end
        fatigue_life = damage; % Return damage fraction if cycles are given
    else
        fatigue_life = N_f; % Return estimated fatigue life (in cycles)
    end
end
