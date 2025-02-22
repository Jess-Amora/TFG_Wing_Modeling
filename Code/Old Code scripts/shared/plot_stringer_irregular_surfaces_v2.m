function plot_stringer_irregular_surfaces_v2(combined_nodes, inserted_table, quad_surfaces_irregular, plottitle, plotfilename, avion, datosEstructural)
% Improved function to visualize irregular quadrilateral surfaces with distinct styles and non-redundant legends.

    %% 🎯 Initialize Plot
    fig = figure('Name', 'Stringer Irregular Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title(plottitle, 'Interpreter', 'none');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');

    %% 🟢 Plot Combined Nodes
    front_spar_idx = strcmp(combined_nodes.tag, 'front spars');
    rear_spar_idx = strcmp(combined_nodes.tag, 'rear spars');
    stringers_idx = strcmp(combined_nodes.tag, 'stringer');

    % Plot Front Spar Nodes in Red
    plot(combined_nodes.x(front_spar_idx), combined_nodes.y(front_spar_idx), ...
         'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'DisplayName', 'Front Spar Nodes');

    % Plot Rear Spar Nodes in Blue
    plot(combined_nodes.x(rear_spar_idx), combined_nodes.y(rear_spar_idx), ...
         'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'DisplayName', 'Rear Spar Nodes');

    % Plot Stringer Nodes in Black
    plot(combined_nodes.x(stringers_idx), combined_nodes.y(stringers_idx), ...
         'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Stringer Nodes');

    %% 🔵 Plot Quadrilateral Surfaces for Each Tag
    if ~isempty(quad_surfaces_irregular)
        % Initialize flags for legend
        legend_flags = struct('quad_irregular', false, 'P1_inserted', false, 'P4_inserted', false);

        for i = 1:height(quad_surfaces_irregular)
            % Determine nodes based on the surface tag
            surface_tag = quad_surfaces_irregular.tags(i);
            if strcmp(surface_tag, "quad irregular P1 inserted")
                % Style for P1 inserted
                color = 'magenta';
                alpha = 0.4;
                if ~legend_flags.P1_inserted
                    legend_label = 'P1 Inserted Surfaces';
                    legend_flags.P1_inserted = true;
                else
                    legend_label = ''; % No label for subsequent surfaces
                end
                % Node selection
                node_1 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

            elseif strcmp(surface_tag, "quad irregular P4 inserted")
                % Style for P4 inserted
                color = 'cyan';
                alpha = 0.3;
                if ~legend_flags.P4_inserted
                    legend_label = 'P4 Inserted Surfaces';
                    legend_flags.P4_inserted = true;
                else
                    legend_label = ''; % No label for subsequent surfaces
                end
                % Node selection
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                node_4 = inserted_table(inserted_table.local_id == quad_surfaces_irregular.node_4(i), :);

            elseif strcmp(surface_tag, "quad irregular")
                % Style for regular quadrilaterals
                color = 'yellow';
                alpha = 0.2;
                if ~legend_flags.quad_irregular
                    legend_label = 'Irregular Quadrilateral Surfaces';
                    legend_flags.quad_irregular = true;
                else
                    legend_label = ''; % No label for subsequent surfaces
                end
                % Node selection
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);
            elseif strcmp(surface_tag, "quad regular")
                % Style for regular quadrilaterals
                color = 'blue';
                alpha = 0.2;
                if ~legend_flags.quad_irregular
                    legend_label = 'regular Quadrilateral Surfaces';
                    legend_flags.quad_irregular = true;
                else
                    legend_label = ''; % No label for subsequent surfaces
                end
                % P2 and P3 from front spar nodes
                node_1 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_1(i), :);
                node_2 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_2(i), :);
                node_3 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_3(i), :);
                node_4 = combined_nodes(combined_nodes.local_id == quad_surfaces_irregular.node_4(i), :);

            else
                % Skip unknown tags
                warning('Unknown surface tag: %s. Skipping surface %d.', surface_tag, i);
                continue;
            end

            % Ensure nodes are valid
            if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
                warning('Skipping surface %d due to missing nodes.', i);
                continue;
            end

            % Extract coordinates
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y;
                node_4.x, node_4.y
            ];

            % Plot the quadrilateral
            fill(surface_coords(:, 1), surface_coords(:, 2), color, 'FaceAlpha', alpha, ...
                 'EdgeColor', 'k', 'LineWidth', 1.2, 'DisplayName', legend_label);
        end
    else
        warning('No irregular surfaces available to plot.');
    end

    %% 📌 Finalize Plot
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

    disp('✅ Irregular quadrilateral surfaces plot completed and saved successfully.');
end
