function A_Ls = optimize_stringers(My, tss, material)
    % Computes required stringer area to prevent local buckling

    beff = min(30 * tss, 0.2);  % Effective width (limit for buckling)
    sigma_cr = (pi^2 * material.E) / (12 * (1 - material.nu^2)) * (tss / beff)^2;
    N_required = My / (beff / 2);
    A_Ls = N_required / sigma_cr;
end
