function superficie_horizontal_larguero_posterior = create_rear_spar_surfaces_v4(...
    combined_nodes, start_rib, end_rib)
% create_rear_spar_surfaces_v4: Creates horizontal stiffening panels near the rear spar with metadata.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag]
%   start_rib: Starting rib index for rear spar surface creation
%   end_rib: Ending rib index for rear spar surface creation
%
% Outputs:
%   superficie_horizontal_larguero_posterior: Table with columns:
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

    %% 🛡️ Validate Inputs
    if ~istable(combined_nodes)
        error('Input "combined_nodes" must be a MATLAB table.');
    end

    required_vars = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
    if ~all(ismember(required_vars, combined_nodes.Properties.VariableNames))
        error('Table must have the following columns: %s', strjoin(required_vars, ', '));
    end

    %% 📝 Initialize Output Table
    superficie_horizontal_larguero_posterior = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});

    surface_counter = 1; % Initialize surface counter

    %% 🔧 Update Stringer Index for Rear Spar Nodes
    % Assign stringer_index = -2 for rear spar nodes
    combined_nodes.stringer_index(strcmp(combined_nodes.tag, 'rear spars')) = -2;

    %% 🔍 Filter Rear Spar and First Stringer Nodes
    rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'), :);
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1, :);

    if isempty(rear_spar_nodes) || isempty(stringer_nodes)
        warning('No valid rear spar or stringer nodes found in the combined_nodes table.');
        return;
    end

    %% 🔄 Loop Through Ribs to Create Surfaces
    for index_costilla = start_rib:end_rib
        % Filter nodes for the current rib
        rear_spar_rib1 = rear_spar_nodes(rear_spar_nodes.rib_index == index_costilla, :);
        rear_spar_rib2 = rear_spar_nodes(rear_spar_nodes.rib_index == index_costilla + 1, :);
        stringer_rib1 = stringer_nodes(stringer_nodes.rib_index == index_costilla, :);
        stringer_rib2 = stringer_nodes(stringer_nodes.rib_index == index_costilla + 1, :);

        if isempty(rear_spar_rib1) || isempty(rear_spar_rib2) || isempty(stringer_rib1) || isempty(stringer_rib2)
            warning('Skipping rib %d: Insufficient nodes detected.', index_costilla);
            continue;
        end

        % Extract Node IDs and Coordinates
        node_1 = rear_spar_rib1.local_id(1); % Rear spar at rib 1
        node_2 = stringer_rib1.local_id(1);  % First stringer at rib 1
        node_3 = stringer_rib2.local_id(1);  % First stringer at rib 2
        node_4 = rear_spar_rib2.local_id(1); % Rear spar at rib 2

        % Extract Rib and Stringer Indices
        rib_1 = rear_spar_rib1.rib_index(1);
        rib_2 = rear_spar_rib2.rib_index(1);
        stringer_1 = -2; % Fixed for rear spar
        stringer_2 = 1;  % Fixed for first stringer

        % Calculate Area and Aspect Ratio
        surface_coords = [rear_spar_rib1.x(1), rear_spar_rib1.y(1); ...
                          stringer_rib1.x(1), stringer_rib1.y(1); ...
                          stringer_rib2.x(1), stringer_rib2.y(1); ...
                          rear_spar_rib2.x(1), rear_spar_rib2.y(1)];
        
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warning('Skipping surface at rib %d due to poor aspect ratio.', index_costilla);
            continue;
        end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Create Surface Panel with Metadata
        new_surface = table( ...
            surface_counter, ...        % local_id
            node_1, ...                 % node_1
            node_2, ...                 % node_2
            node_3, ...                 % node_3
            node_4, ...                 % node_4
            stringer_1, ...             % stringer_1 (rear spar)
            stringer_2, ...             % stringer_2 (first stringer)
            rib_1, ...                  % rib_1
            rib_2, ...                  % rib_2
            "rear_spar_surface", ...    % tags
            area, ...                   % area
            aspect_ratio, ...           % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'});

        % Append the new surface to the output table
        superficie_horizontal_larguero_posterior = [superficie_horizontal_larguero_posterior; new_surface];

        % Increment surface counter
        surface_counter = surface_counter + 1;
    end

    %% ✅ Display Success Message
    disp('✅ Rear spar surfaces with metadata successfully created.');
end
