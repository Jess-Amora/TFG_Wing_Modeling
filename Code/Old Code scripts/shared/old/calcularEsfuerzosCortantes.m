%% Shear Stress Calculation Function
function shear_stresses = calcularEsfuerzosCortantes(F, T, cajon,pitch, materialType)

    % Extract geometric parameters
    H = cajon.H;
    hcg = cajon.hcg;
    tss = cajon.tss;
    tsi = cajon.tsi;
    tl = cajon.tl;
    A_Ls = cajon.A_Ls;
    A_Li = cajon.A_Li;
    I = cajon.I;

    % ✅ Compute first moment of area (Q)  
    if strcmp(materialType, 'metal')
        Qs = sum((A_Ls + 30 * tss) .* (H - hcg));  
        % Qi = sum((A_Li + pitch * tsi) .* hcg);   
        % ✅ Fix Qi calculation
Qi = sum((A_Li + pitch * tsi) .* (H - hcg)); % Use correct reference height

    else
        Qs = sum((A_Ls + tss) .* (H - hcg));     
        Qi = sum((A_Li + tsi) .* hcg);           
    end
    Ql = (cajon.Ari * hcg / 2) + ((H^2) / 8) * tl;  

    % ✅ Compute shear stresses
    tau_ss = (F * Qs) / (I * tss);
    tau_si = (F * Qi) / (I * tsi);
    tau_l = (F * Ql) / (I * tl);

    % ✅ Compute torsional shear stresses
    S = 2 * (H * cajon.C);
    tau_ss_torsion = T / (2 * S * tss);
    tau_si_torsion = T / (2 * S * tsi);
    tau_l_torsion = T / (2 * S * tl);

    % ✅ Fix shear stress calculation for lower skin
    if tau_si < 1e-6 % Avoid zero values
        tau_si = (F * (A_Li * hcg)) / (I * tsi);
    end

    % ✅ Output as struct
    shear_stresses = struct('tau_ss', tau_ss, 'tau_si', tau_si, 'tau_l', tau_l, ...
                            'tau_ss_torsion', tau_ss_torsion, ...
                            'tau_si_torsion', tau_si_torsion, ...
                            'tau_l_torsion', tau_l_torsion, ...
                            'Qs', Qs, 'Qi', Qi);
end
