function structure = pre_dimensioning_graph(My, Vy, T, x, material, SF, geom, datosEstructural, showGraph)
    % =============================================================
    % 📌 Function: pre_dimensioning (Updated to Include Graph)
    % =============================================================
    % Computes suggested structural dimensions for the wing box
    % using My(x), Vy(x), and T(x) while considering Safety Factor (SF).
    %
    % ✅ Inputs:
    % - My: Bending moment distribution along the span (vector)
    % - Vy: Shear force distribution along the span (vector)
    % - T: Torsional moment distribution along the span (vector)
    % - x: Spanwise location vector (same size as My, Vy, T)
    % - material: Struct containing material properties (E, sigma_lim, etc.)
    % - SF: Safety Factor (from `datosEstructural`)
    %
    % ✅ Outputs:
    % - structure: Struct containing suggested dimensions along the span
    %
    % =============================================================

    fprintf('🔹 Starting Pre-Dimensioning Process...\n');

    % Number of spanwise sections
    n_sections = length(x);
    b_spar = datosEstructural.distancia_entre_costillas;

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
        % 1️⃣ Estimate Skin Thickness (Upper & Lower Skins)
        structure.tss(i) = optimize_skin_thickness_1(My(i), material, SF);
        % structure.tss(i) = optimize_skin_thickness_b(My(i), material, SF,b);
        structure.tsi(i) = structure.tss(i);  % Assume symmetry

        % 2️⃣ Compute Stringer Area (Upper & Lower)
        structure.A_Ls(i) = optimize_stringers(My(i), structure.tss(i), material);
        structure.A_Li(i) = structure.A_Ls(i);  % Assume symmetry

        % 3️⃣ Compute Spar Thickness (Based on Shear and Torsion)
        structure.tl(i) = optimize_spars(Vy(i), T(i), material);
        % structure.tl(i) = optimize_spars_v1(Vy(i), T(i), material, b_spar);
        % structure.tl(i) = optimize_spars_v2(Vy(i), T(i), material, b_spar);
    end

    fprintf('🔹 Pre-Dimensioning Complete for Entire Span!\n');
    
    if showGraph
    % ✅ Plot Results for Better Visualization
    figure;
    
    % 🔹 Subplot 1: Skin Thickness
    subplot(3,1,1);
    plot(x, structure.tss, '-b', 'LineWidth', 2);
    hold on;
    plot(x, structure.tsi, '--r', 'LineWidth', 2);
    xlabel('Spanwise Position x (m)');
    ylabel('Skin Thickness t (m)');
    legend('Upper Skin (tss)', 'Lower Skin (tsi)');
    title('Skin Thickness Distribution');
    grid on;
    
    % 🔹 Subplot 2: Stringer Area
    subplot(3,1,2);
    plot(x, structure.A_Ls, '-g', 'LineWidth', 2);
    hold on;
    plot(x, structure.A_Li, '--m', 'LineWidth', 2);
    xlabel('Spanwise Position x (m)');
    ylabel('Stringer Area A (m²)');
    legend('Upper Stringer Area (A_Ls)', 'Lower Stringer Area (A_Li)');
    title('Stringer Area Distribution');
    grid on;
    
    % 🔹 Subplot 3: Spar Thickness
    subplot(3,1,3);
    plot(x, structure.tl, '-k', 'LineWidth', 2);
    xlabel('Spanwise Position x (m)');
    ylabel('Spar Thickness t_s (m)');
    title('Spar Thickness Distribution');
    grid on;
    end
    fprintf('✅ Structural Pre-Dimensioning Completed and Saved.\n');
end
