function filtered_root_nodes = remove_spar_intrados(root_nodes, root_front_spar_intrados, root_rear_spar_intrados)
% REMOVE_SPAR_INTRADOS: Removes specific spar intrados nodes from root_nodes.
%
% Inputs:
%   root_nodes                 - Table containing all root nodes.
%   root_front_spar_intrados   - Row of the front spar intrados node.
%   root_rear_spar_intrados    - Row of the rear spar intrados node.
%
% Output:
%   filtered_root_nodes        - Root nodes table with the spar intrados nodes removed.

    % Collect local_ids to exclude
    exclude_ids = [root_front_spar_intrados.global_id; root_rear_spar_intrados.global_id];

    % Remove rows with matching local_ids
    filtered_root_nodes = root_nodes(~ismember(root_nodes.global_id, exclude_ids), :);

end
