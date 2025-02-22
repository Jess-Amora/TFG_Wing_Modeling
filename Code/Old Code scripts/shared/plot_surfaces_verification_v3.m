function plot_surfaces_verification_v3(nodes, quad_surfaces, tri_surfaces, nodos_anterior_ala, nodos_posterior_ala, zone, plotTitle, savePath)
% plot_surfaces_verification_v2: Verifies and visualizes surfaces by zone with custom title.
%
% Inputs:
%   nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   tri_surfaces: Px3 matrix (triangular surfaces using local IDs)
%   nodos_anterior_ala: Nx5 matrix [x, y, rib_index, stringer_index, local_id] for front spar nodes
%   nodos_posterior_ala: Nx5 matrix [x, y, rib_index, stringer_index, local_id] for rear spar nodes
%   zone: 'regular', 'irregular', or 'all' (zone to focus on)
%   plotTitle: Custom title for the plot (string)
%   savePath: Path to save the resulting plot (optional)

    %% Initialization
    fig = figure('Name', sprintf('Surface Verification Plot (%s Zone)', zone), 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plotTitle); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% Plot General Nodes
    plot(nodes(:,1), nodes(:,2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:size(nodes, 1)
        text(nodes(i,1), nodes(i,2), sprintf('%d', nodes(i,5)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% Plot Front Spar Nodes
    if ~isempty(nodos_anterior_ala)
        plot(nodos_anterior_ala(:,1), nodos_anterior_ala(:,2), 'rs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
        for i = 1:size(nodos_anterior_ala, 1)
            text(nodos_anterior_ala(i,1), nodos_anterior_ala(i,2), sprintf('%d', nodos_anterior_ala(i,5)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'red');
        end
    end
    
    %% Plot Rear Spar Nodes
    if ~isempty(nodos_posterior_ala)
        plot(nodos_posterior_ala(:,1), nodos_posterior_ala(:,2), 'bs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
        for i = 1:size(nodos_posterior_ala, 1)
            text(nodos_posterior_ala(i,1), nodos_posterior_ala(i,2), sprintf('%d', nodos_posterior_ala(i,5)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'blue');
        end
    end
    
    %% Filter Surfaces Based on Zone
    if strcmp(zone, 'regular')
        % Filter Quadrilateral Surfaces for Regular Region
        if ~isempty(quad_surfaces)
            quad_surfaces = quad_surfaces(quad_surfaces(:,1) > 0, :); 
        end
        
        if ~isempty(tri_surfaces)
            tri_surfaces = tri_surfaces(tri_surfaces(:,1) > 0, :);    
        else
            tri_surfaces = []; 
        end
        
    elseif strcmp(zone, 'irregular')
        % Filter Quadrilateral Surfaces for Irregular Region
        if ~isempty(quad_surfaces)
            quad_surfaces = quad_surfaces(quad_surfaces(:,1) < 0, :); 
        end
        
        if ~isempty(tri_surfaces)
            tri_surfaces = tri_surfaces(tri_surfaces(:,1) < 0, :);    
        else
            tri_surfaces = []; 
        end
    end

    %% Plot Quadrilateral Surfaces
    quad_plotted = false;
    if ~isempty(quad_surfaces)
        for i = 1:size(quad_surfaces, 1)
            quad_coords = nodes(ismember(nodes(:,5), quad_surfaces(i,:)), 1:2);
            if size(quad_coords, 1) == 4
                centroid = mean(quad_coords, 1);
                angles = atan2(quad_coords(:,2) - centroid(2), quad_coords(:,1) - centroid(1));
                [~, sort_idx] = sort(angles);
                quad_coords = quad_coords(sort_idx, :);
                if ~quad_plotted
                    fill(quad_coords(:,1), quad_coords(:,2), 'cyan', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'b', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surface');
                    quad_plotted = true;
                else
                    fill(quad_coords(:,1), quad_coords(:,2), 'cyan', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'b', 'LineWidth', 1.2, 'HandleVisibility', 'off');
                end
            end
        end
    end
    
    %% Plot Triangular Surfaces
    tri_plotted = false;
    if ~isempty(tri_surfaces)
        for i = 1:size(tri_surfaces, 1)
            tri_coords = nodes(ismember(nodes(:,5), tri_surfaces(i,:)), 1:2);
            if size(tri_coords, 1) == 3
                if ~tri_plotted
                    fill(tri_coords(:,1), tri_coords(:,2), 'magenta', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'r', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');
                    tri_plotted = true;
                else
                    fill(tri_coords(:,1), tri_coords(:,2), 'magenta', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'r', 'LineWidth', 1.2, 'HandleVisibility', 'off');
                end
            end
        end
    end
    
    %% Legend and Styling
    legend('show', 'Location', 'best');
    hold off;
    
    %% Save Plot
    if exist('savePath', 'var') && ~isempty(savePath)
        [fileDir, fileName, ~] = fileparts(savePath);
        if ~exist(fileDir, 'dir')
            mkdir(fileDir);
        end
        
        saveas(fig, fullfile(fileDir, sprintf('%s_verification_plot_%s.png', fileName, zone)));
        savefig(fig, fullfile(fileDir, sprintf('%s_verification_plot_%s.fig', fileName, zone)));
    end
    
    close(fig); % Prevent plot clutter in MATLAB GUI
end
