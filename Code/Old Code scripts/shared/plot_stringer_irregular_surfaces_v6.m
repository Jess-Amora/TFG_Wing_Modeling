function plot_stringer_irregular_surfaces_v6(combined_nodes, inserted_table, quad_surfaces, tri_surfaces, penta_surfaces, plottitle, plotfilename, avion, datosEstructural)
% plot_stringer_irregular_surfaces_v6: Visualizes stringer surfaces with tag-specific plotting logic.
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
%
% Output:
%   A plot visualizing the specified surfaces (triangular, quadrilateral, and pentagonal) with custom logic per tag.

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

            % Tag-specific logic
            switch surface_tag
                case "quad regular"
                    % Logic for "quad regular" surfaces
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);
                case "quad irregular"
                    % Logic for "quad irregular" surfaces
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

                case "quad irregular P1 inserted"
                    % Logic for "quad irregular P1 inserted"
                    node_1 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

                case "quad irregular P4 inserted"
                    % Logic for "quad irregular P4 inserted"
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :);
                    node_4 = inserted_table(inserted_table.local_id == quad_surfaces.node_4(i), :);

                case "quad irregular root"
                    % Logic for "quad irregular root"
                    node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_3(i), :);
                    node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces.node_4(i), :);

                otherwise
                    warning('Unknown quadrilateral surface tag: %s. Skipping surface %d.', surface_tag, i);
                    continue;
            end

            % Ensure nodes are valid
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

            % Plot the surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'magenta', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
        end
    end

    %% 🔺 Plot Triangular Surfaces
    if ~isempty(tri_surfaces)
        for i = 1:height(tri_surfaces)
            % Extract surface tag
            surface_tag = tri_surfaces.tags(i);

            % Tag-specific logic
            switch surface_tag
                case "tri"
                    % Logic for "tri"
                    node_1 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_3(i), :);

                case "tri root"
                    % Logic for "tri root"
                    node_1 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_1(i), :);
                    node_2 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_2(i), :);
                    node_3 = combined_nodes(combined_nodes.local_id == tri_surfaces.node_3(i), :);

                otherwise
                    warning('Unknown triangular surface tag: %s. Skipping surface %d.', surface_tag, i);
                    continue;
            end

            % Ensure nodes are valid
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

            % Plot the surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'cyan', 'FaceAlpha', 0.3, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
        end
    end

    %% 🔶 Plot Pentagonal Surfaces
    if ~isempty(penta_surfaces)
        for i = 1:height(penta_surfaces)
            % Logic for pentagonal surfaces using P_1, P_2, P_3, P_4, P_5
            stringer_index = penta_surfaces.stringer_index(i);
            
            % Extract relevant nodes for the current and next stringers
            current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);
            next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1, :);
            
            start_rib = penta_surfaces.start_rib(i); % Extract start rib for this pentagonal surface
            
            % Define P_1 to P_5 (logic provided)
            P_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
            P_2 = combined_nodes(combined_nodes.tag == "rear spars" & combined_nodes.rib_index == start_rib - 1, :); % Bottom-right
            P_3 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib - 1, :); % Top-right
            P_4 = next_stringer_nodes(next_stringer_nodes.rib_index == start_rib, :); % Top-left
            P_5 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :); % Close to rear spar
            
            % Ensure nodes are valid
            if isempty(P_1) || isempty(P_2) || isempty(P_3) || isempty(P_4) || isempty(P_5)
                warning('Skipping pentagonal surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates
            surface_coords = [
                P_1.x, P_1.y;
                P_2.x, P_2.y;
                P_3.x, P_3.y;
                P_4.x, P_4.y;
                P_5.x, P_5.y
            ];

            % Plot the pentagonal surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'yellow', 'FaceAlpha', 0.3, ...
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
