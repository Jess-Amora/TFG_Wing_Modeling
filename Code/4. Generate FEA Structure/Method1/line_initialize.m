function line_table = line_initialize(is3D)
% LINE_INITIALIZE - Creates an empty table for structural lines.
%
% INPUT (Optional):
%   is3D - (logical) If true, includes 'h' column for 3D elements.
%
% OUTPUT:
%   line_table - An empty table with the correct variable names and matching placeholders.
%
% USAGE:
%   vertical_stringers = line_initialize();        % 2D version
%   vertical_stringers_3D = line_initialize(true); % 3D version with 'h' column

    % ✅ Define standard variable names for 2D
    variableNames = {'local_id', 'node_1', 'node_2', 'stringer_index', ...
                     'rib_1', 'rib_2', 'tag', 'length'};

    % ✅ If 3D is requested, add 'h' column
    if nargin == 1 && is3D
        variableNames{end+1} = 'h';
    end

    % ✅ Create an empty table with correct number of columns
    emptyValues = cell(1, numel(variableNames)); % Create an empty cell array
    [emptyValues{:}] = deal([]); % Fill with empty placeholders

    line_table = table(emptyValues{:}, 'VariableNames', variableNames);
end
