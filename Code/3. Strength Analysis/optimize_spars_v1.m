function tl = optimize_spars(Vy, T, material, b)
    % =============================================================
    % 📌 Function: optimize_spars (Fixed Version)
    % =============================================================
    % Estimates spar thickness based on shear and torsion loads.
    %
    % ✅ Inputs:
    % - Vy: Shear force (N)
    % - T: Torsional moment (Nm)
    % - material: Struct containing material properties (E, sigma_lim, sigma_cort)
    % - b: Spar width (m)
    %
    % ✅ Outputs:
    % - tl: Required spar thickness (m)
    %
    % =============================================================

    % ✅ Allowable shear stress (Use sigma_cort instead of sigma_lim / 2)
    tau_allow = material.sigma_cort / 1.5;  % Apply safety factor to shear strength

    % ✅ Compute Minimum Thickness from Shear Stress
    tl_min = abs(Vy) / (tau_allow * b);  % Shear stress formula

    % ✅ Compute Minimum Thickness from Torsion
    tl_torsion = abs(T) / (tau_allow * b^2);  % Torsional resistance (approximation)

    % ✅ Compute Final Thickness with a Minimum of 5 mm
    tl = max([tl_min, tl_torsion, 0.005]);  % Ensure minimum thickness (5mm)

    % ✅ Debug Output
    fprintf('🔹 Computed Spar Thickness: %.6f m\n', tl);
end
