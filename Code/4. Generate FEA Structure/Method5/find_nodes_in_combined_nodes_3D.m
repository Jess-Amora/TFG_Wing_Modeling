function matched_nodes = find_nodes_in_combined_nodes_3D( ...
                                    combined_nodes_3D, ...
                                    x_input, ...
                                    y_input, ...
                                    tolerance)
% FIND_NODES_IN_COMBINED_NODES_3D 
%   Finds rows in combined_nodes_3D table that coincide with a given set of (x,y) 
%   points (within some tolerance).
%
%   matched_nodes = find_nodes_in_combined_nodes_3D(combined_nodes_3D, x_input, y_input, tolerance)
%
% Inputs:
%   combined_nodes_3D  - Table with columns: 
%                           {'local_id','x','y','z','rib_index','stringer_index','tag','h'} 
%                        containing 3D node data.
%   x_input, y_input   - Vectors of the same length representing the (x,y) points 
%                        you want to find in the combined_nodes_3D. 
%   tolerance          - Numeric scalar for how close (in x,y) a node must be 
%                        to be considered a match.
%
% Output:
%   matched_nodes      - A table that includes the matched rows from combined_nodes_3D, 
%                        plus an extra column 'input_index' telling you which 
%                        (x_input,y_input) each row matched.
%
% Example:
%   Suppose combined_nodes_3D has 1000 nodes with columns 
%       local_id, x, y, z, rib_index, stringer_index, tag, h
%   and you have 3 points you want to find: (x_input=[10,15,40], y_input=[5,5,10]).
%
%   matched_nodes = find_nodes_in_combined_nodes_3D(combined_nodes_3D, ...
%                                                   [10,15,40], [5,5,10], 1e-3);
%
%   This tries to find any node in combined_nodes_3D for each of those 
%   three points, with tolerance 1e-3 in x,y. 
%
%   If a node's (x,y) is within 1e-3 of one of the input points, it appears 
%   in matched_nodes, with the 'input_index' set to 1,2, or 3, 
%   depending on which input point it matched.

    arguments
        combined_nodes_3D table
        x_input (:,1) double
        y_input (:,1) double
        tolerance (1,1) double {mustBePositive}
    end

    % Basic checks
    nPoints = length(x_input);
    if nPoints ~= length(y_input)
        error('x_input and y_input must be the same length.');
    end

    % Preallocate structure (or table) to store results
    allMatches = [];

    % For each input point, find matches in combined_nodes_3D
    for i = 1:nPoints
        % Extract x,y for the i-th input
        xq = x_input(i);
        yq = y_input(i);

        % Compute difference in x,y relative to the entire table
        dx = abs(combined_nodes_3D.x - xq);
        dy = abs(combined_nodes_3D.y - yq);

        % Find nodes where both dx,dy <= tolerance
        isMatch = (dx <= tolerance) & (dy <= tolerance);

        % If any matches found, store them
        if any(isMatch)
            theseMatches = combined_nodes_3D(isMatch, :);

            % Add an extra column to indicate which input index matched
            theseMatches.input_index = repmat(i, height(theseMatches), 1);

            % Append to allMatches
            if isempty(allMatches)
                allMatches = theseMatches;
            else
                allMatches = [allMatches; theseMatches]; %#ok<AGROW>
            end
        end
    end

    % If no matches found
    if isempty(allMatches)
        warning('No matching nodes found for the given input (x,y) coordinates.');
        matched_nodes = allMatches;  % return empty
    else
        matched_nodes = allMatches;
    end
end
