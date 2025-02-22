function [quad_surfaces, warnings] = create_surfaces_vertical_front_spar_wing(combined_nodes_3D)
    % CREATE_SURFACES_VERTICAL_FRONT_SPAR_WING_V1 - Generates quadrilateral surfaces for the front spar in the wing.
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
    front_spar_extrados = extract_front_spar_nodes(combined_nodes_3D, 'extrados');
    front_spar_intrados = extract_front_spar_nodes(combined_nodes_3D, 'intrados');

    if isempty(front_spar_extrados) || isempty(front_spar_intrados)
        warnings{end+1} = '⚠️ No valid nodes found for front spar.';
        return;
    end

    %% 🔄 Loop to Create Surfaces
    num_ribs = min(height(front_spar_extrados), height(front_spar_intrados)) - 1;
    if num_ribs < 1
        warnings{end+1} = '⚠️ Insufficient nodes for the front spar rib range.';
        return;
    end

    for i = 1:num_ribs - 1
        % Extract four nodes
        nodes = [
            front_spar_extrados(i, :);      % Bottom-left
            front_spar_intrados(i, :);      % Top-left
            front_spar_intrados(i + 1, :);  % Top-right
            front_spar_extrados(i + 1, :)   % Bottom-right
        ];

        % Validate nodes
        if any(cellfun(@isempty, table2cell(nodes)))
            warnings{end+1} = sprintf('⚠️ Skipping surface at rib %d due to missing nodes.', nodes(1, :).rib_index);
            continue;
        end

        % Compute area and aspect ratio
        surface_coords = table2array(nodes(:, {'x', 'y', 'z'}));
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');

        % Append surface if valid
        quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, "quad vertical front", area, aspect_ratio);
        surface_counter = surface_counter + 1;
    end
end

%% **📌 Helper Functions**
function nodes = extract_front_spar_nodes(combined_nodes, h)
    % Extracts nodes for the front spar based on h ('extrados' or 'intrados')
    nodes = [
        combined_nodes(combined_nodes.rib_index == 1e5 & strcmp(combined_nodes.h, h), :);
        sortrows(combined_nodes(strcmp(combined_nodes.tag, 'front spars') & strcmp(combined_nodes.h, h), :), 'rib_index')
    ];
end

function quad_surfaces = append_quad_surface_3D(quad_surfaces, nodes, surface_counter, tag, area, aspect_ratio)
    % Appends a new quadrilateral surface to the quad_surfaces table
    new_surface = table( ...
        surface_counter, ...
        nodes(1, :).local_id, nodes(2, :).local_id, ...
        nodes(3, :).local_id, nodes(4, :).local_id, ...
        -1, -1, ...
        nodes(1, :).rib_index, nodes(3, :).rib_index, ...
        tag, area, aspect_ratio, ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});

    quad_surfaces = [quad_surfaces; new_surface]; % Concatenate safely
end
