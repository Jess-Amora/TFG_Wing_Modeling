function [lines, line_counter] = create_lines_from_stringer_horizontal_ribs(vector_ribs, rib_index, tag, h, initial_line_counter)
% Creates lines from consecutive rows in a vector_ribs table.
%
% Inputs:
%   vector_ribs   - Table with rows representing nodes in the stringer.
%   stringer_index    - Index of the stringer being processed.
%   tag               - Tag to classify the lines (e.g., 'stringer').
%   h                 - Indicates 'extrados' or 'intrados'.
%   initial_line_counter - Initial line counter value.
%
% Outputs:
%   lines             - Table containing the created lines.
%   line_counter      - Updated line counter after adding all lines.

    %% 📝 Initialize Lines Table
    lines = table([], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

    %% 🔄 Iterate Through Consecutive Rows
    line_counter = initial_line_counter; % Start with the given counter
    for i = 1:(height(vector_ribs) - 1)
        % Extract consecutive nodes
        node_1 = vector_ribs(i, :);
        node_2 = vector_ribs(i + 1, :);

        % Extract rib indices from the nodes
        rib_1 = node_1.stringer_index;
        rib_2 = node_2.stringer_index;

        % Use the create_new_line function to create a line
        [lines, line_counter] = create_new_line_horizontal(node_1, node_2, rib_index, rib_1, rib_2, tag, h, line_counter, lines);
    end
end
