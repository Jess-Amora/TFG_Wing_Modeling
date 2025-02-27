function tri_table = tri_initialize(is3D)
% TRI_INITIALIZE - Creates an empty table for triangular surfaces.
%
% INPUT (Optional):
%   is3D - (logical) If true, includes 'h' column for 3D elements.
%
% OUTPUT:
%   tri_table - An empty table with the correct variable names and placeholders.
%
% USAGE:
%   tri_surfaces_regular = tri_initialize();       % 2D version
%   tri_surfaces_3D = tri_initialize(true);        % 3D version with 'h' column

    % ✅ Define standard variable names for 2D
    variableNames = {'local_id', 'node_1', 'node_2', 'node_3', ...
                     'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                     'area', 'aspect_ratio'};
    
    % ✅ If 3D is requested, add 'h' column
    if nargin == 1 && is3D
        variableNames{end+1} = 'h';
    end
    
    % ✅ Create an empty table with correct number of columns
    emptyValues = cell(1, numel(variableNames)); % Create an empty cell array
    [emptyValues{:}] = deal([]); % Fill with empty placeholders

    tri_table = table(emptyValues{:}, 'VariableNames', variableNames);
end
