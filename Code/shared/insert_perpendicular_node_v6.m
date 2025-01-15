function [inserted_node, was_inserted] = insert_perpendicular_node_v6(...
    node_vector, slope, point, ribs_total, stringer_index)
% Inserts a node perpendicular to a segment defined by a stringer, ensuring proper tagging.
%
% Inputs:
%   node_vector: Nx5 matrix of node data [x, y, rib_index, stringer_index, tag].
%   slope: Desired slope of the rear spar.
%   point: Coordinates of the new perpendicular node [x, y].
%   ribs_total: Number of ribs to check for proximity.
%   stringer_index: Index of the stringer being processed.
%
% Outputs:
%   inserted_node: 1x5 vector [x, y, rib_index, stringer_index, tag].
%   was_inserted: Boolean indicating if the node was successfully inserted.

    %% Validate Inputs
    if size(node_vector, 2) ~= 5
        error('Node vector must have 5 columns: [x, y, rib_index, stringer_index, tag].');
    end
    if numel(point) ~= 2
        error('Point must be a 1x2 vector [x, y].');
    end
    if ribs_total > size(node_vector, 1)
        error('ribs_total exceeds the number of available nodes.');
    end

    %% Initialization
    num_nodes = size(node_vector, 1);
    start_idx = max(1, num_nodes - ribs_total); % Ensure bounds are not exceeded
    was_inserted = false; % Default

    %% Loop Through the Last `ribs_total` Node Pairs
    for i = start_idx:num_nodes-1
        node1 = node_vector(i, 1:2); % [x, y]
        node2 = node_vector(i+1, 1:2);

        % Calculate slope between two nodes
        segment_slope = (node2(2) - node1(2)) / (node2(1) - node1(1));

        % Check slope match within tolerance
        if abs(segment_slope - slope) < 1e-5
            % Check if the point lies between the two nodes
            if point(1) > min(node1(1), node2(1)) && point(1) < max(node1(1), node2(1))
                % Infer rib index
                rib_index = node_vector(i, 3) + 1; % Increment logically

                % Create the new node with tag 'inserted'
                inserted_node = [point(1), point(2), rib_index, stringer_index, "inserted"];
                was_inserted = true;
                return;
            end
        end
    end

    % If not inserted during loop, append it as the last node
    rib_index = node_vector(end, 3) + 1;

    inserted_node = [point(1), point(2), rib_index, stringer_index, "inserted"];
    warning('No valid segment found. Node appended to inserted_nodes.');
end
