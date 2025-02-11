function structure = pre_dimensioning(My, Vy, T, material)
    % =============================================================
    % 📌 Function: pre_dimensioning
    % =============================================================
    % Computes the suggested structural dimensions for the wing box.
    % This function sizes skins, stringers, and spars based on applied loads.
    %
    % ✅ Inputs:
    % - My: Bending moment (Nm)
    % - Vy: Shear force (N)
    % - T: Torsional moment (Nm)
    % - material: Struct containing material properties (E, yield stress, etc.)
    %
    % ✅ Outputs:
    % - structure: Struct containing suggested dimensions for:
    %       - Skin thickness (tss, tsi)
    %       - Stringer cross-section area (A_Ls, A_Li)
    %       - Spar thickness (tl)
    %
    % =============================================================

    fprintf('🔹 Starting Pre-Dimensioning Process...\n');

    %% 1️⃣ Estimate Skin Thickness (Upper & Lower Skins)
    % Assumption: Thickness is proportional to bending moment My
    structure.tss = optimize_skin_thickness(My, material);
    structure.tsi = structure.tss;  % Assume symmetry for now
    fprintf('✅ Suggested Skin Thickness: %.6f m\n', structure.tss);

    %% 2️⃣ Compute Stringer Area (Upper & Lower)
    % Assumption: Stringers carry compression & tension from bending
    structure.A_Ls = optimize_stringers(My, structure.tss, material);
    structure.A_Li = structure.A_Ls;  % Assume symmetry
    fprintf('✅ Suggested Stringer Area: %.6f m²\n', structure.A_Ls);

    %% 3️⃣ Compute Spar Thickness (Based on Shear and Torsion)
    structure.tl = optimize_spars(Vy, T, material);
    fprintf('✅ Suggested Spar Thickness: %.6f m\n', structure.tl);

    fprintf('🔹 Pre-Dimensioning Complete!\n');
end
