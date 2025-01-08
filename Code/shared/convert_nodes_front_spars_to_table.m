function nodes_table = convert_nodes_front_spars_to_table(nodes)
% convert_nodes_front_spars_to_table: Converts an Nx2 front spar node matrix into a table.
%
% Inputs:
%   nodes: Nx2 numeric matrix of node coordinates [x, y]
%
% Outputs:
%   nodes_table: Table with columns:
%       - local_id: Unique node ID (row index)
%       - x: X Coordinate
%       - y: Y Coordinate
%       - rib_index: Assigned as local_id
%       - stringer_index: NaN (not applicable)
%       - tag: "front spars"

    %% Validate Input
    if size(nodes, 2) ~= 2
        error('Input nodes must have exactly 2 columns: [x, y]');
    end
    
    %% Create Table with Default Values
    num_nodes = size(nodes, 1); % Number of nodes
    
    nodes_table = table( ...
        (1:num_nodes)', ...                % local_id (row index)
        nodes(:, 1), ...                   % x coordinates
        nodes(:, 2), ...                   % y coordinates
        (1:num_nodes)', ...                % rib_index (set as local_id)
        NaN(num_nodes, 1), ...             % stringer_index (default NaN)
        repmat("front spars", num_nodes, 1), ... % tag
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'} ...
    );
end
