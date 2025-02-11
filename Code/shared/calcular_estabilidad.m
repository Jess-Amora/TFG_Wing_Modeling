%% Stability Analysis Function (Buckling)
function buckling_safety = calcular_estabilidad(geometry, material, applied_load)
    % ✅ Ensure Required Fields Exist
    required_fields = {'L', 't', 'b', 'I'};
    for i = 1:length(required_fields)
        if ~isfield(geometry, required_fields{i})
            error('Missing field: %s in geometry struct', required_fields{i});
        end
    end

    % Compute Euler Buckling Load
    K = 1; % Fixed-Fixed boundary condition
    P_crit = (pi^2 * material.E * geometry.I) / (K * geometry.L)^2;

    % Compute Panel Buckling Load
    D = (material.E * geometry.t^3) / (12 * (1 - material.nu^2)); % Flexural rigidity
    sigma_cr = (pi^2 * D) / (geometry.b^2 * geometry.t); % Critical stress

    % Compute Safety Factor
    buckling_safety = P_crit / applied_load;
    
    % Display Results
    fprintf('\n🔍 Stability Analysis:\n');
    fprintf('  - Euler Buckling Load: %.2f N\n', P_crit);
    fprintf('  - Panel Buckling Stress: %.2f MPa\n', sigma_cr);
    fprintf('  - Safety Factor: %.2f (Should be > 1)\n', buckling_safety);
end

% %% Stability Analysis Function (Buckling)
% function buckling_safety = calcular_estabilidad(geometry, material, applied_load)
%     % CALCULAR_ESTABILIDAD Computes buckling safety factor.
%     %
%     % Inputs:
%     %   geometry: Struct with geometric properties
%     %       - L: Length of member (m)
%     %       - t: Thickness of plate or skin (m)
%     %       - b: Width of plate (m)
%     %       - I: Moment of inertia (m^4)
%     %   material: Struct with material properties
%     %       - E: Young’s modulus (MPa)
%     %       - v: Poisson’s ratio
%     %   applied_load: Applied compressive load (N)
%     %
%     % Outputs:
%     %   buckling_safety: Safety factor for buckling (Should be > 1)
% 
%     %% Compute Euler Buckling Load
%     K = 1; % Fixed-Fixed boundary condition
%     P_crit = (pi^2 * material.E * geometry.I) / (K * geometry.L)^2;
% 
%     %% Compute Panel Buckling Load
%     D = (material.E * geometry.t^3) / (12 * (1 - material.v^2)); % Flexural rigidity
%     sigma_cr = (pi^2 * D) / (geometry.b^2 * geometry.t); % Critical stress
% 
%     %% Compute Safety Factor
%     buckling_safety = P_crit / applied_load;
% 
%     % Display Results
%     fprintf('\n🔍 Stability Analysis:\n');
%     fprintf('  - Euler Buckling Load: %.2f N\n', P_crit);
%     fprintf('  - Panel Buckling Stress: %.2f MPa\n', sigma_cr);
%     fprintf('  - Safety Factor: %.2f (Should be > 1)\n', buckling_safety);
% end
