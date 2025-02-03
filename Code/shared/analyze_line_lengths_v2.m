function [longest_lines, stats, top_10_longest] = analyze_line_lengths_v2(lines_table, threshold_factor)
    % analyze_line_lengths_v2: Finds and analyzes the longest lines based on length.
    %
    % INPUTS:
    % - lines_table: Table containing a 'length' column.
    % - threshold_factor: Factor for filtering long lines (default = 2.5).
    %
    % OUTPUTS:
    % - longest_lines: Table containing only the longest lines above the threshold.
    % - stats: Struct with statistical analysis of all line lengths.
    % - top_10_longest: Table containing the 10 longest lines overall.
    %
    % Example usage:
    % [long_lines, stats, top_10] = analyze_line_lengths_v2(lines, 3);

    % Ensure the table contains a 'length' column
    if ~ismember('length', lines_table.Properties.VariableNames)
        error('Table does not contain a "length" column.');
    end

    % Extract the length values
    lengths = lines_table.length;

    % Compute basic statistics
    max_length = max(lengths);
    mean_length = mean(lengths);
    std_length = std(lengths);

    % Define threshold for "unusually long" lines
    threshold = mean_length + threshold_factor * std_length;

    % Find lines that exceed the threshold
    longest_lines = lines_table(lengths > threshold, :);

    % Sort all lines by length in descending order
    [~, sorted_indices] = sort(lengths, 'descend');
    
    % Get the top 10 longest lines
    num_top = min(10, height(lines_table)); % Handle cases where we have <10 lines
    top_10_longest = lines_table(sorted_indices(1:num_top), :);

    % Store statistics in a struct
    stats = struct();
    stats.max_length = max_length;
    stats.mean_length = mean_length;
    stats.std_length = std_length;
    stats.threshold = threshold;
    stats.num_long_lines = height(longest_lines);
    stats.top_10_max_length = top_10_longest.length(1);

    % Display results
    fprintf('📊 Line Length Analysis:\n');
    fprintf('   Max Length: %.2f\n', max_length);
    fprintf('   Mean Length: %.2f\n', mean_length);
    fprintf('   Std Dev: %.2f\n', std_length);
    fprintf('   Threshold for Long Lines: %.2f\n', threshold);
    fprintf('   Number of Long Lines: %d\n', stats.num_long_lines);
    fprintf('   Max of Top 10 Lines: %.2f\n\n', stats.top_10_max_length);

end
