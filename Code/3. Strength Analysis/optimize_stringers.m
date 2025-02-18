function A_Ls = optimize_stringers_3(My, tss, material)
    % =============================================================
    % 📌 Function: optimize_stringers (Refined Version)
    % =============================================================
    % Computes required stringer area to prevent local buckling.
    %
    % ✅ Inputs:
    % - My: Bending moment (Nm)
    % - tss: Skin thickness (m)
    % - material: Struct containing material properties (E, nu)
    %
    % ✅ Outputs:
    % - A_Ls: Required stringer area (m²)
    %
    % =============================================================

    % ✅ Define Effective Width (Ensure Reasonable Values)
    beff = min(max(20 * tss, 0.05), 0.2);  % Ensure 5 cm min, 20 cm max

    % ✅ Compute Critical Stress for Buckling
    sigma_cr = (pi^2 * material.E) / (12 * (1 - material.nu^2)) * (tss ./ beff).^2;

    % ✅ Ensure sigma_cr is not unrealistically high
    sigma_cr = min(sigma_cr, 0.8 * material.sigma_lim);  % Limit to 80% of yield strength

    % ✅ Compute Required Stringer Load
    N_required = abs(My) ./ (beff / 2); 

    % ✅ Compute Required Stringer Area
    A_Ls = max(N_required ./ sigma_cr, 0.0008);  % Ensure minimum of 800 mm²

    % ✅ Apply Upper Limit (Max 0.0025 m²)
    A_Ls = min(A_Ls, 0.0025);  

    fprintf('🔹 Computed Stringer Area: %.6f m²\n', A_Ls);
end
