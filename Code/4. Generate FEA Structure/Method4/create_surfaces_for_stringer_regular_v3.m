function [quad_surfaces, warnings] = create_surfaces_for_stringer_regular_v3(...
    combined_nodes, stringer_index, varargin)
% Handles general surface creation between two stringers for regular zones.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the region.
%   end_rib: Ending rib index for the region.
%   threshold_distance: Minimum distance threshold for surface validity.
%
% Outputs:
%   quad_surfaces: Table with columns:
%       - local_id: Unique surface identifier.
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface.
%       - stringer_1, stringer_2: Stringer indices defining the surface.
%       - rib_1, rib_2: Rib indices defining the surface.
%       - tags: Surface type (e.g., 'quad regular').
%       - area: Precomputed area of the surface.
%       - aspect_ratio: Aspect ratio of the surface.
%   warnings: Cell array with warnings.

    %% 📝 Initialization
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;
    
    [num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v5(combined_nodes);
    start_rib = rib_ranges(stringer_index,2);
    
    % Handle optional end_rib input
    if nargin >= 3 && ~isempty(varargin{1})
        end_rib = varargin{1};  % Use provided end_rib
    else
        end_rib = max_rib_index;  % Default to max_rib_index
    end

    %% 🔍 Filter Nodes by Stringer and Rib
    current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index & ...
                                             combined_nodes.rib_index >= start_rib & ...
                                             combined_nodes.rib_index <= end_rib, :);
    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                                          combined_nodes.rib_index >= start_rib & ...
                                          combined_nodes.rib_index <= end_rib, :);

   if isempty(current_stringer_nodes) || isempty(next_stringer_nodes)
        warning('No valid rear spar or stringer nodes found in the combined_nodes table.');
        return;
    end

    % Check if both tables have the same number of rows (height)
    if height(current_stringer_nodes) ~= height(next_stringer_nodes)
        error('Mismatch in table heights: rear_spar_nodes has %d rows, while stringer_nodes has %d rows.', ...
              height(current_stringer_nodes), height(next_stringer_nodes));
    end

    for i = 1:height(current_stringer_nodes)-1
        % Extract nodes for the quadrilateral
        node1 = current_stringer_nodes(i, :);          % Bottom-left
        node4 = current_stringer_nodes(i + 1, :);      % Top-left
        node3 = next_stringer_nodes(i + 1, :);         % Top-right
        node2 = next_stringer_nodes(i, :);             % Bottom-right

        % Extract Rib and Stringer Indices
        stringer_1 = node1.stringer_index; % Fixed for rear spar
        stringer_2 = node3.stringer_index;  % Fixed for first stringer
        rib_1 = node1.rib_index;
        rib_2 = node3.rib_index;
        tag = "quad regular";
        
        % Call the function
        [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                           node1, node2, node3, node4, ...
                                                                           stringer_1, stringer_2, rib_1, rib_2);
    end

    %% ✅ Success Message
    % disp('✅ Regular quadrilateral surfaces created successfully.');
end
