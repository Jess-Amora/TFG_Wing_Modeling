function plot_surfaces_verification_v6(nodes_table, quad_surfaces, tri_surfaces, ...
    nodos_anterior_ala_table, nodos_posterior_ala_table, zone, plotTitle, savePath)
% plot_surfaces_verification_v5: Verifies and visualizes surfaces by zone with custom title.
%
% Inputs:
%   nodes_table: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   quad_surfaces: Table with columns representing quadrilateral surfaces (local IDs and metadata)
%   tri_surfaces: Table with columns representing triangular surfaces (local IDs and metadata)
%   nodos_anterior_ala_table: Table for front spar nodes [local_id, x, y, rib_index, stringer_index, tag]
%   nodos_posterior_ala_table: Table for rear spar nodes [local_id, x, y, rib_index, stringer_index, tag]
%   zone: 'rear spar', 'regular', 'irregular', or 'all' (zone to focus on)
%   plotTitle: Custom title for the plot (string)
%   savePath: Path to save the resulting plot (optional)

    %% 🎯 Initialization
    fig = figure('Name', sprintf('Surface Verification Plot (%s Zone)', zone), 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plotTitle, 'Interpreter', 'none'); % Use the custom title from input
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
    
    %% 🟦 Plot Quadrilateral Surfaces
    if ~isempty(quad_surfaces)
        for i = 1:height(quad_surfaces)
            % Extract node coordinates by matching local_id
            quad_coords = nodes_table(ismember(nodes_table.local_id, ...
                [quad_surfaces.Node_ID_1(i), quad_surfaces.Node_ID_2(i), ...
                 quad_surfaces.Node_ID_3(i), quad_surfaces.Node_ID_4(i)]), {'x', 'y'});
            
            if height(quad_coords) == 4
                % Plot quadrilateral surface
                fill(quad_coords.x, quad_coords.y, 'cyan', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'b', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surface');
            end
        end
    end
    
    %% 🟥 Plot Triangular Surfaces
    if ~isempty(tri_surfaces)
        for i = 1:height(tri_surfaces)
            % Extract node coordinates by matching local_id
            tri_coords = nodes_table(ismember(nodes_table.local_id, ...
                [tri_surfaces.Node_ID_1(i), tri_surfaces.Node_ID_2(i), ...
                 tri_surfaces.Node_ID_3(i)]), {'x', 'y'});
            
            if height(tri_coords) == 3
                % Plot triangular surface
                fill(tri_coords.x, tri_coords.y, 'magenta', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'r', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');
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
        saveas(fig, fullfile(fileDir, sprintf('%s_%s.png', fileName, zone)));
        savefig(fig, fullfile(fileDir, sprintf('%s_%s.fig', fileName, zone)));
    end
    
    disp('✅ Verification plot completed and saved successfully.');
end
