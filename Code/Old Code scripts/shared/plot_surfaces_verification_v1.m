function plot_surfaces_verification_v1(nodes, quad_surfaces, tri_surfaces, savePath)
% plot_surfaces_verification: Verifies and visualizes quadrilateral and triangular surfaces.
%
% Inputs:
%   nodes: Nx5 matrix [x, y, rib_index, stringer_index, local_id]
%   quad_surfaces: Mx4 matrix (quadrilateral surfaces using local IDs)
%   tri_surfaces: Px3 matrix (triangular surfaces using local IDs)
%   savePath: Path to save the resulting plot (optional)
%
% Outputs:
%   Saves a plot showing nodes and surfaces in the specified directory.

    %% Initialization
    fig = figure('Name', 'Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title('Surface Verification Plot');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% Plot Nodes
    plot(nodes(:,1), nodes(:,2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:size(nodes, 1)
        text(nodes(i,1), nodes(i,2), sprintf('%d', nodes(i,5)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% Plot Quadrilateral Surfaces

quad_plotted = false; % Flag to track if legend entry was added

if ~isempty(quad_surfaces)
    for i = 1:size(quad_surfaces, 1)
        % Get Node Coordinates
        quad_coords = nodes(ismember(nodes(:,5), quad_surfaces(i,:)), 1:2);
        
        % Ensure we have exactly 4 nodes
        if size(quad_coords, 1) == 4
            % Calculate Centroid
            centroid = mean(quad_coords, 1);
            
            % Calculate Angles Relative to Centroid
            angles = atan2(quad_coords(:,2) - centroid(2), quad_coords(:,1) - centroid(1));
            
            % Sort Nodes Counterclockwise by Angle
            [~, sort_idx] = sort(angles);
            quad_coords = quad_coords(sort_idx, :);
            
            % Plot the Quadrilateral Surface
            if ~quad_plotted
                % First quadrilateral gets a legend entry
                fill(quad_coords(:,1), quad_coords(:,2), 'cyan', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'b', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surface');
                quad_plotted = true; % Mark as plotted
            else
                % Subsequent surfaces are hidden from the legend
                fill(quad_coords(:,1), quad_coords(:,2), 'cyan', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'b', 'LineWidth', 1.2, 'HandleVisibility', 'off');
            end
        else
            warning('Quadrilateral surface %d does not have exactly 4 nodes.', i);
        end
    end
end

    %% Plot Triangular Surfaces
tri_plotted = false; % Flag to track if legend entry was added

if ~isempty(tri_surfaces)
    for i = 1:size(tri_surfaces, 1)
        % Get Node Coordinates
        tri_coords = nodes(ismember(nodes(:,5), tri_surfaces(i,:)), 1:2);
        if size(tri_coords, 1) == 3
            if ~tri_plotted
                % First triangular surface gets a legend entry
                fill(tri_coords(:,1), tri_coords(:,2), 'magenta', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'r', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');
                tri_plotted = true; % Mark as plotted
            else
                % Subsequent surfaces are hidden from the legend
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
        [filePath, fileName, ext] = fileparts(savePath);
        if isempty(ext)
            saveas(fig, fullfile(filePath, [fileName, '.png']));
            savefig(fig, fullfile(filePath, [fileName, '.fig']));
        else
            saveas(fig, savePath);
        end
        fprintf('✅ Verification plot saved to: %s\n', savePath);
    else
        fprintf('⚠️ No savePath provided. Plot not saved.\n');
    end
    
    close(fig); % Optional: Prevent plot clutter in MATLAB GUI
end
