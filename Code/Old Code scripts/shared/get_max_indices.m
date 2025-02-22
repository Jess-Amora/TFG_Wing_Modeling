function [max_rib_index, max_stringer_index] = get_max_indices(nodos_larguerillos)
%GET_MAX_INDICES Calculates the maximum rib and stringer indices from node data.
%
% Inputs:
%   - nodos_larguerillos: NxM matrix containing node data.
%       Column 3: Rib indices
%       Column 4: Stringer indices
%
% Outputs:
%   - max_rib_index: Highest rib index found in the data.
%   - max_stringer_index: Highest stringer index found in the data.
%
% Example:
%   [max_rib, max_stringer] = get_max_indices(nodos_larguerillos);

    %% 📊 Validate Input
    if isempty(nodos_larguerillos) || size(nodos_larguerillos, 2) < 4
        error('nodos_larguerillos must be a non-empty matrix with at least 4 columns.');
    end

    %% 📐 Extract and Validate Rib Indices
    rib_indices = nodos_larguerillos(:, 3);
    valid_rib_indices = rib_indices(rib_indices > 0 & ~isnan(rib_indices));
    
    if isempty(valid_rib_indices)
        error('No valid rib indices found in nodos_larguerillos.');
    end
    
    max_rib_index = max(valid_rib_indices); % Calculate maximum valid rib index

    %% 🛠️ Extract and Validate Stringer Indices
    stringer_indices = nodos_larguerillos(:, 4);
    valid_stringer_indices = stringer_indices(stringer_indices > 0 & ~isnan(stringer_indices));
    
    if isempty(valid_stringer_indices)
        error('No valid stringer indices found in nodos_larguerillos.');
    end
    
    max_stringer_index = max(valid_stringer_indices); % Calculate maximum valid stringer index

    % %% ✅ Display Results (Optional)
    % fprintf('Maximum Rib Index: %d\n', max_rib_index);
    % fprintf('Maximum Stringer Index: %d\n', max_stringer_index);

end
