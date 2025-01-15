function plot_stringer_irregular_surfaces_v9(combined_nodes, inserted_table, quad_surfaces, tri_surfaces, penta_surfaces, rear_surfaces, plottitle, plotfilename)
% plot_stringer_irregular_surfaces_v9: Visualizes stringer surfaces with logic for irregular, triangular, pentagonal, and rear spar surfaces.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   quad_surfaces: Table for quadrilateral surfaces (irregular, P1 inserted, P4 inserted, etc.).
%   tri_surfaces: Table for triangular surfaces.
%   penta_surfaces: Table for pentagonal surfaces.
%   rear_surfaces: Table for "quad rear" surfaces created near the rear spar.
%   plottitle: Custom title for the plot (string).
%   plotfilename: Path to save the resulting plot (optional).
%
% Output:
%   A plot visualizing the specified surfaces (triangular, quadrilateral, pentagonal, and rear spar).

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
        % Extract surface tag
        surface_tag = tri_surfaces.tags(i);

        % Tag-specific logic for triangular surfaces
        switch surface_tag
            case "tri front"
                % Extract nodes for "tri front"
                node_1 = combined_nodes( ...
                    combined_nodes.rib_index == -2 & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_1(i), :); % Bottom-left
                
                node_2 = find_max_rib_node(combined_nodes, tri_surfaces.stringer_1(i)); % Bottom-right
                
                node_3 = combined_nodes( ...
                    combined_nodes.rib_index == node_2.rib_index & ...
                    strcmp(combined_nodes.tag, 'front spars'), :); % Top (on front spar)

                % Assign color for "tri front"
                fill_color = [0, 1, 1]; % Cyan

            case "tri root"
                % Extract nodes for "tri root"
                node_1 = combined_nodes( ...
                    combined_nodes.rib_index == -1 & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_1(i), :); % Bottom-left
                
                node_2 = combined_nodes( ...
                    combined_nodes.rib_index == tri_surfaces.rib_2(i) - 1 & ...
                    strcmp(combined_nodes.tag, 'rear spars'), :); % Bottom-right
                
                node_3 = combined_nodes( ...
                    combined_nodes.rib_index == -1 & ...
                    combined_nodes.stringer_index == tri_surfaces.stringer_2(i), :); % Top

                % Assign color for "tri root"
                fill_color = [1, 0.5, 0]; % Orange

            otherwise
                warning('Unknown triangular surface tag: %s. Skipping surface %d.', surface_tag, i);
                continue;
        end

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
        fill(surface_coords(:, 1), surface_coords(:, 2), fill_color, 'FaceAlpha', 0.3, ...
             'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', surface_tag);
    end
else
    warning('No triangular surfaces found to plot.');
end




    %% 🔶 Plot Rear Spar Surfaces ("quad rear")
    if ~isempty(rear_surfaces)
        for i = 1:height(rear_surfaces)
            % Extract nodes for the rear spar surface
            rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'), :);
            stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1, :);
            
            % Ensure rear spar and stringer nodes are present
            if isempty(rear_spar_nodes) || isempty(stringer_nodes)
                warning('No valid rear spar or stringer nodes found for rear spar surface %d. Skipping.', i);
                continue;
            end
    
            % Extract nodes for the current rib
            a1 = rear_surfaces.rib_1(i);
            a2 = rear_surfaces.rib_2(i);
            a3 = rear_surfaces.rib_1(i);
            a4 = rear_surfaces.rib_2(i);
             
            rear_spar_rib1 = rear_spar_nodes(rear_spar_nodes.rib_index == a1, :); % Rear spar at rib 1
            rear_spar_rib2 = rear_spar_nodes(rear_spar_nodes.rib_index == a2, :); % Rear spar at rib 2
            stringer_rib1 = stringer_nodes(stringer_nodes.rib_index == a3, :);    % Stringer at rib 1
            stringer_rib2 = stringer_nodes(stringer_nodes.rib_index == a4, :);    % Stringer at rib 2
    
            % Ensure all four nodes are present
            if isempty(rear_spar_rib1) || isempty(rear_spar_rib2) || isempty(stringer_rib1) || isempty(stringer_rib2)
                warning('Skipping rear spar surface %d: Insufficient nodes for ribs %d and %d.', i, rear_surfaces.rib_1(i), rear_surfaces.rib_2(i));
                continue;
            end
    
            % Extract Node Coordinates
            surface_coords = [
                rear_spar_rib1.x(1), rear_spar_rib1.y(1); % Node 1 (rear spar, rib 1)
                stringer_rib1.x(1), stringer_rib1.y(1);   % Node 2 (stringer, rib 1)
                stringer_rib2.x(1), stringer_rib2.y(1);   % Node 3 (stringer, rib 2)
                rear_spar_rib2.x(1), rear_spar_rib2.y(1)  % Node 4 (rear spar, rib 2)
            ];
    
            % Plot the rear spar surface
            fill(surface_coords(:, 1), surface_coords(:, 2), 'yellow', 'FaceAlpha', 0.5, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', 'quad rear');
        end
    else
        warning('No rear spar surfaces found to plot.');
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
