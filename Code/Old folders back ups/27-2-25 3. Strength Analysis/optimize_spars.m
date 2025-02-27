function tl = optimize_spars(Vy, T, material)
    % Estimates spar thickness based on shear and torsion

    tau_allow = material.sigma_lim / 2.0;  % Conservative shear stress limit
    tl_min = Vy / (tau_allow * 5);  % Basic shear stress formula
    tl_torsion = T / (tau_allow * 10);  % Torsional constraint
    tl = max([tl_min, tl_torsion, 0.005]);  % Ensure minimum thickness (5mm)
end
