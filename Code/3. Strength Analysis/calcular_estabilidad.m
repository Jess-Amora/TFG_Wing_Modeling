%% Stability Analysis Function (Buckling)
function buckling_safety = calcular_estabilidad(cajon_struct, material, applied_load)
    % CALCULAR_ESTABILIDAD Computes buckling safety factor.
    %
    % Inputs:
    %   cajon_struct: Struct with computed structural properties
    %   material: Struct with material properties
    %   applied_load: Applied compressive load (N) [Can be an array]
    %
    % Outputs:
    %   buckling_safety: Safety factor for buckling (Should be > 1)

    % ✅ Extract geometry from `cajon_struct`
    geometry.L = cajon_struct.C;  % Wing box chord length
    geometry.t = cajon_struct.tss; % Skin thickness
    geometry.b = cajon_struct.H;   % Panel height
    geometry.I = cajon_struct.I;   % Moment of inertia

    % ✅ Ensure Required Fields Exist
    required_fields = {'L', 't', 'b', 'I'};
    for i = 1:length(required_fields)
        if ~isfield(geometry, required_fields{i})
            error('❌ Missing field: %s in geometry struct', required_fields{i});
        end
    end

    % ✅ Compute Euler Buckling Load (Must be a scalar)
    K = 1; % Fixed-Fixed boundary condition
    P_crit = (pi^2 * material.E * geometry.I) / (K * geometry.L)^2;

    % ✅ Compute Panel Buckling Load (Scalar)
    D = (material.E * geometry.t^3) / (12 * (1 - material.nu^2)); % Flexural rigidity
    sigma_cr = (pi^2 * D) / (geometry.b^2 * geometry.t); % Critical stress

    % ✅ Ensure `applied_load` is a scalar (if it's an array, use max value)
    if ~isscalar(applied_load)
        applied_load = max(abs(applied_load)); % Take the worst-case applied load
    end

    % ✅ Compute Safety Factor (Avoid division by zero)
    if applied_load == 0
        buckling_safety = Inf; % No load, so infinite safety factor
    else
        buckling_safety = P_crit / applied_load;
    end

    % ✅ Display Results
    fprintf('\n🔍 Stability Analysis:\n');
    fprintf('  - Euler Buckling Load: %.2f N\n', P_crit);
    fprintf('  - Panel Buckling Stress: %.2f MPa\n', sigma_cr);
    fprintf('  - Safety Factor: %.2f (Should be > 1)\n', buckling_safety);
end
