function t = optimize_skin_thickness(My, material)
    % Estimates skin thickness based on bending moment My and material properties

    sigma_allow = material.yield / 1.5;  % Apply safety factor
    t_min = sqrt(My / (sigma_allow * 10)); % Basic estimation formula
    t = max(t_min, 0.002);  % Ensure minimum practical thickness (2mm)
end
