function area = cordon(dimensions)
    % CORDON Computes the cross-sectional area of a stringer cap.
    %
    % Inputs:
    %   dimensions: Struct with fields:
    %       - hcl: Height of the cordon (m)
    %       - tcl: Thickness of the cordon (m)
    %   showPlot: Boolean (true/false) to visualize the cross-section.
    %
    % Output:
    %   area: Cross-sectional area of the cordon (m²)

    % Extract dimensions from struct
    hcl = dimensions.hcl;  % Height
    tcl = dimensions.tcl;  % Thickness
    
    % Compute cross-sectional area
    area = (hcl + tcl) * 2;
    
end
