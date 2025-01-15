function plot_stringer_irregular_surfaces_v8(combined_nodes, inserted_table, quad_surfaces, tri_surfaces, penta_surfaces, plottitle, plotfilename)
% plot_stringer_irregular_surfaces_v8: Visualizes stringer surfaces with logic for irregular surfaces ("tri", "quad irregular", etc.).
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   quad_surfaces: Table for quadrilateral surfaces (irregular, P1 inserted, P4 inserted, etc.).
%   tri_surfaces: Table for triangular surfaces.
%   penta_surfaces: Table for pentagonal surfaces.
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%
% Output:
%   A plot visualizing the specified surfaces (triangular, quadrilateral, and pentagonal).

    %% 🎯 Initialize Plot
    fig = figure('Name', 'Wing Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');

    %% 🟢 Plot Nodes
    % Identify node tags
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars');
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');
    stringer_idx = strcmp(combined_nodes.tag, 'stringer');

    % Plot nodes with unique markers and colors
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');
    plot(combined_nodes.x(stringer_idx), combined_nodes.y(stringer_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');

    %% 🔵 Plot Quadrilateral Surfaces
    if ~isempty(quad_surfaces)
        for i = 1:height(quad_surfaces)
            % Extract surface tag
            surface_tag = quad_surfaces.tags(i);

            % Tag-specific logic for quad surfaces
            switch surface_tag
                case "quad irregular"
                    % Extract nodes for "quad irregular"
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :); % Bottom-left
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :); % Bottom-right
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :); % Top-right
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :); % Top-left

                case "quad irregular P1 inserted"
                    % Extract nodes for "quad irregular P1 inserted"
                    node_1 = inserted_table(inserted_table.local_id == quad_surfaces.node_1(i), :); % Bottom-left (from inserted nodes)
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :); % Bottom-right
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :); % Top-right
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :); % Top-left

                case "quad irregular P4 inserted"
                    % Extract nodes for "quad irregular P4 inserted"
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :); % Bottom-left
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :); % Bottom-right
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :); % Top-right
                    node_4 = inserted_table(inserted_table.local_id == quad_surfaces.node_4(i), :); % Top-left (from inserted nodes)

                otherwise
                    warning('Unknown quadrilateral surface tag: %s. Skipping surface %d.', surface_tag, i);
                    continue;
            end

            % Validate nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping quadrilateral surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];

            % Plot the quadrilateral surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'magenta', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
        end
    end

    %% 🔺 Plot Triangular Surfaces
    if ~isempty(tri_surfaces)
        for i = 1:height(tri_surfaces)
            % Extract nodes for the triangular surface
            node_1 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_1(i), :); % Bottom-left
            node_2 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_2(i), :); % Bottom-right
            node_3 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_3(i), :); % Top

            % Validate nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warning('Skipping triangular surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];

            % Plot the triangular surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'tri');
        end
    end

    %% 🔶 Plot Pentagonal Surfaces
    if ~isempty(penta_surfaces)
        for i = 1:height(penta_surfaces)
            % Extract nodes for the pentagonal surface
            node_1 = combined_nodes( ...
                combined_nodes.rib_index == -1 & ...
                combined_nodes.stringer_index == penta_surfaces.stringer_1(i), :); % Bottom-left
            
            node_2 = combined_nodes( ...
                combined_nodes.rib_index == penta_surfaces.rib_1(i) - 1 & ...
                strcmp(combined_nodes.tag, 'rear spars'), :); % Bottom-right
            
            node_3 = combined_nodes( ...
                combined_nodes.rib_index == penta_surfaces.rib_1(i) - 1 & ...
                combined_nodes.stringer_index == penta_surfaces.stringer_2(i), :); % Top-right
            
            node_4 = combined_nodes( ...
                combined_nodes.rib_index == penta_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == penta_surfaces.stringer_2(i), :); % Top-left
            
            node_5 = combined_nodes( ...
                combined_nodes.rib_index == penta_surfaces.rib_2(i) & ...
                combined_nodes.stringer_index == penta_surfaces.stringer_1(i), :); % Top

            % Validate nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4) || isempty(node_5)
                warning('Skipping pentagonal surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y;
                node_5.x, node_5.y
            ];

            % Plot the pentagonal surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'yellow', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'penta');
        end
    end

    %% 📌 Legend and Final Styling
    legend('Location', 'best');
    hold off;

    %% 💾 Save Plot
    if exist('plotfilename', 'var') && ~isempty(plotfilename)
        saveas(fig, sprintf('%s.png', plotfilename));
        savefig(fig, sprintf('%s.fig', plotfilename));
    end

    disp('✅ Plotting complete and saved successfully.');
end
