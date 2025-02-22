function [tri_surfaces, warnings] = handle_front_spar_irregularities(current_nodes, next_nodes, threshold)
    tri_surfaces = [];
    warnings = [];
    
    for i = 1:length(current_nodes) - 1
        tri_nodes = [
            current_nodes(i, :);
            next_nodes(i, :);
            next_nodes(i+1, :)
        ];
        
        % Calculate triangle area (quality check)
        area = 0.5 * abs(det([tri_nodes(1, 1:2) - tri_nodes(2, 1:2); ...
                              tri_nodes(1, 1:2) - tri_nodes(3, 1:2)]));
        if area > threshold
            tri_surfaces = [tri_surfaces; tri_nodes];
        else
            warnings = [warnings; sprintf('Triangle %d skipped due to small area.', i)];
        end
    end
end