function plot_surfaces_verification_v5(nodes_table, quad_surfaces, tri_surfaces, ...
    nodos_anterior_ala_table, nodos_posterior_ala_table, zone, plotTitle, savePath)
% plot_surfaces_verification_v5: Verifies and visualizes surfaces by zone with custom title.
%
% Inputs:
%   nodes_table: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   tri_surfaces: Px3 matrix (triangular surfaces using local IDs)
%   nodos_anterior_ala_table: Table for front spar nodes [local_id, x, y, rib_index, stringer_index, tag]
%   nodos_posterior_ala_table: Table for rear spar nodes [local_id, x, y, rib_index, stringer_index, tag]
%   zone: 'regular', 'irregular', or 'all' (zone to focus on)
%   plotTitle: Custom title for the plot (string)
%   savePath: Path to save the resulting plot (optional)

    %% 🎯 Initialization
    fig = figure('Name', sprintf('Surface Verification Plot (%s Zone)', zone), 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plotTitle); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% 🟢 Plot General Nodes
    plot(nodes_table.x, nodes_table.y, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:height(nodes_table)
        text(nodes_table.x(i), nodes_table.y(i), sprintf('%d', nodes_table.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% 🔴 Plot Front Spar Nodes
    if ~isempty(nodos_anterior_ala_table)
        plot(nodos_anterior_ala_table.x, nodos_anterior_ala_table.y, 'rs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
        for i = 1:height(nodos_anterior_ala_table)
            text(nodos_anterior_ala_table.x(i), nodos_anterior_ala_table.y(i), ...
                 sprintf('%d', nodos_anterior_ala_table.local_id(i)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'red');
        end
    end
    
    %% 🔵 Plot Rear Spar Nodes
    if ~isempty(nodos_posterior_ala_table)
        plot(nodos_posterior_ala_table.x, nodos_posterior_ala_table.y, 'bs', 'MarkerSize', 6, ...
             'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
        for i = 1:height(nodos_posterior_ala_table)
            text(nodos_posterior_ala_table.x(i), nodos_posterior_ala_table.y(i), ...
                 sprintf('%d', nodos_posterior_ala_table.local_id(i)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8, 'Color', 'blue');
        end
    end
    
    %% 📊 Filter Surfaces Based on Zone
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

    %% 🟦 Plot Quadrilateral Surfaces
    quad_plotted = false;
    if ~isempty(quad_surfaces)
        for i = 1:size(quad_surfaces, 1)
            % Extract node coordinates by matching local_id
            quad_coords = nodes_table(ismember(nodes_table.local_id, quad_surfaces(i,:)), {'x', 'y'});
            
            if height(quad_coords) == 4
                % Ensure node order is counterclockwise
                centroid = mean([quad_coords.x, quad_coords.y], 1);
                angles = atan2(quad_coords.y - centroid(2), quad_coords.x - centroid(1));
                [~, sort_idx] = sort(angles);
                quad_coords = quad_coords(sort_idx, :);
                
                % Plot quadrilateral surface
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
    
    %% 🟥 Plot Triangular Surfaces
    tri_plotted = false;
    if ~isempty(tri_surfaces)
        for i = 1:size(tri_surfaces, 1)
            tri_coords = nodes_table(ismember(nodes_table.local_id, tri_surfaces(i,:)), {'x', 'y'});
            
            if height(tri_coords) == 3
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
    
    %% 📌 Legend and Styling
    legend('show', 'Location', 'best');
    hold off;
    
    %% 💾 Save Plot
    if exist('savePath', 'var') && ~isempty(savePath)
        [fileDir, fileName, ~] = fileparts(savePath);
        if ~exist(fileDir, 'dir')
            mkdir(fileDir);
        end
        
        saveas(fig, fullfile(fileDir, sprintf('%s_verification_plot_%s.png', fileName, zone)));
        savefig(fig, fullfile(fileDir, sprintf('%s_verification_plot_%s.fig', fileName, zone)));
    end
    
    close(fig); % Prevent plot clutter in MATLAB GUI
    disp('✅ Plot saved successfully.');
end
