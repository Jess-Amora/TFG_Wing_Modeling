function [quad_surfaces, surface_counter] = create_surfaces_from_a_rib_vertical( ...
    vector_stringer_extrados, vector_stringer_intrados,...
    rib_index, tag, h, initial_surface_counter)
% CREATE_SURFACES_FROM_A_RIB_VERTICAL: Creates quadrilateral (CQUAD4) surfaces from consecutive rib nodes.
%
% Inputs:
%   vector_front_spar_extrados - Table with extrados front spar nodes.
%   vector_front_spar_intrados - Table with intrados front spar nodes.
%   vector_rear_spar_extrados  - Table with extrados rear spar nodes.
%   vector_rear_spar_intrados  - Table with intrados rear spar nodes.
%   rib_index                  - Rib index for the surfaces being created.
%   tag                        - Classification tag for the quads (e.g., 'quad vertical rib').
%   h                          - Indicates 'extrados' or 'intrados'.
%   initial_surface_counter    - Initial surface counter value.
%
% Outputs:
%   quad_surfaces              - Table containing the created quadrilateral surfaces.
%   surface_counter            - Updated surface counter after adding all surfaces.

    %% 📝 Initialize Quad Surfaces Table
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio', 'h'});

    %% 🔄 Iterate Through Consecutive Rib Nodes
    surface_counter = initial_surface_counter; % Start with the given counter
    
    if height(vector_stringer_extrados) ~=   height(vector_stringer_intrados)
            warning('vector height mismatch detected at rib %d: Extrados = %d, Intrados = %d', ...
                rib_index, height(vector_stringer_extrados),  height(vector_stringer_intrados));
    end

    for i = 1:min([height(vector_stringer_extrados),  height(vector_stringer_intrados)])-1
        
        % Extract consecutive nodes (forming a quadrilateral)
        node_1 = vector_stringer_extrados(i, :); % Bottom-left
        node_2 = vector_stringer_extrados(i + 1, :); % Top-left
        node_3 = vector_stringer_intrados(i + 1, :);  % Top-right
        node_4 = vector_stringer_intrados(i, :);  % Bottom-right

        stringer_1 = node_1.stringer_index;
        stringer_2 = node_2.stringer_index;


        % Use the create_new_surface_vertical function to create a quadrilateral surface
        [quad_surfaces, surface_counter] = create_new_surface_vertical(node_1, node_2, node_3, node_4, stringer_1, stringer_2, ...
                                                                        rib_index, rib_index, tag, h, surface_counter, quad_surfaces);
    end

end
