function structure = pre_dimensioning(My, Vy, T, x, material, SF, geom)
    % =============================================================
    % 📌 Function: pre_dimensioning (Updated to Include SF)
    % =============================================================
    % Computes suggested structural dimensions for the wing box
    % using My(x), Vy(x), and T(x) while considering Safety Factor (SF).
    %
    % ✅ Inputs:
    % - My: Bending moment distribution along the span (vector)
    % - Vy: Shear force distribution along the span (vector)
    % - T: Torsional moment distribution along the span (vector)
    % - x: Spanwise location vector (same size as My, Vy, T)
    % - material: Struct containing material properties (E, yield stress, etc.)
    % - SF: Safety Factor (from `datosEstructural`)
    %
    % ✅ Outputs:
    % - structure: Struct containing suggested dimensions along the span
    %
    % =============================================================

    fprintf('🔹 Starting Pre-Dimensioning Process...\n');

    % Number of spanwise sections
    n_sections = length(x);
    b = geom.b;

    % Initialize vectors for structural parameters
    structure.tss = zeros(n_sections, 1);
    structure.tsi = zeros(n_sections, 1);
    structure.A_Ls = zeros(n_sections, 1);
    structure.A_Li = zeros(n_sections, 1);
    structure.tl = zeros(n_sections, 1);

    % ✅ Compute Allowable Stress Using SF
    sigma_yield = material.sigma_lim;
    sigma_allow = sigma_yield / SF;  % Apply safety factor

    % ✅ Loop through each spanwise section
    for i = 1:n_sections
        fprintf('📌 Computing for x = %.2f m\n', x(i));

        % 1️⃣ Estimate Skin Thickness (Upper & Lower Skins)
        % structure.tss(i) = optimize_skin_thickness(My(i), material, SF);
        structure.tss(i) = optimize_skin_thickness_b(My(i), material, SF,b);
        structure.tsi(i) = structure.tss(i);  % Assume symmetry
        fprintf('✅ Suggested Skin Thickness: %.6f m\n', structure.tss(i));

        % 2️⃣ Compute Stringer Area (Upper & Lower)
        structure.A_Ls(i) = optimize_stringers(My(i), structure.tss(i), material);
        structure.A_Li(i) = structure.A_Ls(i);  % Assume symmetry
        fprintf('✅ Suggested Stringer Area: %.6f m²\n', structure.A_Ls(i));

        % 3️⃣ Compute Spar Thickness (Based on Shear and Torsion)
        structure.tl(i) = optimize_spars(Vy(i), T(i), material);
        fprintf('✅ Suggested Spar Thickness: %.6f m\n', structure.tl(i));
    end

    fprintf('🔹 Pre-Dimensioning Complete for Entire Span!\n');
end
