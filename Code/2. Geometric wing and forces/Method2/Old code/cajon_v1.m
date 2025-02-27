%% Cajón Function (Wing Box Structural Properties)
function [A_total, hcg, I] = cajon(dimensions, materialType, pandeoLocalsuperior)
    % CAJÓN Computes the cross-sectional properties of the wing box.
    %
    % Inputs:
    %   dimensions: Struct with fields:
    %       - H: Box height (m)
    %       - C: Box width (m)
    %       - tss: Upper skin thickness (m)
    %       - tsi: Lower skin thickness (m)
    %       - tl: Spar thickness (m)
    %       - A_larguerillo: Cross-sectional area of one stringer (m²)
    %       - A_cordon: Cross-sectional area of one cordón (m²)
    %       - n: Number of stringers per skin
    %   materialType: 'metal' or 'composite'
    %   pandeoLocalsuperior: Boolean (true/false) for effective width adjustment
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
    A_larguerillo = dimensions.A_larguerillo;  
    A_cordon = dimensions.A_cordon;  
    n = dimensions.n;  

    % ✅ Compute Upper Skin Area (Ars)
    if strcmp(materialType, 'metal')
        Ars = (30 * tss * n) + (15 * tss * 2) + (n * A_larguerillo) + (2 * A_cordon);
    else
        Ars = (tss * C) + (n * A_larguerillo) + (2 * A_cordon);
    end

    % ✅ Compute Lower Skin Area (Ari)
    if strcmp(materialType, 'metal')
        Ari = (30 * tsi * n) + (15 * tsi * 2) + (n * A_larguerillo) + (2 * A_cordon);
    else
        Ari = (tsi * C) + (n * A_larguerillo) + (2 * A_cordon);
    end

    % ✅ Compute Total Area
    A_total = Ars + Ari + (2 * H * tl);

    % ✅ Compute Height of Center of Gravity (hcg)
    hcg = ((Ars * H) + ((2 * H * tl) * (H / 2))) / A_total;

    % ✅ Compute Moment of Inertia (I)
    I = (2 * ((1/12) * H^3 * tl + (H * tl * (hcg - H/2)^2))) + (Ars * (H - hcg)^2) + (Ari * hcg^2);

end
