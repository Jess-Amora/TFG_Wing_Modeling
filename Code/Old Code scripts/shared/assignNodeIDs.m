function [globalNodes, localToGlobalMap] = assignNodeIDs(varargin)
    % Inputs: varargin - multiple node vectors as Nx2 matrices
    % Outputs:
    % - globalNodes: Combined matrix with global IDs [GlobalID, X, Y]
    % - localToGlobalMap: Cell array mapping local to global IDs for each input node vector

    globalID = 1; % Start global ID
    globalNodes = []; % Initialize global nodes matrix
    localToGlobalMap = cell(nargin, 1); % Cell to store local-to-global maps

    for i = 1:nargin
        nodes = varargin{i}; % Current node vector
        numNodes = size(nodes, 1); % Number of nodes in this vector
        
        % Create local to global mapping for this node vector
        localIDs = (1:numNodes)';
        globalIDs = (globalID:globalID + numNodes - 1)';
        localToGlobalMap{i} = [localIDs, globalIDs];
        
        % Append to global nodes matrix with global IDs
        globalNodes = [globalNodes; [globalIDs, nodes]];
        
        % Update global ID counter
        globalID = globalID + numNodes;
    end
end
