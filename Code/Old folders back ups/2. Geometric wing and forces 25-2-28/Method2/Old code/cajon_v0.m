%% Cajón Function
function [A_total, hcg, I] = cajon(dimensions, materialType)
    % CAJÓN Computes the cross-sectional properties of the wing box.
    %
    % Inputs:
    %   dimensions: Struct with fields:
    %       - H: Box height (m)
    %       - C: Box width (m)
    %       - tss: Upper skin thickness (m)
    %       - tsi: Lower skin thickness (m)
    %       - tl: Spar thickness (m)
    %       - Als: Cross-sectional area of one upper stringer (m²)
    %       - Ali: Cross-sectional area of one lower stringer (m²)
    %       - Acls: Cross-sectional area of upper cordon (m²)
    %       - Acli: Cross-sectional area of lower cordon (m²)
    %       - n: Number of stringers per skin
    %   materialType: 'metal' or 'composite'
    %
    % Outputs:
    %   A_total: Total cross-sectional area (m²)
    %   hcg: Height of center of gravity (m)
    %   I: Moment of inertia (m⁴)

    % Extract values from struct
    H = dimensions.H;  
    C = dimensions.C;  
    tss = dimensions.tss;  
    tsi = dimensions.tsi;  
    tl = dimensions.tl;  
    Als = dimensions.Als;  
    Ali = dimensions.Ali;  
    Acls = dimensions.Acls;  
    Acli = dimensions.Acli;  
    n = dimensions.n;  

    % ✅ Compute Upper Skin Area (Ars)  
    if strcmp(materialType, 'metal')
        Ars = 30 * tss * n + 15 * tss * 2 + n * Als + 2 * Acls;
    else  % Composite (no pandeo)
        Ars = tss * C + n * Als + 2 * Acls;
    end  

    % ✅ Compute Lower Skin Area (Ari)  
    Ari = tsi * C + n * Ali + 2 * Acli;  

    % ✅ Compute Total Area  
    A_total = Ars + Ari + (2 * H * tl);  

    % ✅ Compute Height of Center of Gravity (hcg)  
    hcg = (Ars * H + (2 * H^2 / 2 * tl)) / (Ari + Ars + 2 * H * tl);  

    % ✅ Compute Moment of Inertia (I)  
    I = (2 * (1/12 * H^3 * tl + H * tl * (hcg - H/2)^2)) + (Ars * (H - hcg)^2) + (Ari * hcg^2);  

end
