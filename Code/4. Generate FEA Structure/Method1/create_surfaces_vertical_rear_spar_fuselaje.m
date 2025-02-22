function [quad_surfaces, warnings] = create_surfaces_vertical_rear_spar_fuselaje(combined_nodes_3D)
% CREATE_SURFACES_VERTICAL_REAR_SPAR_FUSELAJE - Generates quadrilateral surfaces for the vertical rear spar in the fuselage.
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

    %% 🔍 Extract Relevant Nodes
    rear_spar_extrados = extract_nodes_3D(combined_nodes_3D, 'rear spars fuselaje', 'extrados');
    rear_spar_intrados = extract_nodes_3D(combined_nodes_3D, 'rear spars fuselaje', 'intrados');

    if isempty(rear_spar_extrados) || isempty(rear_spar_intrados)
        warnings{end+1} = '⚠️ No valid nodes found for the rear spar fuselage.';
        return;
    end
    
    %% 🔄 Create Surfaces
    num_ribs = min(height(rear_spar_extrados), height(rear_spar_intrados)) - 1;
    if num_ribs < 1
        warnings{end+1} = '⚠️ Insufficient nodes for rear spar fuselage surface creation.';
        return;
    end
    
    for i = 1:num_ribs - 1
        % Extract four nodes
        nodes = [
            rear_spar_extrados(i, :);      % Bottom-left
            rear_spar_intrados(i, :);      % Top-left
            rear_spar_intrados(i + 1, :);  % Top-right
            rear_spar_extrados(i + 1, :)   % Bottom-right
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
        quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, "quad vertical rear fuselaje", area, aspect_ratio);
        surface_counter = surface_counter + 1;
    end

    %% 🔗 Connect Rear Spar to Root (Encastre)
    nodes = [
        rear_spar_extrados(num_ribs, :);    % Bottom-left
        rear_spar_intrados(num_ribs, :);    % Top-left
        extract_nodes_3D(combined_nodes_3D, 'rear spars', 'extrados', start_rib); % Top-right
        extract_nodes_3D(combined_nodes_3D, 'rear spars', 'intrados', start_rib)  % Bottom-right
    ];

    % Validate nodes
    if any(cellfun(@isempty, table2cell(nodes)))
        warnings{end+1} = '⚠️ Skipping root connection due to missing nodes.';
        return;
    end

    % Compute area and aspect ratio
    surface_coords = table2array(nodes(:, {'x', 'y', 'z'}));
    area = calculate_quad_area_3D(surface_coords);
    [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');

    % Append root connection surface
    quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, "quad vertical rear fuselaje root", area, aspect_ratio);
end

function nodes = extract_nodes_3D(combined_nodes, tag, h, rib_index)
    % Extracts and sorts nodes based on tag, h (extrados/intrados), and optional rib_index.
    if nargin < 4
        nodes = combined_nodes(strcmp(combined_nodes.tag, tag) & strcmp(combined_nodes.h, h), :);
    else
        nodes = combined_nodes(combined_nodes.rib_index == rib_index & strcmp(combined_nodes.tag, tag) & strcmp(combined_nodes.h, h), :);
    end
end

function quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, tag, area, aspect_ratio)
    % Creates and appends a new 3D quad surface entry to the quad_surfaces table
    
    new_surface = table( ...
        surface_counter, ...
        nodes(1, :).local_id, nodes(2, :).local_id, ...
        nodes(3, :).local_id, nodes(4, :).local_id, ...
        -2, -2, ... % Stringer indices are -2 for rear spar fuselage
        nodes(1, :).rib_index, nodes(3, :).rib_index, ...
        tag, area, aspect_ratio, ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});

    quad_surfaces = [quad_surfaces; new_surface];
end
