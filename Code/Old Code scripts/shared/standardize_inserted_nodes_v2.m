function inserted_table = standardize_inserted_nodes_v2(inserted_nodes)
% Converts an elongated (N*5)x1 inserted_nodes vector into a properly formatted table.
%
% Inputs:
%   inserted_nodes: Elongated vector with (N*5)x1 elements:
%       - Column 1: x-coordinate
%       - Column 2: y-coordinate
%       - Column 3: stringer index
%       - Column 4: rib index
%       - Column 5: tag ('inserted')
%
% Outputs:
%   inserted_table: Table with standardized columns:
%       - local_id: Sequential node identifier (integer)
%       - x: x-coordinate of the node (numeric)
%       - y: y-coordinate of the node (numeric)
%       - stringer_index: Adjusted Stringer index (numeric, decremented by 1)
%       - rib_index: Rib index (numeric, -3 for inserted nodes)
%       - tag: Node type (string, e.g., 'inserted')

    %% Validate Input
    if mod(length(inserted_nodes), 5) ~= 0
        error('The length of the vector must be divisible by 5. Check the input!');
    end

    % Reshape the vector into an N x 5 matrix
    N = length(inserted_nodes) / 5;
    reshaped_nodes = reshape(inserted_nodes, [5, N])'; % Transpose to get N x 5

    %% Extract Individual Columns and Convert to Numeric
    x = str2double(reshaped_nodes(:, 1)); % Convert x to numeric if needed
    y = str2double(reshaped_nodes(:, 2)); % Convert y to numeric if needed
    stringer_index = str2double(reshaped_nodes(:, 3)) - 1; % Convert and decrement by 1
    rib_index = str2double(reshaped_nodes(:, 4)); % Convert rib_index to numeric if needed
    tag = reshaped_nodes(:, 5); % Keep as is (assumed as numeric or string)

    % Convert numeric tag to string if applicable
    if isnumeric(tag)
        tag = arrayfun(@(v) "inserted", tag, 'UniformOutput', false);
    end

    %% Add local_id
    local_id = (1:N)'; % Create sequential IDs based on the row order

    %% Create Table
    inserted_table = table(local_id, x, y, stringer_index, rib_index, tag, ...
        'VariableNames', {'local_id', 'x', 'y', 'stringer_index', 'rib_index', 'tag'});
    
    %% Success Message
    disp('✅ Inserted nodes successfully standardized into a table.');
end
