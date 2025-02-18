function A_Ls = optimize_stringers_1(My, tss, material)
    % =============================================================
    % 📌 Function: optimize_stringers (Improved Version)
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

    % ✅ Define Effective Width (Avoid Overly Small Values)
    beff = min(max(30 * tss, 0.05), 0.2);  % 5 cm min, 20 cm max

    % ✅ Compute Critical Stress for Buckling
    sigma_cr = (pi^2 * material.E) / (12 * (1 - material.nu^2)) * (tss ./ beff).^2;

    % ✅ Ensure sigma_cr is not unrealistically high
    sigma_cr = min(sigma_cr, 0.9 * material.sigma_lim);  % Limit to 90% yield strength

    % ✅ Compute Required Stringer Load
    N_required = My ./ (beff / 2);

    % ✅ Compute Required Stringer Area
    A_Ls = max(N_required ./ sigma_cr, 0.001);  % Ensure a minimum of 1 mm²

    fprintf('🔹 Computed Stringer Area: %.6f m²\n', A_Ls);
end
