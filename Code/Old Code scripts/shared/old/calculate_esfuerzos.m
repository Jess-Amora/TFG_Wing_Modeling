%% Calculate Esfuerzos Function
function sigma = calculate_esfuerzos(H, hcg, My, I)
    % CALCULATE_ESFUERZOS Computes axial stress in the upper and lower skin.
    %
    % Inputs:
    %   H    - Total height of the wing box (m)
    %   hcg  - Center of gravity height (m)
    %   My   - Bending moment (N·m)
    %   I    - Moment of inertia (m⁴)
    %
    % Output:
    %   sigma - Absolute axial stress (Pa) [Same for top & bottom in magnitude]

    % Compute axial stress (same magnitude for top and bottom)
    sigma = abs(My * (H - hcg) / I);
end
