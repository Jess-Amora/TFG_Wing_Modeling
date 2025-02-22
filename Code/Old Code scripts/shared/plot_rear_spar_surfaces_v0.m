function plot_rear_spar_surfaces_v0(combined_nodes, superficie_horizontal_larguero_posterior, folder)
% plot_rear_spar_surfaces: Verifies and visualizes rear spar surfaces.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   superficie_horizontal_larguero_posterior: Table with columns:
%       - local_id: Unique surface identifier
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface
%       - rib_1, rib_2: Ribs defining the surface
%       - stringer_1, stringer_2: Stringers defining the surface
%       - tags: Surface type (e.g., 'rear_spar_surface')
%       - area: Precomputed area of the surface
%       - aspect_ratio: Aspect ratio of the surface
%   plottitle: Custom title for the plot (string)
%   plotfilename: Path to save the resulting plot

    %% 🎯 Initialization
    fig = figure('Name', 'Rear Spar Surface Verification Plot', 'NumberTitle', 'off');
    hold on;
    axis equal;
    grid on;
    title('Plot rear spar 2D quad'); % Use the custom title from input
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    
    %% 🟢 Plot General Nodes
    plot(combined_nodes.x, combined_nodes.y, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Combined Nodes');
    
    % Add Node Labels (Optional for Debugging)
    for i = 1:height(combined_nodes)
        text(combined_nodes.x(i), combined_nodes.y(i), sprintf('%d', combined_nodes.local_id(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
    end
    
    %% 🔵 Plot Rear Spar Surfaces
    if ~isempty(superficie_horizontal_larguero_posterior)
        for i = 1:height(superficie_horizontal_larguero_posterior)
            % Extract node coordinates by matching local_id
            node_ids = [superficie_horizontal_larguero_posterior.node_1(i), ...
                        superficie_horizontal_larguero_posterior.node_2(i), ...
                        superficie_horizontal_larguero_posterior.node_3(i), ...
                        superficie_horizontal_larguero_posterior.node_4(i)];
            
            % Rear spar nodes: node_1 and node_4
            rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars') & ...
                                              ismember(combined_nodes.local_id, [node_ids(1), node_ids(4)]), {'local_id', 'x', 'y'});
            
            % Stringer nodes: node_2 and node_3 (stringer_index == 1)
            stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & ...
                                              combined_nodes.stringer_index == 1 & ...
                                              ismember(combined_nodes.local_id, [node_ids(2), node_ids(3)]), {'local_id', 'x', 'y'});

            % Combine nodes in order: node_1 -> node_2 -> node_3 -> node_4
            ordered_nodes = [
                rear_spar_nodes(rear_spar_nodes.local_id == node_ids(1), :); % node_1 (rear spar, rib 1)
                stringer_nodes(stringer_nodes.local_id == node_ids(2), :);   % node_2 (stringer, rib 1)
                stringer_nodes(stringer_nodes.local_id == node_ids(3), :);   % node_3 (stringer, rib 2)
                rear_spar_nodes(rear_spar_nodes.local_id == node_ids(4), :)  % node_4 (rear spar, rib 2)
            ];

            % Ensure quadrilateral has four nodes
            if height(ordered_nodes) == 4
                % Plot the quadrilateral surface
                fill(ordered_nodes.x, ordered_nodes.y, 'cyan', 'FaceAlpha', 0.3, ...
                     'EdgeColor', 'b', 'LineWidth', 1.5, 'DisplayName', 'Rear Spar Surface');

                % Optional: Add metadata as text annotations
                center_x = mean(ordered_nodes.x);
                center_y = mean(ordered_nodes.y);
                annotation_text = sprintf('Local id: %.2f', ...
                    superficie_horizontal_larguero_posterior.local_id(i));
                text(center_x, center_y, annotation_text, 'FontSize', 8, ...
                     'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
            end
        end
    else
        warning('No rear spar surfaces available to plot.');
    end

    %% 📌 Legend and Styling
    legend({'Combined Nodes', 'Rear Spar Surfaces'}, 'Location', 'best');
    hold off;
    
    % Save to Figures folder
    if isfield(folder, 'figures') && ~isempty(folder.figures)
        if ~isfolder(folder.figures)
            mkdir(folder.figures);
            disp(['📁 Created folder: ', folder.figures]);
        end

        saveas(fig, fullfile(folder.figures, 'Step_4_rear_spar_quad_2D.png'));
        saveas(fig, fullfile(folder.figures, 'Step_4_rear_spar_quad_2D.fig'));
        disp(['📊 Saved plot to: ', fullfile(folder.figures, 'Step_4_rear_spar_quad_2D.png')]);
    end

    close(fig); % Optional: Close the figure to avoid clutter
end
