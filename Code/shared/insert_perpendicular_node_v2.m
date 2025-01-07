function updated_node_vector = insert_perpendicular_node_v3(node_vector, slope, point, ribs_total)
% Updated Function to insert a node into a 1xNx4 node vector based on geometry and slope.
% Rib and Stringer indices are now inferred directly from the node vector.

% Inputs:
%   node_vector: 1xNx4 matrix of node data [x, y, rib_index, stringer_index]
%   slope: Desired slope of the rear spar
%   point: Coordinates of the new perpendicular node [x, y]
%   ribs_total: Number of ribs (nodes) from the end to check

% Outputs:
%   updated_node_vector: 1x(N+1)x4 matrix with the new node inserted in order

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

    %% Initialization
    num_nodes = size(node_vector, 2);
    start_idx = max(1, num_nodes - ribs_total); % Ensure bounds are not exceeded
    insert_idx = -1; % Default to no insertion

    %% Loop Through the Last `ribs_total` Node Pairs
    for i = start_idx:num_nodes-1
        % Extract two consecutive nodes
        node1 = squeeze(node_vector(1, i, 1:2))'; % [x, y]
        node2 = squeeze(node_vector(1, i+1, 1:2))';

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
        rib_index = node_vector(1, insert_idx, 3); % Rib index from nearest node
        stringer_index = node_vector(1, insert_idx, 4); % Stringer index from nearest node
    else
        % Use the last node's rib and stringer indices as fallback
        rib_index = node_vector(1, end, 3);
        stringer_index = node_vector(1, end, 4);
    end

    %% Prepare the Updated Node Vector
    new_node = reshape([point(1), point(2), rib_index, stringer_index], [1, 1, 4]);

    if insert_idx > 0
        % Insert at the determined index
        updated_node_vector = [
            node_vector(:, 1:insert_idx, :), ... % Nodes before insertion
            new_node, ... % Insert new node
            node_vector(:, insert_idx+1:end, :) % Nodes after insertion
        ];
        disp('Node successfully inserted into node vector.');
    else
        % If no valid insertion point, append at the end
        updated_node_vector = [
            node_vector, ...
            new_node % Append node at the end
        ];
        warning('No valid segment found. Node appended at the end.');
    end
end
