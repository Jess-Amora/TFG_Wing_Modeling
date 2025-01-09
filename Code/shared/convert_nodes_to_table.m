function nodes_table = convert_nodes_to_table(nodes)
% convert_nodes_to_table: Converts an Nx4, Nx5, or Nx6 numeric node matrix into a table.
%
% Inputs:
%   nodes: Nx4, Nx5, or Nx6 numeric matrix of node data
%          Columns (if 4): [x, y, rib_index, stringer_index]
%          Columns (if 5): [x, y, rib_index, stringer_index, local_id]
%          Columns (if 6): [x, y, rib_index, stringer_index, local_id, tag]
%
% Outputs:
%   nodes_table: Table with columns:
%       - local_id: Unique node ID (auto-generated if missing)
%       - x: X Coordinate
%       - y: Y Coordinate
%       - rib_index: Rib Index
%       - stringer_index: Stringer Index
%       - tag: Node Tag (as string, defaults to 'undefined' if absent)

    %% ✅ Step 1: Handle 1xNx4 Input
    if ndims(nodes) == 3 && size(nodes, 1) == 1
        nodes = squeeze(nodes)'; % Convert 1xNx4 to Nx4
        disp('✅ Squeezed 1xNx4 matrix into Nx4 for consistency.');
    end

    %% 🛡️ Step 2: Validate Input
    if size(nodes, 2) < 4
        error('Input nodes must have at least 4 columns: [x, y, rib_index, stringer_index]');
    end

    %% 📝 Step 3: Extract and Ensure Column Completeness
    x = nodes(:, 1);               % X Coordinates
    y = nodes(:, 2);               % Y Coordinates
    rib_index = nodes(:, 3);       % Rib Indices
    stringer_index = nodes(:, 4);  % Stringer Indices

    % Handle local_id (5th column)
    if size(nodes, 2) < 5
        local_id = (1:size(nodes, 1))'; % Auto-generate local IDs
        disp('✅ local_id column auto-generated.');
    else
        local_id = nodes(:, 5);
    end

    % Handle tag (6th column)
    if size(nodes, 2) < 6
        tag = repmat("stringer", size(nodes, 1), 1); % Default tag
    else
        tag = string(nodes(:, 6));
    end

    %% 📊 Step 4: Create Table with Standardized Columns
    nodes_table = table( ...
        local_id, x, y, rib_index, stringer_index, tag, ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

    %% ✅ Display Success Message
    disp('✅ Nodes successfully converted to table with local_id auto-handling.');
end
