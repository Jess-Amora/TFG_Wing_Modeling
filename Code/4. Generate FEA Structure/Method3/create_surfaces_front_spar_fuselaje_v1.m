function [quad_surfaces, warnings] = create_surfaces_front_spar_fuselaje_v1(combined_nodes_fuselaje, combined_nodes)
    

[num_stringers_last_rib, max_rib, max_stringer, rib_ranges] = analyze_stringer_rib_data_v5(combined_nodes);

%% 📝 Initialization    
quad_surfaces = quad_initialize();
warnings = {};
surface_counter = 1;

%% 🔍 Filter Nodes by Stringer and Rib
current_stringer_nodes = combined_nodes_fuselaje(combined_nodes_fuselaje.stringer_index == max_stringer, :);


% Debug: Check filtered nodes
if isempty(current_stringer_nodes)
    warnings{end+1} = sprintf('No valid nodes found for stringer %d and its neighbor.', stringer_index);
    return;
end

%% 🔄 Loop Through Nodes to Create Surfaces
num_ribs = height(current_stringer_nodes) - 1;
if num_ribs < 1
    warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', stringer_index);
    return;
end

for i = 1:num_ribs - 1
    % Extract nodes for the quadrilateral
    node1 = current_stringer_nodes(i, :);        % Top-left
    node2 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == i & combined_nodes_fuselaje.tag == 'front spars fuselaje', :);          % Bottom-left
    node3 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == i + 1 & combined_nodes_fuselaje.tag == 'front spars fuselaje', :);          % Bottom-right
    node4 = current_stringer_nodes(i + 1, :);         % Top-right
    
    % Extract Rib and Stringer Indices
    stringer_1 = max_stringer; % Fixed for rear spar
    stringer_2 = -1;  % Fixed for first stringer
    rib_1 = node1.rib_index;
    rib_2 = node3.rib_index;
    tag = "quad fuselaje front";
    
    % Call the function
    [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                       node1, node2, node3, node4, ...
                                                                       stringer_1, stringer_2, rib_1, rib_2);


    % % Ensure nodes are not empty
    % if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
    %     warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', start_rib + i - 1);
    %     continue;
    % end
    % 
    % % Extract coordinates for surface property calculation
    % surface_coords = [
    %     node_1.x(1), node_1.y(1);
    %     node_2.x(1), node_2.y(1);
    %     node_3.x(1), node_3.y(1);
    %     node_4.x(1), node_4.y(1)
    % ];
    % 
    % % Compute area and aspect ratio
    % [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
    % % if ~is_valid
    % %     warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
    % %     continue;
    % % end
    % area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
    % 
    % % Append surface to table
    % new_surface = table( ...
    %     surface_counter, ...        % local_id
    %     node_1.local_id, ...        % node_1
    %     node_2.local_id, ...        % node_2
    %     node_3.local_id, ...        % node_3
    %     node_4.local_id, ...        % node_4
    %     max_stringer, ...         % stringer_1
    %     -1, ...     % stringer_2
    %     node_1.rib_index, ...       % rib_1
    %     node_3.rib_index, ...       % rib_2
    %     "quad fuselaje front", ...         % tags
    %     area, ...                   % area
    %     aspect_ratio, ...           % aspect_ratio
    %     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
    %                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
    %                       'area', 'aspect_ratio'});
    % quad_surfaces = [quad_surfaces; new_surface];
    % 
    % % Increment surface counter
    % surface_counter = surface_counter + 1;
end
    
%% Connect surface to the root with the wing

% Extract nodes for the quadrilateral
node1 = current_stringer_nodes(num_ribs, :);
node2 = combined_nodes_fuselaje(combined_nodes_fuselaje.rib_index == num_ribs & combined_nodes_fuselaje.tag == 'front spars fuselaje', :);
% node_3 = combined_nodes(combined_nodes.local_id == 1 & combined_nodes.tag == 'OnlyNode', :); 
node3 = combined_nodes(combined_nodes.rib_index == 1e5 & combined_nodes.tag == 'front spars', :); 
node4 = combined_nodes(combined_nodes.rib_index == -1 & combined_nodes.stringer_index == max_stringer, :);

% Extract Rib and Stringer Indices
    stringer_1 = max_stringer; % Fixed for rear spar
    stringer_2 = -1;  % Fixed for first stringer
    rib_1 = num_ribs;
    rib_2 = -1;
    tag = "quad fuselaje front root";
    
    % Call the function
    [quad_surfaces, surface_counter, warning_surface] = append_quad_surface_3D(quad_surfaces, surface_counter, tag, ...
                                                                       node1, node2, node3, node4, ...
                                                                       stringer_1, stringer_2, rib_1, rib_2);


% % Ensure nodes are not empty
% if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
%     warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', start_rib + i - 1);
% end
% 
% % Extract coordinates for surface property calculation
% surface_coords = [
%     node_1.x(1), node_1.y(1);
%     node_2.x(1), node_2.y(1);
%     node_3.x(1), node_3.y(1);
%     node_4.x(1), node_4.y(1)
% ];
% 
% % Compute area and aspect ratio
% [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
% % if ~is_valid
% %     warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
% %     continue;
% % end
% area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
% 
% % Append surface to table
% new_surface = table( ...
%     surface_counter, ...        % local_id
%     node_1.local_id, ...        % node_1
%     node_2.local_id, ...        % node_2
%     node_3.local_id, ...        % node_3
%     node_4.local_id, ...        % node_4
%     max_stringer, ...         % stringer_1
%     -1, ...     % stringer_2
%     num_ribs, ...       % rib_1
%     -1, ...       % rib_2
%     "quad fuselaje front root", ...         % tags
%     area, ...                   % area
%     aspect_ratio, ...           % aspect_ratio
%     'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
%                       'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
%                       'area', 'aspect_ratio'});
% quad_surfaces = [quad_surfaces; new_surface];

end