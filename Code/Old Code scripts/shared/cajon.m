%% Cajón Function (Wing Box Structural Properties)
function [A, hcg, I] = cajon(dimensions, materialType, pandeoLocalsuperior)
    % Extract values from struct
    H = dimensions.H;  
    C = dimensions.C;  
    tss = dimensions.tss;  
    tsi = dimensions.tsi;  
    tl = dimensions.tl;  
    A_larguerillo = dimensions.A_larguerillo;  
    A_cordon = dimensions.A_cordon;  
    n = dimensions.n;  
    pitch = dimensions.pitch;  

    % ✅ Compute Effective Areas Based on Material Type  
    if strcmp(materialType, 'metal')
        A.Ass = (30 * tss);  
        A.Asi = (30 * tsi);  
        A.Als = A_larguerillo;  
        A.Ali = A_larguerillo;  
        A.Acse = (15 * tss);  
        A.Aci = (15 * tsi);  
    else
        A.Ass = tss * C;  
        A.Asi = tsi * C;  
        A.Als = A_larguerillo;  
        A.Ali = A_larguerillo;  
        A.Acse = A_cordon;  
        A.Aci = A_cordon;  
    end

    % ✅ Compute Total Upper and Lower Areas  
    A.Ars = A.Ass * n + A.Als * n + 2 * A.Acse;  
    A.Ari = A.Asi * n + A.Ali * n + 2 * A.Aci;  

    % ✅ Compute Total Section Area  
    A.A_total = A.Ars + A.Ari + (2 * H * tl);  

    % ✅ Compute Height of Center of Gravity (hcg)  
    hcg = ((A.Ars * H) + ((2 * H * tl) * (H / 2))) / A.A_total;  

    % ✅ Compute Moment of Inertia (I)  
    I = (2 * ((1/12) * H^3 * tl + (H * tl * (hcg - H/2)^2))) + (A.Ars * (H - hcg)^2) + (A.Ari * hcg^2);  

    % ✅ Fix Area for Load Distribution
    A.Acse = A.Acse / 2; % Correct for stress calculation

    % ✅ Fix Values for Shear Stress Calculation  
    A.H = H;
    A.hcg = hcg;
    A.tss = tss;
    A.tsi = tsi;
    A.tl = tl;
    A.A_Ls = A.Als;
    A.A_Li = A.Ali;
    A.pitch = pitch;
    A.I = I;
    A.C = C;
end
