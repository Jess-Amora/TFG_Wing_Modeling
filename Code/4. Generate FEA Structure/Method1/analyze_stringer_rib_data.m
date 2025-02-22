function [num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes)
% analyze_stringer_rib_data_v5: Analyzes stringer and rib data, including bounded ranges for both stringers and ribs.
%
% Inputs:
%   combined_nodes - Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%
% Outputs:
%   num_stringers_last_rib  - Number of stringers that reach the last rib.
%   max_rib_index           - Maximum rib index (ignoring special indices like -1, 0, or >= special cutoff).
%   max_stringer_index      - Maximum stringer index.
%   rib_ranges              - Nx3 matrix where each row corresponds to a stringer:
%                             [stringer_index, min_rib_index, max_rib_index].
%   rib_ranges_by_ribs      - Mx3 matrix where each row corresponds to a rib:
%                             [rib_index, min_stringer_index, max_stringer_index].
%   special_rib_indices     - Struct containing information about special rib indices.
%   max_ribs_fuselaje       - Maximum rib index for nodes tagged as 'stringer fuselaje'.

    %% 📝 Filter Relevant Nodes
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);
    fuselage_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer fuselaje'), :);

    % Ensure there are stringer nodes
    if isempty(stringer_nodes)
        warning('No stringer nodes found in combined_nodes.');
        num_stringers_last_rib = 0;
        max_rib_index = NaN;
        max_stringer_index = NaN;
        rib_ranges = [];
        rib_ranges_by_ribs = [];
        special_rib_indices = struct('exists_rib_zero', false, ...
                                     'exists_negative_ribs', false, ...
                                     'special_ribs', []);
        max_ribs_fuselaje = NaN;
        return;
    end

    %% 🔍 Detect and Filter Special Rib Indices
    special_rib_cutoff = 1e4; % Define special rib indices as >= 1e4
    special_ribs = unique(stringer_nodes.rib_index(stringer_nodes.rib_index >= special_rib_cutoff)); % Detect special indices

    % Filter out special indices for regular ribs
    regular_ribs = stringer_nodes.rib_index(stringer_nodes.rib_index > 0 & stringer_nodes.rib_index < special_rib_cutoff);
    
    % Compute the max rib index only for regular ribs
    max_rib_index = max(regular_ribs);

    % Compute max stringer index
    max_stringer_index = max(stringer_nodes.stringer_index);

    % Compute max ribs for fuselage nodes
    if ~isempty(fuselage_nodes)
        max_ribs_fuselaje = max(fuselage_nodes.rib_index);
    else
        max_ribs_fuselaje = NaN;
        % warning('No fuselage nodes (tag == "stringer fuselaje") found in combined_nodes.');
    end

    %% ✅ Detect Special Rib Indices
    exists_rib_zero = any(stringer_nodes.rib_index == 0); % Check if rib_index = 0 exists
    exists_negative_ribs = any(stringer_nodes.rib_index <= -3); % Check if rib_index <= -3 exists

    % Store results in a struct
    special_rib_indices = struct('exists_rib_zero', exists_rib_zero, ...
                                 'exists_negative_ribs', exists_negative_ribs, ...
                                 'special_ribs', special_ribs);

    %% 🔄 Calculate Stringer Rib Ranges
    rib_ranges = zeros(max_stringer_index, 3); % Preallocate [stringer_index, min_rib, max_rib]
    num_stringers_last_rib = 0;

    for stringer_idx = 1:max_stringer_index
        % Extract nodes for the current stringer
        current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        if isempty(current_stringer_nodes)
            continue; % Skip if no nodes for this stringer
        end

        % Exclude special rib indices when calculating min and max rib indices
        positive_ribs = current_stringer_nodes.rib_index(current_stringer_nodes.rib_index > 0 & current_stringer_nodes.rib_index < special_rib_cutoff);
        min_rib = min(positive_ribs);
        max_rib = max(positive_ribs);

        % Check if the stringer reaches the last rib
        if any(positive_ribs == max_rib_index)
            num_stringers_last_rib = num_stringers_last_rib + 1;
        end

        % Store stringer data in rib_ranges
        rib_ranges(stringer_idx, :) = [stringer_idx, min_rib, max_rib];
    end

    rib_ranges = rib_ranges(any(rib_ranges, 2), :); % Remove rows with all zeros

    %% 🔄 Calculate Rib Ranges
    unique_ribs = unique(stringer_nodes.rib_index(stringer_nodes.rib_index > 0 & stringer_nodes.rib_index < special_rib_cutoff));
    rib_ranges_by_ribs = zeros(length(unique_ribs), 3); % Preallocate [rib_index, min_stringer, max_stringer]

    for i = 1:length(unique_ribs)
        rib = unique_ribs(i);

        % Extract nodes for the current rib
        current_rib_nodes = stringer_nodes(stringer_nodes.rib_index == rib, :);

        % Find min and max stringer indices for this rib
        min_stringer = min(current_rib_nodes.stringer_index);
        max_stringer = max(current_rib_nodes.stringer_index);

        % Store rib data in rib_ranges_by_ribs
        rib_ranges_by_ribs(i, :) = [rib, min_stringer, max_stringer];
    end

    %% ✅ Output Results
    % Uncomment to display results
    % disp('Rib ranges for each rib:');
    % disp(array2table(rib_ranges_by_ribs, 'VariableNames', {'Rib_Index', 'Min_Stringer', 'Max_Stringer'}));
end
