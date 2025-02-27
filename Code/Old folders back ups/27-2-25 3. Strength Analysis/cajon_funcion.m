function cajon_struct = cajon_funcion(dimensions, ribs_prop, materialType, datosEstructural, pandeoLocalsuperior)
% CAJON_FUNCION Computes the cajón properties for each rib slice.
%
%   cajon_struct = cajon_funcion(dimensions, ribs_prop, materialType, datosEstructural, pandeoLocalsuperior)
%
%   Inputs:
%       dimensions      - Struct with fields:
%                           tss         : Upper skin thickness (scalar, in mm)
%                           tsi         : Lower skin thickness (scalar, in mm)
%                           tl          : Spar thickness (scalar, in mm)
%                           A_larguerillo: Area of larguerillo (scalar, in m²)
%                           A_cordon    : Area of cordón (scalar, in m²)
%       ribs_prop       - Table (or struct array) with rib properties, containing at least:
%                           'rib_id'    : Rib identifier
%                           'C'         : Local chord (box width) for that rib (in mm)
%                           'H'         : Local box height for that rib (in mm)
%       materialType    - String specifying the material type (e.g., 'metal' or others)
%       datosEstructural- Struct containing design parameters:
%                           n         : (number of elements, etc.)
%                           distancia_entre_larguerillo : (pitch) in m
%       pandeoLocalsuperior - (Not used in this simple example but kept for compatibility)
%
%   Output:
%       cajon_struct    - Array of structs (one per rib) with fields:
%                           A, hcg, I, H, C, tss, tsi, tl, pitch, A_Ls, A_Li, Ari
%
%   For each rib, the function uses the rib's H and C (converted from mm to m as needed)
%   and computes effective areas, center of gravity, and moment of inertia.

    % Number of ribs (each row in ribs_prop represents one rib)
    N = height(ribs_prop);
    
    % Preallocate struct array for efficiency
    cajon_struct = repmat(struct('A', [], 'hcg', [], 'I', [], 'H', [], 'C', [], ...
                                 'tss', [], 'tsi', [], 'tl', [], 'pitch', [], ...
                                 'A_Ls', [], 'A_Li', [], 'Ari', []), N, 1);
    
    % Extract constant values from dimensions and datosEstructural
    tss = dimensions.tss;        % Upper skin thickness (mm)
    tsi = dimensions.tsi;        % Lower skin thickness (mm)
    tl = dimensions.tl;          % Spar thickness (mm)
    A_larguerillo = dimensions.A_larguerillo;  % (m²)
    A_cordon = dimensions.A_cordon;            % (m²)
    n = datosEstructural.n;
    pitch = datosEstructural.distancia_entre_larguerillo; % (m)
    
    % Loop over each rib to compute its cajón properties
    for i = 1:N
        % For this rib, extract H and C from the ribs_prop table (in mm)
        H_i = ribs_prop.H(i);  % Box height (mm)
        C_i = ribs_prop.C(i);  % Box width (mm)
        
        % Convert H and C from mm to m for calculations
        H_m = H_i * 1e-3;
        C_m = C_i * 1e-3;
        
        % Compute effective areas based on material type
        if strcmp(materialType, 'metal')
            A.Ass = (30 * tss) * 1e-3;  % Convert thickness to m if tss in mm
            A.Asi = (30 * tsi) * 1e-3;
            A.Als = A_larguerillo;
            A.Ali = A_larguerillo;
            A.Acse = (15 * tss) * 1e-3;
            A.Aci = (15 * tsi) * 1e-3;
        else
            A.Ass = (tss * C_m);
            A.Asi = (tsi * C_m);
            A.Als = A_larguerillo;
            A.Ali = A_larguerillo;
            A.Acse = A_cordon;
            A.Aci = A_cordon;
        end

        % Compute total upper and lower areas
        A.Ars = A.Ass * n + A.Als * n + 2 * A.Acse;
        A.Ari = A.Asi * n + A.Ali * n + 2 * A.Aci;
        
        % Compute total section area (include contribution from spars)
        A.A_total = A.Ars + A.Ari + (2 * H_m * (tl * 1e-3));
        
        % Compute center of gravity (hcg)
        hcg = ((A.Ars * H_m) + ((2 * H_m * (tl * 1e-3)) * (H_m / 2))) / A.A_total;
        
        % Compute moment of inertia (I)
        I = (2 * ((1/12) * H_m^3 * (tl * 1e-3) + (H_m * (tl * 1e-3) * (hcg - H_m/2)^2))) + ...
            (A.Ars * (H_m - hcg)^2) + (A.Ari * hcg^2);
        
        % Store corrected fields in A
        A.H = H_m;
        A.hcg = hcg;
        A.tss = tss * 1e-3;
        A.tsi = tsi * 1e-3;
        A.tl = tl * 1e-3;
        A.pitch = pitch;
        A.I = I;
        A.C = C_m;
        A.A_Ls = A.Als;
        A.A_Li = A.Ali;
        
        % Store computed values for this rib in the struct array
        cajon_struct(i) = struct( ...
            'A', A, ...
            'hcg', hcg, ...
            'I', I, ...
            'H', H_m, ...
            'C', C_m, ...
            'tss', tss * 1e-3, ...
            'tsi', tsi * 1e-3, ...
            'tl', tl * 1e-3, ...
            'pitch', pitch, ...
            'A_Ls', A.Als, ...
            'A_Li', A.Ali, ...
            'Ari', A.Ari ...
        );
    end
end
