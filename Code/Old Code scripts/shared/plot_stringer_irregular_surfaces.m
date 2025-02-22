function plot_stringer_irregular_surfaces(combined_nodes, inserted_table, quad_surfaces_irregular, plottitle, plotfilename, avion, datosEstructural)
% plot_stringer_irregular_surfaces: Visualizes stringer surfaces (irregular zones).
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   inserted_table: Table with additional nodes (for inserted points).
%   quad_surfaces_irregular: Table with irregular surface properties and metadata.
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%   avion, datosEstructural: Structs for geometric and structural data (used for plot styling).

    %% 🎯 Initialize Plot
    fig = figure('Name', 'Stringer Irregular Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');

    %% 🟢 Plot Combined Nodes with Color Codes for Spars
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars'); % Front spar nodes
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');   % Rear spar nodes
    stringers_idx = strcmp(combined_nodes.tag, 'stringer');     % Stringer nodes

    % Plot Front Spar Nodes in Red
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');

    % Plot Rear Spar Nodes in Blue
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');

    % Plot Stringer Nodes in Black
    plot(combined_nodes.x(stringers_idx), combined_nodes.y(stringers_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:height(combined_nodes)
        text(combined_nodes.x(i), combined_nodes.y(i), sprintf('%d', combined_nodes.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end

    %% 🔵 Plot Quadrilateral Surfaces for Different Tags
    if ~isempty(quad_surfaces_irregular)
        for i = 1:height(quad_surfaces_irregular)
            % Determine nodes based on the surface tag
            surface_tag = quad_surfaces_irregular.tags(i);

            if strcmp(surface_tag, "quad irregular P1 inserted")
                % P1 from inserted_table, other nodes from combined_nodes
                node_1 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.stringer_index == quad_surfaces_irregular.stringer_2(i) & combined_nodes.rib_index ==-2, :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

            elseif strcmp(surface_tag, "quad irregular P4 inserted")
                % P4 from inserted_table, other nodes from combined_nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                node_3 = combined_nodes(combined_nodes.stringer_index == quad_surfaces_irregular.stringer_2(i) & combined_nodes.rib_index ==-2, :);
                node_4 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_4(i), :);

            elseif strcmp(surface_tag, "quad irregular")
                % P2 and P3 from front spar nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i) & strcmp(combined_nodes.tag, 'front spars'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);
            elseif strcmp(surface_tag, "quad regular")
                % P2 and P3 from front spar nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i)& strcmp(combined_nodes.tag, 'stringer'), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i)& strcmp(combined_nodes.tag, 'stringer'), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i)& strcmp(combined_nodes.tag, 'stringer'), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i)& strcmp(combined_nodes.tag, 'stringer'), :);

            else
                % Unknown tag, skip this surface
                warning('Unknown surface tag: %s. Skipping surface %d.', surface_tag, i);
                continue;
            end

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the quadrilateral surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];

            % Plot the quadrilateral surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'magenta', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);

            % Optional: Add metadata as text annotations
            center_x = mean(surface_coords(:, 1));
            center_y = mean(surface_coords(:, 2));
            % annotation_text = sprintf('Area: %.2f\nAspect: %.2f', ...
            %     quad_surfaces_irregular.area(i), ...
            %     quad_surfaces_irregular.aspect_ratio(i));
            % text(center_x, center_y, annotation_text, 'FontSize', 8, ...
            %      'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
        end
    else
        warning('No irregular stringer surfaces available to plot.');
    end

    %% 📌 Legend and Final Styling
    legend('Location', 'best');
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

    disp('✅ Stringer irregular surfaces plot completed and saved successfully.');
end
