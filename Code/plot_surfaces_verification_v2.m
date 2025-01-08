function plot_surfaces_verification_v2(nodes, quad_surfaces, tri_surfaces, zone, plotTitle, savePath)
% plot_surfaces_verification_v2: Verifies and visualizes surfaces by zone with a custom title.
%
% Inputs:
%   nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   tri_surfaces: Px3 matrix (triangular surfaces using local IDs)
%   zone: 'regular', 'irregular', or 'all' (zone to focus on)
%   plotTitle: Custom title for the plot (string)
%   savePath: Path to save the resulting plot (optional)
%

    %% Initialization
    fig = figure('Name', sprintf('Surface Verification Plot (%s Zone)', zone), 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plotTitle); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% Plot Nodes
    plot(nodes(:,1), nodes(:,2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:size(nodes, 1)
        text(nodes(i,1), nodes(i,2), sprintf('%d', nodes(i,5)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
        
    %% Filter Surfaces Based on Zone

if strcmp(zone, 'regular')
    % Filter Quadrilateral Surfaces for Regular Region
    if ~isempty(quad_surfaces)
        quad_surfaces = quad_surfaces(quad_surfaces(:,1) > 0, :); % Example condition for regular surfaces
    end
    
    % Safely Handle Empty Triangular Surfaces
    if ~isempty(tri_surfaces)
        tri_surfaces = tri_surfaces(tri_surfaces(:,1) > 0, :);    % Example condition for regular surfaces
    else
        tri_surfaces = []; % Ensure it's explicitly set as an empty matrix
    end
    
elseif strcmp(zone, 'irregular')
    % Filter Quadrilateral Surfaces for Irregular Region
    if ~isempty(quad_surfaces)
        quad_surfaces = quad_surfaces(quad_surfaces(:,1) < 0, :); % Example condition for irregular surfaces
    end
    
    % Safely Handle Empty Triangular Surfaces
    if ~isempty(tri_surfaces)
        tri_surfaces = tri_surfaces(tri_surfaces(:,1) < 0, :);    % Example condition for irregular surfaces
    else
        tri_surfaces = []; % Ensure it's explicitly set as an empty matrix
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
        % Ensure savePath is a valid directory
        [fileDir, fileName, fileExt] = fileparts(savePath);
        
        if isempty(fileExt)
            % If no file extension is provided, assume it's a directory path
            targetDir = fileDir;
        else
            % If a file extension is provided, extract the directory
            targetDir = fileDir;
        end
        
        % Create directory if it doesn't exist
        if ~exist(targetDir, 'dir')
            mkdir(targetDir);
            fprintf('📂 Created directory: %s\n', targetDir);
        end
        
        % Define file paths for PNG and FIG formats
        pngFile = fullfile(targetDir, sprintf('%s_verification_plot_%s.png', fileName, zone));
        figFile = fullfile(targetDir, sprintf('%s_verification_plot_%s.fig', fileName, zone));
        
        % Save the plot
        try
            saveas(fig, pngFile);
            savefig(fig, figFile);
            fprintf('✅ Verification plot (%s zone) saved to:\n - %s\n - %s\n', zone, pngFile, figFile);
        catch saveError
            warning('❌ Failed to save plot: %s', saveError.message);
        end
    else
        fprintf('⚠️ No valid savePath provided. Plot not saved.\n');
    end

    
    close(fig); % Prevent plot clutter in MATLAB GUI
end
