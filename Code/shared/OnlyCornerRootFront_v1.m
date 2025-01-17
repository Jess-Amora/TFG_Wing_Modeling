function [tri_surfaces, quad_surfaces, warnings] = OnlyCornerRootFront_v1(combined_nodes)
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
% OnlyCornerRootFront_v1
% ----------------------
% This function assumes the existence of a single additional rib with rib_index = 0,
% representing the front spar rib. This special rib is currently the only auxiliary rib
% included in the model, apart from the regular ribs (rib_index ≥ 1) and the root rib 
% (rib_index = -1).
%
% Future Expansion:
% -----------------
% The current framework is designed to be flexible, allowing for the inclusion of more 
% auxiliary ribs (e.g., rib_index ≤ -3) in future versions. The logic can be extended to 
% handle these cases with minimal changes.
%
% Current Assumption:
% -------------------
% - rib_index = 0: Represents the front spar rib and is used for corner surface creation.
% - Only one instance of rib_index = 0 is allowed in the current implementation. If more 
%   auxiliary ribs are added in future iterations, the function will need to be updated 
%   accordingly to process them.
%
% Author: [Jess Bern Amora Ycong]
% Date: [17/01/25]

%% Initialization
tri_surfaces = table([], [], [], [], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio'});
quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                      'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                      'area', 'aspect_ratio'});

warnings = {};
surface_counter = 1;

%% 🔍 Extract Relevant Nodes

[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, special_rib_indices] = analyze_stringer_rib_data_v2(combined_nodes);
stringer_index = max_stringer_index;

current_stringer_nodes = combined_nodes( ...
    combined_nodes.stringer_index == stringer_index, :);

%% First Surface

node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :); % Bottom-left
node_2 = combined_nodes(combined_nodes.local_id == 1 & combined_nodes.tag == 'OnlyNode', :);       % Bottom-right
node_3 = combined_nodes(combined_nodes.local_id == max_rib_index +1 & combined_nodes.tag == 'front spars', :); % Top-right
node_4 = current_stringer_nodes(current_stringer_nodes.rib_index == 0, :); % Bottom-left

% Validate nodes
if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
    warnings{end+1} = sprintf('Skipping corner root-front_spar due to missing nodes.');
    % continue;
end

% Extract coordinates for surface property calculation
surface_coords = [
    node_1.x, node_1.y;
    node_2.x, node_2.y;
    node_3.x, node_3.y;
    node_4.x, node_4.y
];

% Compute area and aspect ratio
[is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
if ~is_valid
    warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
    % continue;
end
area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

% Append surface to quad_surfaces
quad_surfaces = [quad_surfaces; table( ...
    surface_counter, ...        % local_id
    node_1.local_id, ...        % node_1
    node_2.local_id, ...        % node_2
    node_3.local_id, ...        % node_3
    node_4.local_id, ...        % node_4
    max_stringer_index, ...         % stringer_1
    -1, ...     % stringer_2
    -1, ...                % rib_1
    0, ...            % rib_2
    "quad OnlyNode1", ...       % tags
    area, ...                   % area
    aspect_ratio, ...           % aspect_ratio
    'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                      'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                      'area', 'aspect_ratio'})];
surface_counter = surface_counter + 1;

%% EL bucle que recorre hasta la superficie triangular
if special_rib_indices.exists_rib_zero
    start_rib = 0;
else
    start_rib = 1;
end

for index_rib = start_rib:rib_ranges(max_stringer_index,3)-1
    node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == index_rib, :); % Bottom-left
    node_2 = combined_nodes(combined_nodes.rib_index == index_rib & combined_nodes.tag == 'front spars', :); % Top-right
    node_3 = combined_nodes(combined_nodes.rib_index == index_rib + 1 & combined_nodes.tag == 'front spars', :); % Top-right
    node_4 = current_stringer_nodes(current_stringer_nodes.rib_index == index_rib + 1, :); % Bottom-left
    
    % Validate nodes
    if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
        warnings{end+1} = sprintf('Skipping corner root-front_spar due to missing nodes.');
        % continue;
    end
    
    % Extract coordinates for surface property calculation
    surface_coords = [
        node_1.x, node_1.y;
        node_2.x, node_2.y;
        node_3.x, node_3.y;
        node_4.x, node_4.y
    ];
    
    % Compute area and aspect ratio
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    if ~is_valid
        warnings{end+1} = sprintf('Skipped quadrilateral due to poor aspect ratio at rib pair %d-%d.', start_rib, start_rib + 1);
        % continue;
    end
    area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
    
    % Append surface to quad_surfaces
    quad_surfaces = [quad_surfaces; table( ...
        surface_counter, ...        % local_id
        node_1.local_id, ...        % node_1
        node_2.local_id, ...        % node_2
        node_3.local_id, ...        % node_3
        node_4.local_id, ...        % node_4
        max_stringer_index, ...         % stringer_1
        -1, ...     % stringer_2
        index_rib, ...                % rib_1
        index_rib + 1, ...            % rib_2
        "quad irregular root corner", ...       % tags
        area, ...                   % area
        aspect_ratio, ...           % aspect_ratio
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'})];
    surface_counter = surface_counter + 1;
end

% Triangulo
node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == -2,:);
node_2 = current_stringer_nodes(current_stringer_nodes.rib_index == rib_ranges(max_stringer_index,3),:);       % Bottom-right
node_3 = combined_nodes(combined_nodes.rib_index == rib_ranges(max_stringer_index,3) & combined_nodes.tag == 'front spars',:);     


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
    max_stringer_index, ...            % stringer_1
    -1, ...        % stringer_2
    rib_ranges(max_stringer_index,3), ...                 % rib_1
    -2, ...                        % rib_2
    "tri last front", ...    % tags
    area, ...                      % area
    aspect_ratio, ...              % aspect_ratio
    'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                      'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                      'area', 'aspect_ratio'})];


end