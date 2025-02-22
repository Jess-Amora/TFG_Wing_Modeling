function num_stringers_last_rib = calculate_stringers_to_last_rib(combined_nodes)
% calculate_stringers_to_last_rib: Determines the number of stringers reaching the last rib.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%
% Outputs:
%   num_stringers_last_rib: Number of stringers that reach the last rib.

    %% 📝 Filter Relevant Nodes
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);

    % Ensure there are stringer nodes
    if isempty(stringer_nodes)
        warning('No stringer nodes found in combined_nodes.');
        num_stringers_last_rib = 0;
        return;
    end

    %% 🔍 Find the Last Rib Index
    last_rib_index = max(stringer_nodes.rib_index);

    %% 🔄 Iterate Through Stringers
    num_stringers_last_rib = 0;
    max_stringer_index = max(stringer_nodes.stringer_index);

    for stringer_idx = 1:max_stringer_index
        % Extract nodes for the current stringer
        current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        % Check if the current stringer has a node in the last rib
        if any(current_stringer_nodes.rib_index == last_rib_index)
            num_stringers_last_rib = num_stringers_last_rib + 1;
        else
            % Break if the current stringer doesn't reach the last rib
            break;
        end
    end

    %% ✅ Output
    % disp(['Number of stringers reaching the last rib: ', num2str(num_stringers_last_rib)]);
end
