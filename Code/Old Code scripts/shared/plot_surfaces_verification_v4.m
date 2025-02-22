function plot_surfaces_verification_v4(nodes, quad_surfaces, tri_surfaces, ...
    nodos_anterior_ala, nodos_posterior_ala, zone, plotTitle, savePath)
% plot_surfaces_verification_v3: Verifies and visualizes surfaces by zone with a custom title.
%
% Inputs:
%   nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   tri_surfaces: Px3 matrix (triangular surfaces using local IDs)
%   nodos_anterior_ala: Table [local_id, x, y, rib_index, stringer_index, tag] for front spar nodes
%   nodos_posterior_ala: Table [local_id, x, y, rib_index, stringer_index, tag] for rear spar nodes
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
    if ~isempty(nodes)
        plot(nodes.x, nodes.y, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes');
        % Add Node Labels
        for i = 1:height(nodes)
            text(nodes.x(i), nodes.y(i), sprintf('%d', nodes.local_id(i)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
        end
    end
    
    %% Plot Front Spar Nodes
    if ~isempty(nodos_anterior_ala)
        plot(nodos_anterior_ala.x, nodos_anterior_ala.y, 'rs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
        for i = 1:height(nodos_anterior_ala)
            text(nodos_anterior_ala.x(i), nodos_anterior_ala.y(i), sprintf('%d', nodos_anterior_ala.local_id(i)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'red');
        end
    end
    
    %% Plot Rear Spar Nodes
    if ~isempty(nodos_posterior_ala)
        plot(nodos_posterior_ala.x, nodos_posterior_ala.y, 'bs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
        for i = 1:height(nodos_posterior_ala)
            text(nodos_posterior_ala.x(i), nodos_posterior_ala.y(i), sprintf('%d', nodos_posterior_ala.local_id(i)), ...
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
            quad_coords = nodes{ismember(nodes.local_id, quad_surfaces(i,:)), {'x', 'y'}};
            if size(quad_coords, 1) == 4
                centroid = mean(quad_coords{:,:}, 1);
                angles = atan2(quad_coords.y - centroid(2), quad_coords.x - centroid(1));
                [~, sort_idx] = sort(angles);
                quad_coords = quad_coords(sort_idx, :);
                if ~quad_plotted
                    fill(quad_coords.x, quad_coords.y, 'cyan', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'b', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surface');
                    quad_plotted = true;
                else
                    fill(quad_coords.x, quad_coords.y, 'cyan', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'b', 'LineWidth', 1.2, 'HandleVisibility', 'off');
                end
            end
        end
    end
    
    %% Plot Triangular Surfaces
    tri_plotted = false;
    if ~isempty(tri_surfaces)
        for i = 1:size(tri_surfaces, 1)
            tri_coords = nodes{ismember(nodes.local_id, tri_surfaces(i,:)), {'x', 'y'}};
            if size(tri_coords, 1) == 3
                if ~tri_plotted
                    fill(tri_coords.x, tri_coords.y, 'magenta', 'FaceAlpha', 0.3, ...
                         'EdgeColor', 'r', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');
                    tri_plotted = true;
                else
                    fill(tri_coords.x, tri_coords.y, 'magenta', 'FaceAlpha', 0.3, ...
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
