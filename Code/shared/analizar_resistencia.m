%% Function to Analyze Resistance of Revestimientos, Larguerillos, Largueros, and Costillas
function RF = analizar_resistencia(stresses, materialType)
    % ANALIZAR_RESISTENCIA Computes resistance factors (RF) based on stress limits.
    %
    % Inputs:
    %   stresses: Struct with computed stresses
    %       - sigma_LS: Axial stress in upper stringer
    %       - sigma_Li: Axial stress in lower stringer
    %       - sigma_Cs: Axial stress in upper spar cap
    %       - sigma_Ci: Axial stress in lower spar cap
    %       - sigma_RS: Axial stress in upper skin
    %       - sigma_RI: Axial stress in lower skin
    %       - tau_SS: Shear stress in upper skin
    %       - tau_SI: Shear stress in lower skin
    %       - tau_L: Shear stress in larguero
    %       - tau_C: Shear stress in costilla
    %   materialType: 'metal' or 'composite'
    %
    % Outputs:
    %   RF: Struct with resistance factors for each component

    %% Define Material Allowables
    if strcmp(materialType, 'metal')
        sigma_lim_RS = 450;  % Upper skin yield limit (MPa)
        sigma_lim_RI = 450;  % Lower skin yield limit (MPa)
        sigma_rupt_LS = 505; % Upper stringer rupture (MPa)
        sigma_rupt_Li = 415; % Lower stringer rupture (MPa)
        sigma_rupt_Cs = 505; % Upper spar cap rupture (MPa)
        sigma_rupt_Ci = 415; % Lower spar cap rupture (MPa)
        sigma_fatigue_L = 280; % Larguero fatigue limit (MPa)
        sigma_fatigue_C = 280; % Costilla fatigue limit (MPa)
        tau_lim_SS = 305;    % Upper skin shear limit (MPa)
        tau_lim_SI = 415;    % Lower skin shear limit (MPa)
        tau_lim_L = 305;     % Shear limit for larguero (MPa)
        tau_lim_C = 505;     % Shear limit for costilla (MPa)
    else
        sigma_lim_RS = 505;  
        sigma_lim_RI = 505;  
        sigma_rupt_LS = 505;  
        sigma_rupt_Li = 505;  
        sigma_rupt_Cs = 505;  
        sigma_rupt_Ci = 505;  
        sigma_fatigue_L = -175; % Composite DT fiber failure
        sigma_fatigue_C = -175; % Composite DT fiber failure
        tau_lim_SS = 505;    
        tau_lim_SI = 505;    
        tau_lim_L = -175;     % Composite shear DT limit
        tau_lim_C = 245;      % Composite rib shear limit
    end

    %% Compute Resistance Factors (RF)
    % Larguerillos (Stringers)
    RF.sigma_LS = abs(stresses.sigma_LS) / sigma_rupt_LS;
    RF.sigma_Li = abs(stresses.sigma_Li) / sigma_rupt_Li;
    
    % Cordon Larguero (Spar Caps)
    RF.sigma_Cs = abs(stresses.sigma_Cs) / sigma_rupt_Cs;
    RF.sigma_Ci = abs(stresses.sigma_Ci) / sigma_rupt_Ci;
    
    % Larguero (Spar)
    RF.sigma_VM_L_A = sqrt(stresses.sigma_Cs^2 + 3 * stresses.tau_SS^2) / sigma_rupt_Cs;
    RF.sigma_VM_L_C = sqrt(stresses.sigma_Ci^2 + 3 * stresses.tau_SI^2) / sigma_rupt_Ci;
    RF.tau_L = abs(stresses.tau_L) / tau_lim_L;
    
    % Costilla (Rib)
    RF.sigma_VM_C = sqrt(stresses.sigma_C^2 + 3 * stresses.tau_C^2) / sigma_fatigue_C;

    % Upper & Lower Skin Analysis
    if strcmp(materialType, 'metal')
        RF.tau_SS = abs(stresses.tau_SS) / tau_lim_SS;
        RF.sigma_VM_RI = sqrt(stresses.sigma_RI^2 + 3 * stresses.tau_SI^2) / tau_lim_SI;
    else
        RF.sigma_VM_RS = sqrt(stresses.sigma_RS^2 + 3 * stresses.tau_SS^2) / sigma_lim_RS;
        RF.sigma_VM_RI = sqrt(stresses.sigma_RI^2 + 3 * stresses.tau_SI^2) / sigma_lim_RI;
    end
end
