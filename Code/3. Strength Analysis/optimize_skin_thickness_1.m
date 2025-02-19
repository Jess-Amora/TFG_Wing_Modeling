function t = optimize_skin_thickness(My, material, SF)
    % Computes required skin thickness based on My
    
    % ✅ Ensure My is positive (taking absolute value)
    My = abs(My);

    % ✅ Compute Allowable Stress (with Safety Factor)
    sigma_allow = material.sigma_lim / SF;

    % ✅ Compute Minimum Required Thickness
    t_min = sqrt(My / (sigma_allow * 10)); 

    % ✅ Ensure Minimum Practical Thickness (2mm)
    t = max(real(t_min), 0.002);  % Ignore imaginary parts
    
    % fprintf('🔹 Estimated Skin Thickness: %.6f m\n', t);
end
