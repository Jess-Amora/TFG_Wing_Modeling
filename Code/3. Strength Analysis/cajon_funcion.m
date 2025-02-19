function cajon_struct = cajon_funcion(dimensions, materialType, datosEstructural, pandeoLocalsuperior)
    % Extract values from struct
    H = dimensions.H;  
    C = dimensions.C;  
    tss = dimensions.tss;  
    tsi = dimensions.tsi;  
    tl = dimensions.tl;  
    A_larguerillo = dimensions.A_larguerillo;  
    A_cordon = dimensions.A_cordon;  
    n = datosEstructural.n;  
    pitch = datosEstructural.distancia_entre_larguerillo;  

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

    % ✅ Store Corrected Fields
    A.H = H;
    A.hcg = hcg;
    A.tss = tss;
    A.tsi = tsi;
    A.tl = tl;
    A.pitch = pitch;
    A.I = I;
    A.C = C;

    % ✅ Fix Issue: Define `A_Ls` and `A_Li`
    A.A_Ls = A.Als;  % ✅ Add explicitly for later reference
    A.A_Li = A.Ali;  % ✅ Add explicitly for later reference

    % ✅ Return as structured output
    cajon_struct = struct( ...
    'A', A, ...
    'hcg', hcg, ...
    'I', I, ...
    'H', H, ...
    'C', C, ...
    'tss', tss, ...
    'tsi', tsi, ...
    'tl', tl, ...
    'pitch', pitch, ...
    'A_Ls', A.Als, ...  % ✅ Explicitly included
    'A_Li', A.Ali, ...  % ✅ Explicitly included
    'Ari', A.Ari ...    % ✅ FIX: Add Ari to the struct
);

end
