function [lines, line_counter] = create_new_line_vertical(node_1, node_2, stringer_index, rib_1, rib_2, tag, h, line_counter, lines)
% Creates a new line entry and appends it to the existing lines table.
%
% Inputs:
%   node_1          - Struct or table row representing the first node.
%   node_2          - Struct or table row representing the second node.
%   stringer_index  - Index of the associated stringer.
%   rib_1           - Rib index for the first node.
%   rib_2           - Rib index for the second node.
%   tag             - Tag to classify the line (e.g., 'quad vertical rib').
%   h               - Indicates 'extrados' or 'intrados'.
%   line_counter    - Current line counter to assign unique IDs.
%   lines           - Existing lines table to append the new line.
%
% Outputs:
%   lines           - Updated lines table with the new entry.
%   line_counter    - Updated line counter after adding the new line.

    %% 🟢 Validate Nodes
    if isempty(node_1) || isempty(node_2)
        warning('Skipping line creation due to missing nodes.');
        return;
    end

    %% 🔄 Calculate Line Length
    length = norm([node_2.x - node_1.x, node_2.y - node_1.y, node_2.z - node_1.z]);

    %% 📝 Create New Line
    new_line = table( ...
        line_counter, ...       % local_id
        node_1.local_id, ...    % node_1
        node_2.local_id, ...    % node_2
        stringer_index, ...     % stringer_index
        rib_1, ...              % rib_1
        rib_2, ...              % rib_2
        tag, ...                % tag
        length, ...             % length
        h, ...                  % h (extrados or intrados)
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

    %% 🔄 Append to Lines Table
    lines = [lines; new_line];

    %% 🔢 Increment Line Counter
    line_counter = line_counter + 1;
end
