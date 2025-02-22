function valid = all_nodes_exist(node_list)
% ALL_NODES_EXIST - Checks if all given nodes exist.
%
% Input:
%   node_list - A cell array or vector of nodes.
%
% Output:
%   valid     - Boolean (true if all nodes are valid, false otherwise).

    valid = all(~cellfun(@isempty, node_list));
end
