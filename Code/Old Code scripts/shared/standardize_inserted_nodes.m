function inserted_table = standardize_inserted_nodes(inserted_nodes)
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
%       - x: x-coordinate of the node
%       - y: y-coordinate of the node
%       - rib_index: Rib index (-3 for inserted nodes)
%       - stringer_index: Stringer index
%       - tag: Node type (e.g., 'inserted')

    %% Validate Input
    if mod(length(inserted_nodes), 5) ~= 0
        error('The length of the vector must be divisible by 5. Check the input!');
    end

    % Reshape the vector into an N x 5 matrix
    N = length(inserted_nodes) / 5;
    reshaped_nodes = reshape(inserted_nodes, [5, N])'; % Transpose to get N x 5

    %% Extract Individual Columns
    x = reshaped_nodes(:, 1);
    y = reshaped_nodes(:, 2);
    stringer_index = reshaped_nodes(:, 3);
    rib_index = reshaped_nodes(:, 4);
    tag = reshaped_nodes(:, 5); % Assuming numeric tag

    % Map numeric tag to string
    if isnumeric(tag)
        tag = arrayfun(@(v) "inserted", tag, 'UniformOutput', false);
    end

    %% Create Table
    inserted_table = table(x, y, rib_index, stringer_index, tag, ...
        'VariableNames', {'x', 'y', 'rib_index', 'stringer_index', 'tag'});
    
    %% Success Message
    disp('✅ Inserted nodes successfully standardized into a table.');
end
