function [is_valid, aspect_ratio] = check_aspect_ratio(surface_nodes, surface_type, varargin)
    % Function to evaluate aspect ratio for given surface nodes
    % Inputs:
    %   surface_nodes: Array of node coordinates [Nx2 or Nx3]
    %   surface_type: Type of surface ('quad', 'triangle')
    %   varargin: Aspect ratio threshold (optional, default = 3)
    % Outputs:
    %   is_valid: Boolean indicating if the surface passes the check
    %   aspect_ratio: Calculated aspect ratio
    
    % Default aspect ratio threshold
    aspect_ratio_threshold = 3;
    if ~isempty(varargin)
        aspect_ratio_threshold = varargin{1};
    end

    % Calculate aspect ratio based on surface type
    switch lower(surface_type)
        case 'quad'
            % Ensure 4 nodes
            if size(surface_nodes, 1) ~= 4
                error('Quadrilateral must have 4 nodes.');
            end
            % Calculate diagonals
            d1 = norm(surface_nodes(1, :) - surface_nodes(3, :)); % Diagonal 1
            d2 = norm(surface_nodes(2, :) - surface_nodes(4, :)); % Diagonal 2
            aspect_ratio = max(d1, d2) / min(d1, d2);
            
        case 'triangle'
            % Ensure 3 nodes
            if size(surface_nodes, 1) ~= 3
                error('Triangle must have 3 nodes.');
            end
            % Calculate edge lengths
            e1 = norm(surface_nodes(1, :) - surface_nodes(2, :));
            e2 = norm(surface_nodes(2, :) - surface_nodes(3, :));
            e3 = norm(surface_nodes(3, :) - surface_nodes(1, :));
            % Approximate aspect ratio as longest edge divided by shortest edge
            aspect_ratio = max([e1, e2, e3]) / min([e1, e2, e3]);
            
        otherwise
            error('Unsupported surface type: %s', surface_type);
    end

    % Validate against threshold
    is_valid = aspect_ratio <= aspect_ratio_threshold;
end
