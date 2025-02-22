%% Reparto de Fuerzas Function
function P = reparto_de_fuerzas(A, sigma, n, materialType, pitch)
    % REPARTO_DE_FUERZAS Computes load distribution between skin, stringers, and spars.
    %
    % Inputs:
    %   A: Struct with all necessary areas (from cajon.m)
    %   sigma: Axial stress (Pa)
    %   n: Number of stringers per skin
    %   materialType: 'metal' or 'composite'
    %   pitch: Distance between stringers (m)
    %
    % Output:
    %   P: Struct containing distributed loads

    % ✅ Compute Resultant Forces (Fixed)
    P.P_RS = sigma * A.Ars; % Upper skin resultant force (N)
    P.P_RI = sigma * A.Ari; % Lower skin resultant force (N)

    % ✅ Compute Axial Stresses (NEW - Fixing Missing Fields)
    P.sigma_RS = P.P_RS / A.Ars; % Upper skin axial stress (Pa)
    P.sigma_RI = P.P_RI / A.Ari; % Lower skin axial stress (Pa)

    if strcmp(materialType, 'metal')
        % ✅ Metal (Effective Width Applied)
        A.A_LSe = A.Als + 30 * A.Ass; % Effective stringer area (top)
        A.A_CSe = A.Acse + 15 * A.Ass; % Effective spar cap area (top)
    else
        % ✅ Composite (No Effective Width Adjustment)
        A.A_LSe = A.Als;
        A.A_CSe = A.Acse;
    end

    % ✅ Load Distribution for Upper Skin
    P.P_CSe = P.P_RS * (2 * A.A_CSe / (2 * A.A_CSe + n * A.A_LSe));
    P.P_LSe = P.P_RS * (n * A.A_LSe / (2 * A.A_CSe + n * A.A_LSe));
    
    % ✅ Stresses in Upper Skin Components
    P.sigma_CS = P.P_CSe / (2 * A.A_CSe);
    P.sigma_LS = P.P_LSe / (n * A.A_LSe);

    % ✅ Load Distribution for Lower Skin
    A.A_Si = pitch * A.Asi; % Effective lower skin area
    P.P_Ci = P.P_RI * (2 * A.Aci / (2 * A.Aci + n * A.Ali + (n + 1) * A.Asi));
    P.P_Li = P.P_RI * (n * A.Ali / (2 * A.Aci + n * A.Ali + (n + 1) * A.Asi));
    P.P_Si = P.P_RI * ((n + 1) * A.Asi / (2 * A.Aci + n * A.Ali + (n + 1) * A.Asi));

    % ✅ Stresses in Lower Skin Components
    P.sigma_Ci = P.P_Ci / (2 * A.Aci);
    P.sigma_Li = P.P_Li / (n * A.Ali);
    P.sigma_Si = P.P_Si / ((n + 1) * A.Asi);
end
