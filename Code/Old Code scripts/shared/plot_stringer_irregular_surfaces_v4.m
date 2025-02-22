function plot_stringer_irregular_surfaces_v4(combined_nodes, inserted_table, quad_surfaces_irregular, tri_surfaces, penta_surfaces, plottitle, plotfilename, avion, datosEstructural)
% plot_stringer_irregular_surfaces_v4: Visualizes stringer surfaces (irregular zones), including triangular, quadrilateral, and pentagonal surfaces.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional nodes (for inserted points).
%   quad_surfaces_irregular: Table with quadrilateral surface properties and metadata.
%   tri_surfaces: Table with triangular surface properties and metadata.
%   penta_surfaces: Table with pentagonal surface properties and metadata (added in v4).
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%   avion, datosEstructural: Structs for geometric and structural data (used for plot styling).
%
% Output:
%   A plot visualizing the specified surfaces (triangular, quadrilateral, and pentagonal).

    %% 🎯 Initialize Plot
    fig = figure('Name', 'Stringer Surface Verification Plot', 'NumberTitle', 'off');
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

    %% 🔵 Plot Quadrilateral Surfaces
    if ~isempty(quad_surfaces_irregular)
        for i = 1:height(quad_surfaces_irregular)
            % Extract nodes for the quadrilateral surface
            node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
            node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
            node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
            node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping quadrilateral surface %d due to missing nodes.', i);
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
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'Quadrilateral Surface');
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

            % Extract coordinates for the triangular surface
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];

            % Plot the triangular surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
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
            if isempty(node_1) || isempty(node_2) || isempty(node_
