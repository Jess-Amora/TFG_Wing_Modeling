function globalElements = mapLocalToGlobalElements(localElements, localToGlobalMap)
%MAPLOCALTOGLOBALELEMENTS Maps local node IDs in elements to global node IDs.
%
% Inputs:
% - localElements: Cell array with matrices of local node IDs for each element set.
% - localToGlobalMap: Cell array mapping local IDs to global IDs.
%
% Outputs:
% - globalElements: Cell array with matrices of global node IDs.

    numSets = numel(localElements);
    globalElements = cell(numSets, 1);

    for i = 1:numSets
        currentElements = localElements{i};
        currentMap = localToGlobalMap{i};
        
        % Create a lookup dictionary
        localToGlobalDict = containers.Map(currentMap(:, 1), currentMap(:, 2));

        % Preallocate the global elements matrix
        globalElements{i} = zeros(size(currentElements));
        
        % Map each node ID, with error handling
        for row = 1:size(currentElements, 1)
            for col = 1:size(currentElements, 2)
                localID = currentElements(row, col);
                if isKey(localToGlobalDict, localID)
                    globalElements{i}(row, col) = localToGlobalDict(localID);
                else
                    error('Node ID %d in elementos{%d} does not exist in the corresponding nodos{%d}.', ...
                          localID, i, i);
                end
            end
        end
    end
end
