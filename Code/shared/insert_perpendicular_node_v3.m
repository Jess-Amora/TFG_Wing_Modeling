function updated_node_vector = insert_perpendicular_node_v3(node_vector, slope, point, ribs_total, tolerance_distance)
% Enhanced Function to handle close-node removal and perpendicular node insertion
%
% Inputs:
%   node_vector: 1xNx4 matrix of node data [x, y, rib_index, stringer_index]
%   slope: Desired slope of the rear spar
%   point: Coordinates of the new perpendicular node [x, y]
%   ribs_total: Number of ribs (nodes) from the end to check
%   tolerance_distance: Minimum distance to consider nodes as separate
%
% Outputs:
%   updated_node_vector: 1x(N+1)x4 matrix with updated nodes

    %% Validate Inputs
    if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 4
        error('Node vector must be a 1xNx4 matrix ([x, y, rib_index, stringer_index]).');
    end
    if numel(point) ~= 2
        error('Point must be a 1x2 vector [x, y].');
    end
    if ribs_total > size(node_vector, 2)
        error('ribs_total exceeds the number of available nodes.');
    end
    if ~isscalar(tolerance_distance) || tolerance_distance <= 0
        error('tolerance_distance must be a positive scalar.');
    end

    %% Initialization
    num_nodes = size(node_vector, 2);
    updated_node_vector = node_vector;

    %% Case 1: Check Distance Between Penultimate and Last Node
    if num_nodes > 1
        last_node = squeeze(node_vector(1, end, 1:2));
        penultimate_node = squeeze(node_vector(1, end-1, 1:2));

        % Calculate Euclidean distance
        distance = sqrt(sum((last_node - penultimate_node).^2));

        if distance < tolerance_distance
            % Remove the last node if too close to the penultimate node
            disp('🔄 Removing last node due to proximity to penultimate node.');
            updated_node_vector(:, end, :) = [];
            num_nodes = num_nodes - 1;
        end
    end

    %% Case 2: Insert a Perpendicular Node
    % Ensure we still have enough nodes after potential removal
    if num_nodes > 1
        % Default insertion index is at the end
        insert_idx = -1; 

        % Loop through the last `ribs_total` node pairs
        start_idx = max(1, num_nodes - ribs_total); 
        for i = start_idx:num_nodes-1
            % Extract two consecutive nodes
            node1 = squeeze(updated_node_vector(1, i, 1:2))'; % [x, y]
            node2 = squeeze(updated_node_vector(1, i+1, 1:2))';

            % Calculate slope between two nodes
            segment_slope = (node2(2) - node1(2)) / (node2(1) - node1(1));

            % Check slope match within tolerance
            if abs(segment_slope - slope) < 1e-5
                % Check if the point lies between the two nodes
                if point(1) > min(node1(1), node2(1)) && point(1) < max(node1(1), node2(1))
                    insert_idx = i; % Found correct segment
                    break;
                end
            end
        end

        %% Infer rib_index and stringer_index from nearest node
        if insert_idx > 0
            rib_index = updated_node_vector(1, insert_idx, 3); % Rib index from nearest node
            stringer_index = updated_node_vector(1, insert_idx, 4); % Stringer index from nearest node
        else
            % Use the last node's rib and stringer indices as fallback
            rib_index = updated_node_vector(1, end, 3);
            stringer_index = updated_node_vector(1, end, 4);
        end

        %% Add the Perpendicular Node
        new_node = reshape([point(1), point(2), rib_index, stringer_index], [1, 1, 4]);

        if insert_idx > 0
            % Insert at the determined index
            updated_node_vector = [
                updated_node_vector(:, 1:insert_idx, :), ... % Nodes before insertion
                new_node, ... % Insert new node
                updated_node_vector(:, insert_idx+1:end, :) % Nodes after insertion
            ];
            disp('✅ Perpendicular node inserted successfully.');
        else
            % If no valid insertion point, append at the end
            updated_node_vector = [
                updated_node_vector, ...
                new_node % Append node at the end
            ];
            warning('⚠️ No valid segment found. Node appended at the end.');
        end
    else
        warning('⚠️ Insufficient nodes to insert a perpendicular node.');
    end
end
