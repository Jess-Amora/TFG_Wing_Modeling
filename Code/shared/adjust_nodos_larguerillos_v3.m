function [updated_node_vector, inserted_nodes] = adjust_nodos_larguerillos_v3(...
    node_vector, slope, perpendicular_slope, ribs_total, ...
    distancia_entre_larguerillo_vertical, alfa_larguero_posterior_radianes, ...
    threshold_distance, stringer_index)
% Adjusts nodes by removing or inserting nodes based on geometry, with consistent use of stringer_index.
%
% Inputs:
%   node_vector: 1xNx2 matrix with columns [x, y].
%   slope: Desired slope of the rear spar.
%   perpendicular_slope: Perpendicular slope for node adjustment.
%   ribs_total: Total ribs in the wing.
%   distancia_entre_larguerillo_vertical: Vertical spacing for larguerillos.
%   alfa_larguero_posterior_radianes: Angle for rear spar alignment (in radians).
%   threshold_distance: Minimum distance for removing or inserting nodes.
%   stringer_index: Index of the stringer being processed.
%
% Outputs:
%   updated_node_vector: Adjusted Nx5 matrix with updated nodes.
%   inserted_nodes: Matrix of inserted nodes [x, y, rib_index, stringer_index, tag].

    %% Validate and Expand Node Vector
    % Check if the input is a 1xNx2 matrix
    if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
        error('Node vector must be a 1xNx2 matrix ([x, y]).');
    end

    % Add `rib_index`, `stringer_index`, and `tag` columns
    num_nodes = size(node_vector, 2);
    rib_index = linspace(1, ribs_total, num_nodes); % Linear rib index from 1 to ribs_total
    stringer_column = stringer_index * ones(1, num_nodes); % Same stringer index for all nodes
    tag_column = repmat("original", 1, num_nodes); % Default tag as 'original'

    % Convert to Nx5 format
    node_vector = permute(node_vector, [2, 1, 3]); % Reshape to Nx2
    node_vector = [node_vector, rib_index(:), stringer_column(:), tag_column(:)];

    % Initialize outputs
    updated_node_vector = node_vector;
    inserted_nodes = []; % To store inserted nodes

    %% Check Last Two Nodes for Proximity
    num_nodes = size(updated_node_vector, 1);
    if num_nodes < 2
        warning('Not enough nodes for adjustment.');
        return;
    end

    % Extract the last two nodes
    last_node = updated_node_vector(end, 1:2);
    penultimate_node = updated_node_vector(end-1, 1:2);

    % Calculate distance between the last two nodes
    distancia_nodos = norm(last_node - penultimate_node);

    if distancia_nodos < threshold_distance
        %% Case 1: Remove Last Node (Nodes too close)
        % Uncomment the following line to enable removal if required:
        % updated_node_vector(end, :) = [];
        % disp('✅ Last node removed due to close proximity to the penultimate node.');
    else
        %% Case 2: Insert Perpendicular Node
        delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / sqrt(1 + perpendicular_slope^2);
        delta_y = perpendicular_slope * delta_x;

        % Calculate perpendicular point
        x2 = last_node(1) - delta_x;
        y2 = last_node(2) - delta_y;

        % Insert perpendicular node and save to `inserted_nodes`
        [inserted_node, was_inserted] = insert_perpendicular_node_v6(...
            updated_node_vector, slope, [x2, y2], ribs_total, stringer_index);

        if was_inserted
            inserted_nodes = [inserted_nodes; inserted_node];
            updated_node_vector = [updated_node_vector; inserted_node]; % Append to the node vector
            disp('✅ Perpendicular node successfully added to inserted_nodes.');
        end
    end
end
