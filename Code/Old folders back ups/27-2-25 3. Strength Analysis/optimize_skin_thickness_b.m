function t = optimize_skin_thickness_b(My, material, SF, b)
    % =============================================================
    % 📌 Function: optimize_skin_thickness (Improved Version)
    % =============================================================
    % Computes the required skin thickness based on bending moment My,
    % material properties, and a safety factor (SF).
    %
    % ✅ Inputs:
    % - My: Bending moment (Nm)
    % - material: Struct containing material properties (E, sigma_lim, etc.)
    % - SF: Safety Factor
    % - b: Panel width (distance between stringers) [meters]
    %
    % ✅ Outputs:
    % - t: Estimated skin thickness (meters)
    %
    % =============================================================

    % ✅ Ensure `material` is a struct
    if ~isstruct(material)
        error('❌ ERROR: `material` is not a struct in optimize_skin_thickness.m');
    end

    % ✅ Ensure `sigma_lim` exists
    if ~isfield(material, 'sigma_lim')
        error('❌ ERROR: `sigma_lim` is missing in `material` struct');
    end

    % ✅ Compute Allowable Stress (with Safety Factor)
    sigma_allow = material.sigma_lim / SF;

    % ✅ Compute Minimum Required Thickness using bending stress formula
    t_min = sqrt(abs(My) / (b * sigma_allow)); % Improved formula

    % ✅ Ensure Minimum Practical Thickness (2 mm)
    t = max(t_min, 0.002);

    fprintf('🔹 Estimated Skin Thickness: %.6f m\n', t);
end
