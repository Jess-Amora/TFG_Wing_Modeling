function t = optimize_skin_thickness(My, material, SF)
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

    % ✅ Compute Minimum Required Thickness
    t_min = sqrt(My / (sigma_allow * 10)); % Basic estimation formula

    % ✅ Ensure Minimum Practical Thickness (2 mm)
    t = max(t_min, 0.002);

    fprintf('🔹 Estimated Skin Thickness: %.6f m\n', t);
end
