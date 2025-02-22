function [is_valid, aspect_ratio] = check_aspect_ratio_v2(surface_nodes, surface_type, varargin)
    % CHECK_ASPECT_RATIO - Evaluate aspect ratio for given surface nodes in 3D
    %
    % Inputs:
    %   surface_nodes: Array of node coordinates [Nx3] (3D nodes)
    %   surface_type: Type of surface ('quad', 'triangle', 'penta')
    %   varargin: Aspect ratio threshold (optional, default = 3)
    %
    % Outputs:
    %   is_valid: Boolean indicating if the surface passes the aspect ratio check
    %   aspect_ratio: Calculated aspect ratio
    
    %% 🛠 Default aspect ratio threshold
    aspect_ratio_threshold = 3; % Default threshold
    if ~isempty(varargin)
        aspect_ratio_threshold = varargin{1};
    end

    %% 🔄 Handle surface types
    switch lower(surface_type)
        case 'quad'  % Quadrilateral surface
            % Ensure 4 nodes
            if size(surface_nodes, 1) ~= 4 || size(surface_nodes, 2) ~= 3
                error('Quadrilateral must have 4 nodes in 3D space.');
            end

            % Calculate diagonals
            d1 = norm(surface_nodes(1, :) - surface_nodes(3, :)); % Diagonal 1
            d2 = norm(surface_nodes(2, :) - surface_nodes(4, :)); % Diagonal 2
            
            % Aspect ratio: Longest diagonal divided by shortest diagonal
            aspect_ratio = max(d1, d2) / min(d1, d2);

        case 'triangle'  % Triangular surface
            % Ensure 3 nodes
            if size(surface_nodes, 1) ~= 3 || size(surface_nodes, 2) ~= 3
                error('Triangle must have 3 nodes in 3D space.');
            end

            % Calculate edge lengths
            e1 = norm(surface_nodes(1, :) - surface_nodes(2, :));
            e2 = norm(surface_nodes(2, :) - surface_nodes(3, :));
            e3 = norm(surface_nodes(3, :) - surface_nodes(1, :));
            
            % Aspect ratio: Longest edge divided by shortest edge
            aspect_ratio = max([e1, e2, e3]) / min([e1, e2, e3]);

        case 'penta'  % Pentagonal surface
            % Ensure 5 nodes
            if size(surface_nodes, 1) ~= 5 || size(surface_nodes, 2) ~= 3
                error('Pentagonal surface must have 5 nodes in 3D space.');
            end

            % Calculate all edges and diagonals
            edges = [
                norm(surface_nodes(1, :) - surface_nodes(2, :));
                norm(surface_nodes(2, :) - surface_nodes(3, :));
                norm(surface_nodes(3, :) - surface_nodes(4, :));
                norm(surface_nodes(4, :) - surface_nodes(5, :));
                norm(surface_nodes(5, :) - surface_nodes(1, :));
            ];
            diagonals = [
                norm(surface_nodes(1, :) - surface_nodes(3, :));
                norm(surface_nodes(1, :) - surface_nodes(4, :));
                norm(surface_nodes(2, :) - surface_nodes(4, :));
                norm(surface_nodes(2, :) - surface_nodes(5, :));
                norm(surface_nodes(3, :) - surface_nodes(5, :));
            ];
            
            % Combine edges and diagonals
            all_lengths = [edges; diagonals];
            
            % Aspect ratio: Longest length divided by shortest length
            aspect_ratio = max(all_lengths) / min(all_lengths);

        otherwise
            error('Unsupported surface type: %s', surface_type);
    end

    %% ✅ Validate against threshold
    is_valid = aspect_ratio <= aspect_ratio_threshold;
end
