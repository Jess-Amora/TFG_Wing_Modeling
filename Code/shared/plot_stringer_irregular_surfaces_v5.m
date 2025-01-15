function plot_stringer_irregular_surfaces_v5(combined_nodes, inserted_table, quad_surfaces, tri_surfaces, penta_surfaces, plottitle, plotfilename, avion, datosEstructural)
% plot_stringer_irregular_surfaces_v5: Visualizes stringer surfaces (triangular, quadrilateral, and pentagonal surfaces) for the wing model.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional nodes (for inserted points).
%   quad_surfaces: Table for quadrilateral surfaces (regular, irregular, root, etc.).
%   tri_surfaces: Table for triangular surfaces (regular, root, etc.).
%   penta_surfaces: Table for pentagonal surfaces (root, etc.).
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%   avion, datosEstructural: Structs for geometric and structural data (used for plot styling).

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
            surface_tag = quad_surfaces.tags(i);

            % Extract nodes for the quadrilateral surface
            node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :);
            node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :);

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping quadrilateral surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];

            % Define color based on surface tag
            if contains(surface_tag, 'regular')
                face_color = 'magenta'; % Regular quads
            elseif contains(surface_tag, 'irregular')
                face_color = 'yellow'; % Irregular quads
            elseif contains(surface_tag, 'root')
                face_color = 'orange'; % Root-specific quads
            else
                face_color = 'white'; % Default (if unknown tag)
            end

            % Plot the quadrilateral surface
            fill(surface_coords(:, 1), surface_coords(:, 2), face_color, 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
        end
    end

    %% 🔺 Plot Triangular Surfaces
    if ~isempty(tri_surfaces)
        for i = 1:height(tri_surfaces)
            % Extract nodes for the triangular surface
            node_1 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_3(i), :);

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warning('Skipping triangular surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];

            % Define color based on tag
            if contains(tri_surfaces.tags(i), 'root')
                face_color = 'cyan'; % Root triangles
            else
                face_color = 'blue'; % General triangles
            end

            % Plot the triangular surface
            fill(surface_coords(:, 1), surface_coords(:, 2), face_color, 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'Triangular Surface');
        end
    end

    %% 🔶 Plot Pentagonal Surfaces
    if ~isempty(penta_surfaces)
        for i = 1:height(penta_surfaces)
            % Extract nodes for the pentagonal surface
            node_1 = combined_nodes(combined_nodes.local_id == penta_surfaces.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == penta_surfaces.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.local_id == penta_surfaces.node_3(i), :);
            node_4 = combined_nodes(combined_nodes.local_id == penta_surfaces.node_4(i), :);
            node_5 = combined_nodes(combined_nodes.local_id == penta_surfaces.node_5(i), :);

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4) || isempty(node_5)
                warning('Skipping pentagonal surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates for the surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y;
                node_5.x, node_5.y
            ];

            % Plot the pentagonal surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'green', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'Pentagonal Surface');
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
