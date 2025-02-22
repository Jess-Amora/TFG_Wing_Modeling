% function updated_node_vector = insert_perpendicular_node(node_vector, slope, point, id_nodo_local_larguerillo_costilla)
%     % Function to insert a perpendicular node into a 1xNx2 node vector based on geometry and slope
%     %
%     % Inputs:
%     %   node_vector: 1xNx2 matrix of node coordinates [x, y]
%     %   slope: Desired slope of the rear spar
%     %   point: Coordinates of the end node on the current stringer [x, y]
%     %   id_nodo_local_larguerillo_costilla: Mapping of nodes to ribs and stringers
%     %
%     % Outputs:
%     %   updated_node_vector: 1x(N+1)x2 matrix with the new node inserted in order
% 
%     %% Validate Inputs
%     if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
%         error('Node vector must be a 1xNx2 matrix (x, y coordinates).');
%     end
%     if numel(point) ~= 2
%         error('Point must be a 1x2 vector [x, y].');
%     end
%     if size(id_nodo_local_larguerillo_costilla, 2) < 3
%         error('id_nodo_local_larguerillo_costilla must have at least 3 columns: [NodeID, RibIndex, StringerIndex].');
%     end
% 
%     %% Step 1: Identify Current Stringer and Rib Indices
%     % Find the index of the input point in the node vector
%     point_idx = find(squeeze(node_vector(1, :, 1)) == point(1) & squeeze(node_vector(1, :, 2)) == point(2), 1);
% 
%     if isempty(point_idx)
%         error('Input point not found in node vector.');
%     end
% 
%     % Get the current rib and stringer indices
%     current_node_id = id_nodo_local_larguerillo_costilla(point_idx, 1);
%     current_rib = id_nodo_local_larguerillo_costilla(point_idx, 2);
%     current_stringer = id_nodo_local_larguerillo_costilla(point_idx, 3);
% 
%     % Find the second-to-last node in the current stringer
%     current_stringer_nodes = id_nodo_local_larguerillo_costilla(id_nodo_local_larguerillo_costilla(:,3) == current_stringer, :);
%     current_stringer_nodes = sortrows(current_stringer_nodes, 2); % Sort by RibIndex
% 
%     if size(current_stringer_nodes, 1) < 2
%         error('Current stringer does not have enough nodes for calculation.');
%     end
% 
%     second_last_node_idx = current_stringer_nodes(end-1, 1);
%     second_last_point = squeeze(node_vector(1, second_last_node_idx, :))';
% 
%     %% Step 2: Locate the Corresponding Node on the Previous Stringer
%     prev_stringer = current_stringer - 1; % Assuming stringers are sequentially numbered
% 
%     % Find nodes in the previous stringer
%     prev_stringer_nodes = id_nodo_local_larguerillo_costilla(id_nodo_local_larguerillo_costilla(:,3) == prev_stringer, :);
%     prev_stringer_nodes = sortrows(prev_stringer_nodes, 2); % Sort by RibIndex
% 
%     if size(prev_stringer_nodes, 1) < 2
%         error('Previous stringer does not have enough nodes for calculation.');
%     end
% 
%     % Find the corresponding second-to-last node in the previous stringer
%     corresponding_prev_node_idx = prev_stringer_nodes(end-1, 1);
%     corresponding_prev_node = squeeze(node_vector(1, corresponding_prev_node_idx, :))';
% 
%     %% Step 3: Calculate Distance and Project Perpendicular Node
%     % Distance between the current end node and second-to-last node
%     distance = sqrt((point(1) - second_last_point(1))^2 + (point(2) - second_last_point(2))^2);
%     disp(['Distance between end and second-to-last node: ', num2str(distance)]);
% 
%     % Project the new node
%     delta_x = distance / sqrt(1 + (-1/slope)^2);
%     delta_y = (-1 / slope) * delta_x;
% 
%     new_node = [corresponding_prev_node(1) + delta_x, corresponding_prev_node(2) + delta_y];
%     disp(['New node coordinates: [', num2str(new_node(1)), ', ', num2str(new_node(2)), ']']);
% 
%     %% Step 4: Insert the New Node into the Node Vector
%     updated_node_vector = [
%         node_vector(:, 1:corresponding_prev_node_idx, :), ... % Nodes before insertion
%         reshape(new_node, [1, 1, 2]), ... % Insert new perpendicular node
%         node_vector(:, corresponding_prev_node_idx+1:end, :) % Nodes after insertion
%     ];
% 
%     disp('Node successfully inserted into node vector.');
% end


