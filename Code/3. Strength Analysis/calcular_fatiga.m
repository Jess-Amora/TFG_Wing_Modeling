%% Fatigue Analysis Function (Improved)
function fatigue_life = calcular_fatiga(stress, materialType, num_cycles)
    % CALCULAR_FATIGA Estimates fatigue life using S-N curves and Miner’s Rule.
    %
    % Inputs:
    %   stress: Applied stress amplitude (MPa) [Can be a vector]
    %   materialType: 'metal' or 'composite'
    %   num_cycles: Number of load cycles
    %
    % Outputs:
    %   fatigue_life: Estimated fatigue life (cycles until failure)

    %% 🔹 Define S-N Curve Parameters
    if strcmp(materialType, 'metal')
        sigma_f = 300; % Fatigue strength at 1 cycle (MPa)
        b = -0.1;      % Slope of the S-N curve
    else
        sigma_f = 250; % Approximate fatigue strength for composites
        b = -0.15;     % Steeper slope for composites
    end

    %% 🔹 **Ensure stress is valid**
    min_stress = 1e-3; % Set a minimum stress to avoid log10(0)
    stress = max(abs(stress), min_stress); % Use absolute values (compressive/tensile)

    %% 🔹 **Compute Number of Cycles to Failure**
    N_f = 10.^((log10(sigma_f) - log10(stress)) / b); % Basquin’s equation

    %% 🔹 **Apply Miner’s Rule**
    if nargin == 3
        damage = num_cycles ./ N_f; % Compute damage ratio (array-wise)
        damage(damage > 1e6) = 1;    % Cap extreme damage values at 1

        % 🔹 **Display only one summary message**
        max_damage = max(damage); % Worst-case damage
        if max_damage >= 1
            fprintf('⚠️ Fatigue failure expected after %.2f cycles!\n', num_cycles);
        else
            fprintf('✅ Structure should survive %.2f cycles (Max Damage = %.3f)\n', num_cycles, max_damage);
        end
        fatigue_life = damage; % Return damage array
    else
        fatigue_life = N_f; % Return estimated fatigue life in cycles
    end
end
