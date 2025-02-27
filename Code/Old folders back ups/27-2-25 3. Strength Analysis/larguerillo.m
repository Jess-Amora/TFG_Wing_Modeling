%% Larguerillo Function
function area = larguerillo(dimensions)
    % LARGUERILLO Computes the cross-sectional area of a stringer.
    %
    % Inputs:
    %   dimensions: Struct with fields:
    %       - type: 'Z' or 'T' (defines the stringer shape)
    %       - wf: Flange width (m)
    %       - tf: Flange thickness (m)
    %       - hw: Web height (m)
    %       - tw: Web thickness (m)
    %       - wh: Heel width (m) [Only for 'Z']
    %       - th: Heel thickness (m) [Only for 'Z']
    %
    % Output:
    %   area: Cross-sectional area of the stringer (m²)

    % Extract common dimensions
    type = dimensions.type;  % 'Z' or 'T'
    wf = dimensions.wf;      % Flange width
    tf = dimensions.tf;      % Flange thickness
    hw = dimensions.hw;      % Web height
    tw = dimensions.tw;      % Web thickness

    % Compute area based on type
    if strcmp(type, 'Z')  % Z-type stringer
        wh = dimensions.wh;  % Heel width
        th = dimensions.th;  % Heel thickness
        area = (wf * tf) + (hw * tw) + (wh * th);
    
    elseif strcmp(type, 'T')  % T-type stringer
        area = (wf * tf) + (hw * tw);
    
    else
        error('Type must be "Z" or "T"');
    end
end