% function updated_node_vector = insert_perpendicular_node(node_vector, slope, point, ribs_total)
%     % Function to insert a perpendicular node into a 1xNx2 node vector based on geometry and slope
%     %
%     % Inputs:
%     %   node_vector: 1xNx2 matrix of node coordinates [x, y]
%     %   slope: Desired slope of the rear spar
%     %   point: Coordinates of the end node on the current stringer [x, y]
%     %   ribs_total: Number of ribs (nodes) from the end to check
%     %
%     % Outputs:
%     %   updated_node_vector: 1x(N+1)x2 matrix with the new node inserted in order
% 
%     %% Validate Inputs
%     if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
%         error('Node vector must be a 1xNx2 matrix (x, y coordinates).');
%     end
%     if numel(point) ~= 2
%         error('Point must be a 1x2 vector [x, y].');
%     end
%     if ribs_total > size(node_vector, 2)
%         error('ribs_total exceeds the number of available nodes.');
%     end
% 
%     %% Step 1: Extract Relevant Nodes
%     num_nodes = size(node_vector, 2);
% 
%     % Current stringer nodes
%     end_node = squeeze(node_vector(1, end, :))'; % End node
%     second_last_node = squeeze(node_vector(1, end-1, :))'; % Second-to-last node
% 
%     % Previous stringer corresponding nodes
%     prev_end_idx = num_nodes - ribs_total; % Index for previous stringer
%     if prev_end_idx < 2
%         error('Not enough nodes to locate the corresponding previous stringer node.');
%     end
% 
%     prev_second_last_node = squeeze(node_vector(1, prev_end_idx-1, :))';
% 
%     %% Step 2: Calculate the Distance Between Current End Node and Second-to-Last Node
%     distance = sqrt((end_node(1) - second_last_node(1))^2 + (end_node(2) - second_last_node(2))^2);
%     disp(['Distance between end node and second-to-last node: ', num2str(distance)]);
% 
%     %% Step 3: Project the New Node on the Previous Stringer
%     % The new node is projected perpendicularly along the stringer slope
%     delta_x = distance / sqrt(1 + (-1/slope)^2); % Distance in x
%     delta_y = (-1 / slope) * delta_x; % Distance in y
% 
%     % Calculate the new perpendicular node coordinates
%     new_node = [prev_second_last_node(1) + delta_x, prev_second_last_node(2) + delta_y];
%     disp(['New node coordinates: [', num2str(new_node(1)), ', ', num2str(new_node(2)), ']']);
% 
%     %% Step 4: Insert the New Node into the Node Vector
%     updated_node_vector = [
%         node_vector(:, 1:prev_end_idx, :), ... % Nodes before insertion
%         reshape(new_node, [1, 1, 2]), ... % Insert new perpendicular node
%         node_vector(:, prev_end_idx+1:end, :) % Nodes after insertion
%     ];
% 
%     disp('Node successfully inserted into node vector.');
% end


