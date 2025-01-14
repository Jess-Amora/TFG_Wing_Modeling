function combined_nodes_modified = add_singular_rib(combined_nodes, point_1, point_2, rib_index, tag)
% add_singular_rib: Adds a single rib to the combined_nodes table by calculating intersections
%                   with existing stringers and the line defined by point_1 and point_2.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   point_1: 2x1 array representing [x, y] coordinates of the first point of the rib.
%   point_2: 2x1 array representing [x, y] coordinates of the second point of the rib.
%   rib_index: Rib index for the new rib.
%   tag: Tag for the constructed nodes (e.g., 'constructed').
%
% Output:
%   combined_nodes_modified: Updated table with added constructed nodes for the new rib.

    %% 📝 Initialization
    combined_nodes_modified = combined_nodes; % Copy input table for modification
    warnings = {};
    added_nodes = zeros(0, 2); % Initialize with correct dimensions (empty 2-column array)

    % Find the largest local_id for constructed nodes
    constructed_nodes = combined_nodes(strcmp(combined_nodes.tag, 'constructed'), :);
    if isempty(constructed_nodes)
        next_local_id = max(combined_nodes.local_id) + 1; % Start after the highest ID
    else
        next_local_id = max(constructed_nodes.local_id) + 1; % Start after the highest constructed ID
    end

    % Extract coordinates for the rib line
    x1 = point_1(1); y1 = point_1(2);
    x2 = point_2(1); y2 = point_2(2);

    % Calculate the slope (m) and intercept (b) of the rib line
    if abs(x2 - x1) < 1e-8
        m_rib = Inf; % Vertical line
        b_rib = x1;  % x-intercept for vertical line
    else
        m_rib = (y2 - y1) / (x2 - x1); % Slope
        b_rib = y1 - m_rib * x1;      % y-intercept
    end

    %% 🔍 Process Each Stringer
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);
    unique_stringers = unique(stringer_nodes.stringer_index);

    for stringer_idx = unique_stringers'
        % Extract nodes for the current stringer
        stringer_points = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        % Ensure the stringer has enough nodes to define a line segment
        if height(stringer_points) < 2
            warnings{end+1} = sprintf('Skipping stringer %d due to insufficient nodes.', stringer_idx);
            continue;
        end

        % Iterate over pairs of stringer points (segments)
        for i = 1:height(stringer_points) - 1
            % Define the segment line (stringer)
            p1_stringer = stringer_points(i, :);
            p2_stringer = stringer_points(i + 1, :);
            x3 = p1_stringer.x; y3 = p1_stringer.y;
            x4 = p2_stringer.x; y4 = p2_stringer.y;

            if abs(x4 - x3) < 1e-8
                m_stringer = Inf; % Vertical stringer segment
                b_stringer = x3; % x-intercept for vertical line
            else
                m_stringer = (y4 - y3) / (x4 - x3); % Slope
                b_stringer = y3 - m_stringer * x3; % y-intercept
            end

            % Calculate the intersection using the provided function
            cortes = cortes_de_dos_funciones_lineales_v3([x1, y1], m_rib, [x3, y3; x4, y4], m_stringer);

           % Round intersection points to 8 decimal places
            intersection_x = round(cortes(1, 1, 1), 8);
            intersection_y = round(cortes(1, 1, 2), 8);
            
            % Verify the intersection is within the segment bounds
            if (intersection_x >= min(x3, x4) && intersection_x <= max(x3, x4)) && ...
               (intersection_y >= min(y3, y4) && intersection_y <= max(y3, y4))
                % Check if the node is already added
                if ~ismember([intersection_x, intersection_y], added_nodes, 'rows')
                    % Add the intersection as a constructed node
                    combined_nodes_modified = [combined_nodes_modified; table( ...
                        next_local_id, intersection_x, intersection_y, rib_index, ...
                        stringer_idx, string(tag), ... % Ensure tag is a string
                        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'})];
                    added_nodes = [added_nodes; intersection_x, intersection_y]; % Track added node
                    next_local_id = next_local_id + 1;
                end
            end

        end
    end

    %% ✅ Output Results
    if ~isempty(warnings)
        disp('Warnings:');
        disp(warnings);
    end

    disp('Singular rib added successfully.');
end
