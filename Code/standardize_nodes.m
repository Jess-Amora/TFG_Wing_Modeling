function standardized_nodes = standardize_nodes(nodes, start_id, default_tag)
% standardize_nodes: Converts Nx2 or Nx5 node matrices to a standardized Nx6 format.
%
% Inputs:
%   nodes: Nx2, Nx5, or Nx6 matrix of node data
%   start_id (optional): Starting local ID for nodes. Defaults to 1.
%   default_tag (optional): Default tag assigned to all nodes. Defaults to 'undefined'.
%
% Outputs:
%   standardized_nodes: Nx6 standardized matrix [local_id, x, y, rib_index, stringer_index, tag]

    %% Default Parameters
    if nargin < 2 || isempty(start_id)
        start_id = 1; % Default starting ID
    end
    if nargin < 3 || isempty(default_tag)
        default_tag = "undefined"; % Default tag if none is provided
    end
    
    %% Validate Inputs
    num_nodes = size(nodes, 1);
    
    if size(nodes, 2) == 2
        % Nodes are Nx2, add local_id, rib_index, stringer_index, and tag
        standardized_nodes = [(start_id:start_id+num_nodes-1)', nodes, NaN(num_nodes, 2), repmat(string(default_tag), num_nodes, 1)];
    elseif size(nodes, 2) == 5
        % Nodes are Nx5, add tag
        standardized_nodes = [nodes, repmat(string(default_tag), num_nodes, 1)];
    elseif size(nodes, 2) == 6
        % Nodes are already standardized
        standardized_nodes = nodes;
    else
        error('Invalid node format. Must be Nx2, Nx5, or Nx6.');
    end
end
