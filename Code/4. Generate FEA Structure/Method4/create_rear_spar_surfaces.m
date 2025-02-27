function [quad_surface, warning_surface] = create_rear_spar_surfaces(...
    combined_nodes)
% create_rear_spar_surfaces_v4: Creates horizontal stiffening panels near the rear spar with metadata.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   start_rib: Starting rib index for rear spar surface creation
%   end_rib: Ending rib index for rear spar surface creation
%
% Outputs:
%   quad_surface: Table with columns:
%       - local_id: Unique surface identifier
%       - node_1: Node ID for the first corner of the surface
%       - node_2: Node ID for the second corner of the surface
%       - node_3: Node ID for the third corner of the surface
%       - node_4: Node ID for the fourth corner of the surface (or NaN for lines/triangles)
%       - stringer_1: Stringer index corresponding to node_1 (rear spar = -2)
%       - stringer_2: Stringer index corresponding to node_2 (first stringer = 1)
%       - rib_1: Rib index corresponding to node_1
%       - rib_2: Rib index corresponding to node_2
%       - tags: Tag describing the surface type (e.g., 'rear_spar_surface')
%       - area: Precomputed area of the surface
%       - aspect_ratio: Aspect ratio of the surface

[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes);

% start_rib = 
    %% 🛡️ Validate Inputs
    if ~istable(combined_nodes)
        error('Input "combined_nodes" must be a MATLAB table.');
    end

    required_vars = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
    if ~all(ismember(required_vars, combined_nodes.Properties.VariableNames))
        error('Table must have the following columns: %s', strjoin(required_vars, ', '));
    end

    %% 📝 Initialize Output Table
    quad_surface = quad_initialize();
    warning_surface = quad_initialize();
    surface_counter = 1; % Initialize surface counter

    %% 🔍 Filter Rear Spar and First Stringer Nodes
    rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars') & combined_nodes.rib_index >= rib_ranges(1,2), :);
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1  & combined_nodes.rib_index >= rib_ranges(1,2), :);


    if isempty(rear_spar_nodes) || isempty(stringer_nodes)
        warning('No valid rear spar or stringer nodes found in the combined_nodes table.');
        return;
    end

    % Check if both tables have the same number of rows (height)
    if height(rear_spar_nodes) ~= height(stringer_nodes)
        error('Mismatch in table heights: rear_spar_nodes has %d rows, while stringer_nodes has %d rows.', ...
              height(rear_spar_nodes), height(stringer_nodes));
    end


    %% 🔄 Loop Through Ribs to Create Surfaces
    for i = 1:min(height(rear_spar_nodes),height(stringer_nodes))-1
        % Filter nodes for the current rib
        node1 = rear_spar_nodes(i, :);          % Top-left
        node2 = stringer_nodes(i, :);             % Bottom-left
        node3 = stringer_nodes(i + 1, :);         % Bottom-right
        node4 = rear_spar_nodes(i + 1, :);      % Top-right
        

        % Extract Rib and Stringer Indices
        stringer_1 = node1.stringer_index; % Fixed for rear spar
        stringer_2 = node3.stringer_index;  % Fixed for first stringer
        rib_1 = node1.rib_index;
        rib_2 = node3.rib_index;
        tag = "quad rear horizontal 2D";
        
        % Call the function
        [quad_surface, surface_counter, warning_surface] = append_quad_surface_3D(quad_surface, surface_counter, tag, ...
                                                                           node1, node2, node3, node4, ...
                                                                           stringer_1, stringer_2, rib_1, rib_2);
    end

    %% ✅ Display Success Message
    % disp('✅ Rear spar surfaces with metadata successfully created.');
end
