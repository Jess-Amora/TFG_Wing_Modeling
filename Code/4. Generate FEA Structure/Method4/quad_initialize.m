function quad_table = quad_initialize(is3D)
% QUAD_INITIALIZE - Creates an empty table for quadrilateral surfaces.
%
% INPUT (Optional):
%   is3D - (logical) If true, includes 'h' column for 3D elements.
%
% OUTPUT:
%   quad_table - An empty table with the correct variable names and matching placeholders.
%
% USAGE:
%   quad_surfaces_regular = quad_initialize();        % 2D version
%   quad_surfaces_3D = quad_initialize(true);         % 3D version with 'h' column

    % ✅ Define standard variable names for 2D
    variableNames = {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                     'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                     'area', 'aspect_ratio'};
    
    % ✅ If 3D is requested, add 'h' column
    if nargin == 1 && is3D
        variableNames{end+1} = 'h';
    end
    
    % ✅ Create an empty table with correct number of columns
    emptyValues = cell(1, numel(variableNames)); % Create an empty cell array
    [emptyValues{:}] = deal([]); % Fill with empty placeholders

    quad_table = table(emptyValues{:}, 'VariableNames', variableNames);
end
