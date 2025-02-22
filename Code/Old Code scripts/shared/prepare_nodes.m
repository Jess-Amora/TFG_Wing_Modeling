function nodes = prepare_nodes(node_ids, coordinates)
%PREPARE_NODES Prepare node data for write_bdf function.
%
% Inputs:
%   node_ids    : Vector of unique node IDs (1 x N)
%   coordinates : Nx3 matrix of node coordinates [X, Y, Z]
%
% Output:
%   nodes       : Nx6 array formatted for write_bdf
%                 [ID, CP, X, Y, Z, CD]
%
% Example:
%   node_ids = [1, 2, 3];
%   coordinates = [0, 0, 0; 1, 0, 0; 0, 1, 0];
%   nodes = prepare_nodes(node_ids, coordinates);

    % Check input validity
    if length(node_ids) ~= size(coordinates, 1)
        error('Number of node IDs must match number of coordinate rows.');
    end
    
    % Initialize CP and CD columns
    CP = zeros(size(node_ids));  % Input coordinate system
    CD = zeros(size(node_ids));  % Output coordinate system
    
    % Combine all data into the nodes array
    nodes = [node_ids(:), CP(:), coordinates, CD(:)];
end