% function updated_node_vector = insert_perpendicular_node(node_vector, slope, point, ribs_total)
%     % Function to insert a perpendicular node into a 1xNx2 node vector based on geometry and slope
%     %
%     % Inputs:
%     %   node_vector: 1xNx2 matrix of node coordinates [x, y]
%     %   slope: Desired slope of the rear spar
%     %   point: Coordinates of the end node on the current stringer [x, y]
%     %   ribs_total: Number of ribs (nodes) from the end to check
%     %
%     % Outputs:
%     %   updated_node_vector: 1x(N+1)x2 matrix with the new node inserted in order
% 
%     % Validate Inputs
%     if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
%         error('Node vector must be a 1xNx2 matrix (x, y coordinates).');
%     end
%     if numel(point) ~= 2
%         error('Point must be a 1x2 vector [x, y].');
%     end
%     if ribs_total > size(node_vector, 2)
%         error('ribs_total exceeds the number of available nodes.');
%     end
% 
%     % Extract the last two nodes from the current stringer
%     num_nodes = size(node_vector, 2);
%     end_node = squeeze(node_vector(1, end, :))'; % Last node
%     second_last_node = squeeze(node_vector(1, end-1, :))'; % Second-to-last node
% 
%     % Calculate the Euclidean distance between the end node and second-to-last node
%     distance = sqrt((end_node(1) - second_last_node(1))^2 + (end_node(2) - second_last_node(2))^2);
%     disp(['Distance between end node and second-to-last node: ', num2str(distance)]);
% 
%     % Find the corresponding second-to-last node on the previous stringer
%     prev_stringer_idx = num_nodes - ribs_total; % Start index for the previous stringer
%     if prev_stringer_idx < 2
%         error('Not enough nodes to find corresponding second-to-last node on previous stringer.');
%     end
% 
%     prev_second_last_node = squeeze(node_vector(1, prev_stringer_idx-1, :))';
% 
%     % Project the perpendicular node using the calculated distance
%     % Perpendicular slope is -1/slope
%     delta_x = distance / sqrt(1 + (-1/slope)^2);
%     delta_y = (-1 / slope) * delta_x;
% 
%     % Calculate the new node coordinates
%     new_node = [prev_second_last_node(1) + delta_x, prev_second_last_node(2) + delta_y];
%     disp(['New node coordinates: [', num2str(new_node(1)), ', ', num2str(new_node(2)), ']']);
% 
%     % Insert the new node into the node vector
%     updated_node_vector = [
%         node_vector(:, 1:prev_stringer_idx, :), ... % Nodes before insertion
%         reshape(new_node, [1, 1, 2]), ... % Insert new point
%         node_vector(:, prev_stringer_idx+1:end, :) % Nodes after insertion
%     ];
% 
%     disp('Node successfully inserted into node vector.');
% end


function updated_node_vector = insert_perpendicular_node(node_vector, slope, point, ribs_total)
    % Function to insert a node into a 1xNx2 node vector based on geometry and slope
    %
    % Inputs:
    %   node_vector: 1xNx2 matrix of node coordinates [x, y]
    %   slope: Desired slope of the rear spar
    %   point: Coordinates of the new perpendicular node [x, y]
    %   ribs_total: Number of ribs (nodes) from the end to check
    %
    % Outputs:
    %   updated_node_vector: 1x(N+1)x2 matrix with the new node inserted in order

    % Validate Inputs
    if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
        error('Node vector must be a 1xNx2 matrix (x, y coordinates).');
    end
    if numel(point) ~= 2
        error('Point must be a 1x2 vector [x, y].');
    end
    if ribs_total > size(node_vector, 2)
        error('ribs_total exceeds the number of available nodes.');
    end

    % Extract the subset of nodes for checking
    num_nodes = size(node_vector, 2);
    start_idx = max(1, num_nodes - ribs_total); % Ensure we don't exceed bounds

    insert_idx = -1; % Default no insertion

    % Loop through the last `ribs_total` node pairs
    for i = start_idx:num_nodes-1
        % Extract two consecutive nodes
        node1 = squeeze(node_vector(1, i, :))'; % Convert to row vector [x, y]
        node2 = squeeze(node_vector(1, i+1, :))';

        % Calculate slope between the two nodes
        segment_slope = (node2(2) - node1(2)) / (node2(1) - node1(1));

        % Check if the slopes match within a tolerance
        if abs(segment_slope - slope) < 1e-5
            % Check if the new point lies between the two nodes
            if point(1) > min(node1(1), node2(1)) && point(1) < max(node1(1), node2(1))
                insert_idx = i; % Found the correct segment
                break;
            end
        end
    end

    % Prepare the updated node vector
    if insert_idx > 0
        % Insert the new node at the identified position
        updated_node_vector = [
            node_vector(:, 1:insert_idx, :), ... % Nodes before insertion
            reshape(point, [1, 1, 2]), ... % Insert new point
            node_vector(:, insert_idx+1:end, :) % Nodes after insertion
        ];
        disp('Node successfully inserted into node vector.');
    else
        % If no valid insertion point, append the new node at the end
        updated_node_vector = [
            node_vector, ...
            reshape(point, [1, 1, 2]) % Append point at the end
        ];
        warning('No valid segment found. Node appended at the end.');
    end
end



