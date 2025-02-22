function end_rib = determine_end_rib(combined_nodes, stringer_index)
% DETERMINE_END_RIB - Finds the end rib dynamically, handling irregular cases.

    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1, :);
    
    next_rib_indices = unique(next_stringer_nodes.rib_index); % Extract unique rib indices

    if any(next_rib_indices == -100) % Special root condition
        valid_ribs = next_rib_indices(next_rib_indices ~= -100);
        if ~isempty(valid_ribs)
            end_rib = max(valid_ribs);
        else
            warning('No valid ribs found besides -100. Using fallback rib index.');
            end_rib = -99; % Default fallback
        end
    else
        end_rib = max(next_rib_indices);
    end
end
