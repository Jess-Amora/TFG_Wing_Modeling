function tl = optimize_spars(Vy, T, material, b)
    % =============================================================
    % 📌 Function: optimize_spars (Refined Version)
    % =============================================================
    % Computes spar thickness based on shear and torsion loads.
    %
    % ✅ Inputs:
    % - Vy: Shear force (N)
    % - T: Torsional moment (Nm)
    % - material: Struct containing material properties (E, sigma_lim, sigma_cort)
    % - b: Spar width (m)
    %
    % ✅ Outputs:
    % - tl: Required spar thickness (m)
    % =============================================================

    % ✅ Debug: Print input values for validation
    fprintf('🔍 Debug: Vy = %.2f N, T = %.2f Nm, b = %.3f m\n', Vy, T, b);

    % ✅ Convert Shear Strength to Pascals (Ensure Correct Units)
    tau_allow = (material.sigma_cort * 1e6) / 1.5;  % Apply safety factor

    % ✅ Ensure `b` is reasonable
    if b < 0.2  % Minimum reasonable spar width for large aircraft
        warning('⚠️ Spar width is too small (b = %.4f m). Adjusting...', b);
        b = 0.4;  % Set minimum width to 40 cm
    end

    % ✅ Compute Thickness from Shear Load
    tl_min = abs(Vy) / (tau_allow * b);  

    % ✅ Compute Thickness from Torsion
    tl_torsion = abs(T) / (tau_allow * (b^2));  

    % ✅ Apply Constraints and Ensure a Minimum Thickness (5mm)
    tl = max([tl_min, tl_torsion, 0.005]);  

    % ✅ Debug Output
    fprintf('🔹 Computed Spar Thickness: %.6f m\n', tl);
end