% function updated_node_vector = insert_perpendicular_node(node_vector, slope, point)
%     % Function to insert a node into a 1xNx2 node vector based on geometry and slope
%     %
%     % Inputs:
%     %   node_vector: 1xNx2 matrix of node coordinates [x, y]
%     %   slope: Desired slope of the rear spar
%     %   point: Coordinates of the new perpendicular node [x, y]
%     %
%     % Outputs:
%     %   updated_node_vector: 1x(N+1)x2 matrix with the new node inserted in order
% 
%     % Validate Inputs
%     if size(node_vector, 1) ~= 1 || size(node_vector, 3) ~= 2
%         error('Node vector must be a 1xNx2 matrix (x, y coordinates).');
%     end
%     if numel(point) ~= 2
%         error('Point must be a 1x2 vector [x, y].');
%     end
% 
%     % Extract number of nodes
%     num_nodes = size(node_vector, 2);
%     insert_idx = -1; % Default no insertion
% 
%     % Loop through node pairs
%     for i = 1:num_nodes-1
%         % Extract two consecutive nodes
%         node1 = squeeze(node_vector(1, i, :))'; % Convert to row vector [x, y]
%         node2 = squeeze(node_vector(1, i+1, :))';
% 
%         % Calculate slope between the two nodes
%         segment_slope = (node2(2) - node1(2)) / (node2(1) - node1(1));
% 
%         % Check if the slopes match within a tolerance
%         if abs(segment_slope - slope) < 1e-5
%             % Check if the new point lies between the two nodes
%             if point(1) > min(node1(1), node2(1)) && point(1) < max(node1(1), node2(1))
%                 insert_idx = i; % Found the correct segment
%                 break;
%             end
%         end
%     end
% 
%     % Prepare the updated node vector
%     if insert_idx > 0
%         % Insert the new node at the identified position
%         updated_node_vector = [
%             node_vector(:, 1:insert_idx, :), ... % Nodes before insertion
%             reshape(point, [1, 1, 2]), ... % Insert new point
%             node_vector(:, insert_idx+1:end, :) % Nodes after insertion
%         ];
%         disp('Node successfully inserted into node vector.');
%     else
%         % If no valid insertion point, append the new node at the end
%         updated_node_vector = [
%             node_vector, ...
%             reshape(point, [1, 1, 2]) % Append point at the end
%         ];
%         warning('No valid segment found. Node appended at the end.');
%     end
% end


% function updated_node_vector = insert_perpendicular_node(node_vector, slope, point)
%     % Function to insert a node into a node vector based on geometry and slope
%     %
%     % Inputs:
%     %   node_vector: Nx2 matrix of node coordinates [x, y]
%     %   slope: Desired slope of the rear spar
%     %   point: Coordinates of the new perpendicular node [x, y]
%     %
%     % Outputs:
%     %   updated_node_vector: Nx2 matrix with the new node inserted in order
% 
%     % Validate Inputs
%     if size(node_vector, 2) ~= 2
%         error('Node vector must be an Nx2 matrix (x, y coordinates).');
%     end
%     if numel(point) ~= 2
%         error('Point must be a 1x2 vector [x, y].');
%     end
% 
%     % Initialize variables
%     num_nodes = size(node_vector, 1);
%     insert_idx = -1; % Default no insertion
% 
%     % Loop through node pairs
%     for i = 1:num_nodes-1
%         % Extract two consecutive nodes
%         node1 = node_vector(i, :);
%         node2 = node_vector(i+1, :);
% 
%         % Calculate slope between the two nodes
%         segment_slope = (node2(2) - node1(2)) / (node2(1) - node1(1));
% 
%         % Check if the slopes match within a tolerance
%         if abs(segment_slope - slope) < 1e-5
%             % Check if the new point lies between the two nodes
%             if point(1) > min(node1(1), node2(1)) && point(1) < max(node1(1), node2(1))
%                 insert_idx = i; % Found the correct segment
%                 break;
%             end
%         end
%     end
% 
%     % If a valid insertion point was found
%     if insert_idx > 0
%         % Insert the new node into the vector
%         updated_node_vector = [
%             node_vector(1:insert_idx, :);
%             point;
%             node_vector(insert_idx+1:end, :)
%         ];
%         disp('Node successfully inserted into node vector.');
%     else
%         % If no valid insertion point, append at the end
%         updated_node_vector = [node_vector; point];
%         warning('No valid segment found. Node appended at the end.');
%     end
% end
