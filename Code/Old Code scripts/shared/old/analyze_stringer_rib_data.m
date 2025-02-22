function [num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges] = analyze_stringer_rib_data(combined_nodes)
% analyze_stringer_rib_data: Analyzes stringer and rib data from combined_nodes.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%
% Outputs:
%   num_stringers_last_rib: Number of stringers that reach the last rib.
%   max_rib_index: Maximum rib index.
%   max_stringer_index: Maximum stringer index.
%   rib_ranges: Nx3 matrix where each row corresponds to a stringer:
%               [stringer_index, min_rib_index, max_rib_index].

    %% 📝 Filter Relevant Nodes
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);

    % Ensure there are stringer nodes
    if isempty(stringer_nodes)
        warning('No stringer nodes found in combined_nodes.');
        num_stringers_last_rib = 0;
        max_rib_index = NaN;
        max_stringer_index = NaN;
        rib_ranges = [];
        return;
    end

    %% 🔍 Find Max and Min Rib/Stringer Indices
    max_rib_index = max(stringer_nodes.rib_index);
    max_stringer_index = max(stringer_nodes.stringer_index);
    min_rib_index = min(stringer_nodes.rib_index);
    
    %% 🔄 Iterate Through Stringers for Ranges
    rib_ranges = zeros(max_stringer_index, 3); % Preallocate [stringer_index, min_rib, max_rib]
    num_stringers_last_rib = 0;

    for stringer_idx = 1:max_stringer_index
        % Extract nodes for the current stringer
        current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        if isempty(current_stringer_nodes)
            % If the stringer index doesn't exist in the table, skip
            continue;
        end

        % Find the minimum positive rib index for this stringer
        positive_ribs = current_stringer_nodes.rib_index(current_stringer_nodes.rib_index > 0);
        
        if isempty(positive_ribs)
            min_rib = NaN; % Assign NaN or a placeholder value if no positive ribs exist
        else
            min_rib = min(positive_ribs);
        end
        
        % Find the maximum positive rib index for this stringer
        max_rib = max(current_stringer_nodes.rib_index);

        % Check if the stringer reaches the last rib
        if any(current_stringer_nodes.rib_index == max_rib_index)
            num_stringers_last_rib = num_stringers_last_rib + 1;
        end

        % Store stringer data in rib_ranges
        rib_ranges(stringer_idx, :) = [stringer_idx, min_rib, max_rib];
    end

    %% Remove Unused Rows in rib_ranges
    rib_ranges = rib_ranges(any(rib_ranges, 2), :); % Remove rows with all zeros

    %% ✅ Output Results
    % Uncomment to display results
    % disp(['Number of stringers reaching the last rib: ', num2str(num_stringers_last_rib)]);
    % disp(['Max rib index: ', num2str(max_rib_index)]);
    % disp(['Max stringer index: ', num2str(max_stringer_index)]);
    % disp('Rib ranges for each stringer:');
    % disp(array2table(rib_ranges, 'VariableNames', {'Stringer_Index', 'Min_Rib', 'Max_Rib'}));
end
