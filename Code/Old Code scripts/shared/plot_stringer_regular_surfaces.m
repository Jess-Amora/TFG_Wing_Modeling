function plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular, plottitle, plotfilename)
% plot_stringer_regular_surfaces: Verifies and visualizes stringer surfaces (regular zones).
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   quad_surfaces_regular: Table with columns:
%       - local_id: Unique surface identifier
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface
%       - stringer_1, stringer_2: Stringers defining the surface
%       - rib_1, rib_2: Ribs defining the surface
%       - tags: Surface type (e.g., 'quad_regular')
%       - area: Area of the surface
%       - aspect_ratio: Aspect ratio of the surface
%   plottitle: Custom title for the plot (string)
%   plotfilename: Path to save the resulting plot (optional)

    %% 🎯 Initialization
    fig = figure('Name', 'Stringer Regular Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none'); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% 🟢 Plot Combined Nodes with Color Codes for Spars

    % Assuming 'combined_nodes' has a column 'type' with values 'front' or 'rear'
    % Example: combined_nodes.type = {'front', 'rear', 'front', ...};
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars'); % Logical index for front spar nodes
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');  % Logical index for rear spar nodes
    stringers_idx = strcmp(combined_nodes.tag, 'stringers');  % Logical index for rear spar nodes

    % Plot Front Spar Nodes in Red
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
    
    % Plot Rear Spar Nodes in Blue
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
    
    % Plot stringers Nodes in black
    plot(combined_nodes.x(stringers_idx), combined_nodes.y(stringers_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'stringers');

    % Add Node Labels (Optional for Debugging)
    for i = 1:height(combined_nodes)
        text(combined_nodes.x(i), combined_nodes.y(i), sprintf('%d', combined_nodes.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% 🟦 Plot Regular Quadrilateral Surfaces
    if ~isempty(quad_surfaces_regular)
        for i = 1:height(quad_surfaces_regular)
            % Extract node coordinates by matching local_id
            surface_nodes = combined_nodes(ismember(combined_nodes.local_id, ...
                [quad_surfaces_regular.node_1(i), ...
                 quad_surfaces_regular.node_2(i), ...
                 quad_surfaces_regular.node_3(i), ...
                 quad_surfaces_regular.node_4(i)]), {'local_id', 'x', 'y'});

            % Ensure nodes are ordered top-left, counterclockwise
            ordered_coords = [
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_1(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_1(i)); % Top-left (node_1)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_2(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_2(i)); % Lower-left (node_2)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_3(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_3(i)); % Lower-right (node_3)
                surface_nodes.x(surface_nodes.local_id == quad_surfaces_regular.node_4(i)), ...
                surface_nodes.y(surface_nodes.local_id == quad_surfaces_regular.node_4(i))  % Top-right (node_4)
            ];

            % Plot quadrilateral surface
            fill(ordered_coords(:, 1), ordered_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'b', 'LineWidth', 1.2);
            
            % Optional: Add metadata as text annotations
            center_x = mean(ordered_coords(:, 1));
            center_y = mean(ordered_coords(:, 2));
            annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
                quad_surfaces_regular.area(i), ...
                quad_surfaces_regular.aspect_ratio(i));
            text(center_x, center_y, annotation_text, 'FontSize', 8, ...
                 'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
        end
    else
        warning('No regular stringer surfaces available to plot.');
    end

    %% 📌 Legend and Styling
    legend({'Combined Nodes', 'Regular Quadrilateral Surfaces'}, 'Location', 'best');
    hold off;
    
    %% 💾 Save Plot
    if exist('plotfilename', 'var') && ~isempty(plotfilename)
        [fileDir, fileName, ~] = fileparts(plotfilename);
        if ~exist(fileDir, 'dir')
            mkdir(fileDir);
        end
        saveas(fig, fullfile(fileDir, sprintf('%s.png', fileName)));
        savefig(fig, fullfile(fileDir, sprintf('%s.fig', fileName)));
    end
    
    disp('✅ Stringer regular surfaces plot completed and saved successfully.');
end
