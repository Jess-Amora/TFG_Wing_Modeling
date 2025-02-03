function [tri_surfaces, warnings] = create_first_surface_root(combined_nodes, stringer_index, start_rib)
% Iteratively creates quadrilateral surfaces for irregular zones until the endpoint or triangle.
%
% Inputs:
%   combined_nodes: Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%   inserted_table: Table with additional inserted nodes [local_id, x, y, rib_index, stringer_index, tag].
%   stringer_index: Index of the current stringer.
%   start_rib: Starting rib index for the irregular zone.
%
% Outputs:
%   quad_surfaces: Table with surface properties for irregular quadrilaterals.
%   warnings: Cell array with warnings about skipped or invalid surfaces.

    %% Initialization
    tri_surfaces = table([], [], [], [], [], [], [], [], [], [], [], ...
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'});
    warnings = {};

    %% 🔍 Extract Relevant Nodes
    stringer_index =1;
    current_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index, :);

    next_stringer_nodes = combined_nodes( ...
        combined_nodes.stringer_index == stringer_index + 1, :);

    [num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data_v5(combined_nodes);
    start_rib = rib_ranges(1,2);

    %% Create First Surface
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes)
            % Triangulo
            node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
            node_2 = combined_nodes(combined_nodes.tag =='rear spars' & combined_nodes.rib_index == start_rib,:); % Bottom-left
            node_3 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);
            
            % Validate Nodes
            if isempty(node_1) || isempty(node_2) || isempty(node_3)
                warnings{end+1} = sprintf('Skipping final triangular surface due to missing nodes at stringer %d.', stringer_index);
                % return;
            end
        
            % Extract Coordinates for Surface Property Calculation
            surface_coords = [
                node_1.x, node_1.y;
                node_2.x, node_2.y;
                node_3.x, node_3.y
            ];
        
            % Compute area and aspect ratio
            area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
            [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');
            if ~is_valid
                warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio at stringer %d.', stringer_index);
                % return;
            end
        
            % Append Surface to tri_surfaces
            tri_surfaces = [tri_surfaces; table( ...
                1, ...       % local_id
                node_1.local_id, ...           % node_1
                node_2.local_id, ...           % node_2
                node_3.local_id, ...           % node_3
                stringer_index, ...            % stringer_1
                stringer_index + 1, ...        % stringer_2
                 -1, ...                 % rib_1
                 start_rib, ...                        % rib_2
                "tri corner root", ...    % tags
                area, ...                      % area
                aspect_ratio, ...              % aspect_ratio
                'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                                  'area', 'aspect_ratio'})];

    end
end