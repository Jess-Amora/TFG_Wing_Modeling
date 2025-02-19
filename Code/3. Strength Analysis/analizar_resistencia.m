function RF = analizar_resistencia(stresses, materialType)
    % ANALIZAR_RESISTENCIA Computes resistance factors (RF) based on stress limits.

    %% Define Material Allowables
    if strcmp(materialType, 'metal')
        RF.sigma_lim_RS = 450;  % Upper skin yield limit (MPa)
        RF.sigma_lim_RI = 450;  % Lower skin yield limit (MPa)
        sigma_rupt_LS = 505; % Upper stringer rupture (MPa)
        sigma_rupt_Li = 415; % Lower stringer rupture (MPa)
        sigma_rupt_Cs = 505; % Upper spar cap rupture (MPa)
        sigma_rupt_Ci = 415; % Lower spar cap rupture (MPa)
        sigma_fatigue_L = 280; % Larguero fatigue limit (MPa)
        sigma_fatigue_C = 280; % Costilla fatigue limit (MPa)
        RF.tau_lim_SS = 305;    % Upper skin shear limit (MPa)
        RF.tau_lim_SI = 415;    % Lower skin shear limit (MPa)
        RF.tau_lim_L = 305;     % Shear limit for larguero (MPa)
        RF.tau_lim_C = 505;     % Shear limit for costilla (MPa)
    else
        RF.sigma_lim_RS = 505;  
        RF.sigma_lim_RI = 505;  
        sigma_rupt_LS = 505;  
        sigma_rupt_Li = 505;  
        sigma_rupt_Cs = 505;  
        sigma_rupt_Ci = 505;  
        sigma_fatigue_L = -175; % Composite DT fiber failure
        sigma_fatigue_C = -175; % Composite DT fiber failure
        RF.tau_lim_SS = 505;    
        RF.tau_lim_SI = 505;    
        RF.tau_lim_L = -175;     % Composite shear DT limit
        RF.tau_lim_C = 245;      % Composite rib shear limit
    end

    %% Compute Resistance Factors (RF)
    RF.sigma_LS = abs(stresses.sigma_LS) / sigma_rupt_LS;
    RF.sigma_Li = abs(stresses.sigma_Li) / sigma_rupt_Li;
    RF.sigma_Cs = abs(stresses.sigma_Cs) / sigma_rupt_Cs;
    RF.sigma_Ci = abs(stresses.sigma_Ci) / sigma_rupt_Ci;

    % Larguero (Spar)
    RF.sigma_VM_L_A = sqrt(stresses.sigma_Cs.^2 + 3 * stresses.tau_SS.^2) / sigma_rupt_Cs;
    RF.sigma_VM_L_C = sqrt(stresses.sigma_Ci.^2 + 3 * stresses.tau_SI.^2) / sigma_rupt_Ci;
    RF.tau_L = abs(stresses.tau_L) / RF.tau_lim_L;

    % Costilla (Rib)
    RF.sigma_VM_C = sqrt(stresses.sigma_C.^2 + 3 * stresses.tau_C.^2) / sigma_fatigue_C;

    % Upper & Lower Skin Analysis
    RF.tau_SS = abs(stresses.tau_SS) / RF.tau_lim_SS;
    RF.sigma_VM_RI = sqrt(stresses.sigma_RI.^2 + 3 * stresses.tau_SI.^2) / RF.tau_lim_SI;
    RF.sigma_VM_RS = sqrt(stresses.sigma_RS.^2 + 3 * stresses.tau_SS.^2) / RF.sigma_lim_RS;  % ✅ Fix for metal case
end
