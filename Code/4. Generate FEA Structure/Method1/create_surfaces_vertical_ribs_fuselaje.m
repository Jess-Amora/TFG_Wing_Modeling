function [quad_surfaces, warnings] = create_surfaces_vertical_ribs_fuselaje(combined_nodes_3D)
% CREATE_SURFACES_VERTICAL_RIBS_FUSELAJE - Generates quadrilateral surfaces for vertical ribs in the fuselage.
%
% Inputs:
%   combined_nodes_3D - Table containing node data (x, y, z, rib_index, tag, etc.)
%
% Outputs:
%   quad_surfaces - Table containing generated quadrilateral surfaces.
%   warnings - Cell array containing warnings for skipped or invalid surfaces.

    %% 📝 Initialization    
    quad_surfaces = quad_initialize();
    warnings = {};
    surface_counter = 1;
    
    [~, ~, ~, rib_ranges] = analyze_stringer_rib_data(combined_nodes_3D);
    start_rib = rib_ranges(1,2);

    %% 🔍 Extract and Sort Relevant Nodes
    front_spar_extrados = extract_sorted_nodes_3D(combined_nodes_3D, 'front spars fuselaje', 'extrados');
    front_spar_intrados = extract_sorted_nodes_3D(combined_nodes_3D, 'front spars fuselaje', 'intrados');
    rear_spar_extrados = extract_sorted_nodes_3D(combined_nodes_3D, 'rear spars fuselaje', 'extrados');
    rear_spar_intrados = extract_sorted_nodes_3D(combined_nodes_3D, 'rear spars fuselaje', 'intrados');

    % Debug: Check filtered nodes
    if any(cellfun(@isempty, {front_spar_extrados, front_spar_intrados, rear_spar_extrados, rear_spar_intrados}))
        warnings{end+1} = '⚠️ No valid nodes found for vertical ribs.';
        return;
    end
    
    %% 🔄 Create Surfaces
    num_ribs = min(height(rear_spar_extrados), height(rear_spar_intrados));
    if num_ribs < 1
        warnings{end+1} = '⚠️ Insufficient nodes for vertical rib surface creation.';
        return;
    end
    
    % Process every second rib (even indices only)
    for i = 2:2:num_ribs
        % Extract four nodes
        nodes = [
            front_spar_extrados(i, :); % Bottom-left
            front_spar_intrados(i, :); % Top-left
            rear_spar_intrados(i, :);  % Top-right
            rear_spar_extrados(i, :)   % Bottom-right
        ];

        % Validate nodes
        if any(cellfun(@isempty, table2cell(nodes)))
            warnings{end+1} = sprintf('⚠️ Skipping surface at rib %d due to missing nodes.', nodes(1, :).rib_index);
            continue;
        end

        % Compute area and aspect ratio
        surface_coords = table2array(nodes(:, {'x', 'y', 'z'}));
        area = calculate_quad_area_3D(surface_coords);
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');

        % Append surface if valid
        quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, "quad vertical rib fuselaje", area, aspect_ratio);
        surface_counter = surface_counter + 1;
    end
end

function nodes = extract_sorted_nodes_3D(combined_nodes, tag, h)
    % Extracts and sorts nodes based on tag and h (extrados/intrados).
    nodes = sortrows(combined_nodes(strcmp(combined_nodes.tag, tag) & strcmp(combined_nodes.h, h), :), 'rib_index');
end

function quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, tag, area, aspect_ratio)
    % Creates and appends a new 3D quad surface entry to the quad_surfaces table
    
    new_surface = table( ...
        surface_counter, ...
        nodes(1, :).local_id, nodes(2, :).local_id, ...
        nodes(3, :).local_id, nodes(4, :).local_id, ...
        nodes(1, :).stringer_index, nodes(3, :).stringer_index, ...
        nodes(1, :).rib_index, nodes(3, :).rib_index, ...
        tag, area, aspect_ratio, ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});

    quad_surfaces = [quad_surfaces; new_surface];
end
