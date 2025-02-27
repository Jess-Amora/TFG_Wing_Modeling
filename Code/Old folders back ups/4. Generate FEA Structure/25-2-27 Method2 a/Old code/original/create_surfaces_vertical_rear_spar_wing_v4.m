function [quad_surfaces, warnings] = create_surfaces_vertical_rear_spar_wing(combined_nodes_3D)
% CREATE_SURFACES_VERTICAL_REAR_SPAR_WING - Generates quadrilateral surfaces for the vertical rear spar in the wing.
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

    %% 🔍 Extract Relevant Nodes
    rear_spar_extrados = extract_nodes(combined_nodes_3D, 'rear spars', rib_ranges(1,2), 'extrados');
    rear_spar_intrados = extract_nodes(combined_nodes_3D, 'rear spars', rib_ranges(1,2), 'intrados');

    if isempty(rear_spar_extrados) || isempty(rear_spar_intrados)
        warnings{end+1} = '⚠️ No valid nodes found for the rear spar.';
        return;
    end

    %% 🔄 Create Surfaces
    for i = 1:min(height(rear_spar_extrados), height(rear_spar_intrados)) - 1 
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
        quad_surfaces = append_quad_surface(quad_surfaces, nodes, surface_counter, "quad vertical rear spar", area, aspect_ratio);
        surface_counter = surface_counter + 1;
    end
end

function nodes = extract_nodes(combined_nodes, tag, min_rib, h)
    % Extracts nodes based on tag, rib index, and h (if provided)
    if nargin < 4
        nodes = combined_nodes(strcmp(combined_nodes.tag, tag) & combined_nodes.rib_index >= min_rib, :);
    else
        nodes = combined_nodes(strcmp(combined_nodes.tag, tag) & combined_nodes.rib_index >= min_rib & strcmp(combined_nodes.h, h), :);
    end
end
function quad_surfaces = append_quad_surface(quad_surfaces, nodes, surface_counter, tag, area, aspect_ratio)
    % Creates and appends a new quad surface entry to the quad_surfaces table
    
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
