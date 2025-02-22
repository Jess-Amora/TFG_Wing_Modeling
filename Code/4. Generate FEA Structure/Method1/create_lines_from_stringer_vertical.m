function [lines, line_counter] = create_lines_from_stringer_vertical(vector_stringer_extrados, vector_stringer_intrados, rib_index, tag, h, initial_line_counter)
% Creates lines from consecutive rows in a vector_stringer table.
%
% Inputs:
%   vector_stringer   - Table with rows representing nodes in the stringer.
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

    for i = 1:min(height(vector_stringer_extrados),height(vector_stringer_intrados))
        % Extract consecutive nodes
        node_1 = vector_stringer_extrados(i, :);
        node_2 = vector_stringer_intrados(i, :);

        % Extract rib indices from the nodes
        stringer_index = node_1.stringer_index;
 

        % Use the create_new_line function to create a line
        [lines, line_counter] = create_new_line_vertical(node_1, node_2, stringer_index, rib_index, rib_index, tag, h, line_counter, lines);
    end

end
