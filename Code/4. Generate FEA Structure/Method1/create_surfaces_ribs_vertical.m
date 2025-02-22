function [quad_surfaces_ala, quad_surfaces_fuselaje, warnings] = create_surfaces_ribs_vertical(combined_nodes_3D)
% Creates lines from consecutive rows in a vector_stringer table.
%
% Inputs:
%   vector_stringer   - Table with rows representing nodes in the stringer.
%   stringer_index    - Index of the stringer being processed.
%   tag               - Tag to classify the lines (e.g., 'stringer').
%   h                 - Indicates 'extrados' or 'intrados'.
%   initial_line_counter - Initial line counter value.
%
% Outputs:
%   lines             - Table containing the created lines.
%   line_counter      - Updated line counter after adding all lines.

    %% 📝 Initialize Lines Table
    quad_surfaces_ala = quad_initialize(true);
    quad_surfaces_fuselaje = quad_initialize(true);
    warnings = {};
    surface_counter = 1;

    [~, max_rib_index, ~, ~, rib_ranges_by_ribs, ~, max_ribs_fuselaje] = analyze_stringer_rib_data(combined_nodes_3D);

%% Creación de las barras verticales en las costillas

% Loop over unique rib numbers for the ala
unique_ribs = rib_ranges_by_ribs(:, 1);
for i = 1:2:length(unique_ribs)
    current_rib = unique_ribs(i);
    
    Vector_extrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                          strcmp(combined_nodes_3D.h, 'extrados') & ...
                          strcmp(combined_nodes_3D.tag, 'stringer') & ...
                          combined_nodes_3D.stringer_index >= rib_ranges_by_ribs(i, 2) & ...
                          combined_nodes_3D.stringer_index <= rib_ranges_by_ribs(i, 3), :);
    
    Vector_intrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                          strcmp(combined_nodes_3D.h, 'intrados') & ...
                          strcmp(combined_nodes_3D.tag, 'stringer') & ...
                          combined_nodes_3D.stringer_index >= rib_ranges_by_ribs(i, 2) & ...
                          combined_nodes_3D.stringer_index <= rib_ranges_by_ribs(i, 3), :);
    
    nodo_rear_extrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                         strcmp(combined_nodes_3D.h, 'extrados') & ...
                         strcmp(combined_nodes_3D.tag, 'rear spars'), :);
    
    nodo_rear_intrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                         strcmp(combined_nodes_3D.h, 'intrados') & ...
                         strcmp(combined_nodes_3D.tag, 'rear spars'), :);
    
    nodo_front_extrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                          strcmp(combined_nodes_3D.h, 'extrados') & ...
                          strcmp(combined_nodes_3D.tag, 'front spars'), :);
    
    nodo_front_intrados = combined_nodes_3D( combined_nodes_3D.rib_index == current_rib & ...
                          strcmp(combined_nodes_3D.h, 'intrados') & ...
                          strcmp(combined_nodes_3D.tag, 'front spars'), :);
    
    Vector_extrados = [nodo_rear_extrados; Vector_extrados; nodo_front_extrados];
    Vector_intrados = [nodo_rear_intrados; Vector_intrados; nodo_front_intrados];
    
    [quad_surfaces_rib, surface_counter] = create_surfaces_from_a_rib_vertical(Vector_extrados, Vector_intrados, ...
                                               current_rib, "quad vertical ribs", "vertical", 1);
    
    quad_surfaces_ala = [quad_surfaces_ala; quad_surfaces_rib];
end



% Bucle para las costillas en el fuselaje
for index_rib = 1:2:max_ribs_fuselaje-1
    
    Vector_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                      combined_nodes_3D.h == 'extrados' & ...
                      combined_nodes_3D.tag == 'stringer fuselaje',:);

    Vector_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                      combined_nodes_3D.h == 'intrados' & ...
                      combined_nodes_3D.tag == 'stringer fuselaje',:);

    nodo_rear_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                         combined_nodes_3D.h == 'extrados' & ...
                         combined_nodes_3D.tag == 'rear spars fuselaje',:);
    
    nodo_rear_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                         combined_nodes_3D.h == 'intrados' & ...
                         combined_nodes_3D.tag == 'rear spars fuselaje',:);

    nodo_front_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                          combined_nodes_3D.h == 'extrados' & ...
                          combined_nodes_3D.tag == 'front spars fuselaje',:);

    nodo_front_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                          combined_nodes_3D.h == 'intrados' & ...
                          combined_nodes_3D.tag == 'front spars fuselaje',:);

    Vector_extrados = [nodo_rear_extrados; Vector_extrados; nodo_front_extrados];
    Vector_intrados = [nodo_rear_intrados; Vector_intrados; nodo_front_intrados];

    [quad_surfaces_rib, surface_counter] = create_surfaces_from_a_rib_vertical(Vector_extrados, Vector_intrados,...
                                           index_rib, "quad vertical ribs fuselaje", "vertical", 1);

    quad_surfaces_fuselaje = [quad_surfaces_fuselaje; quad_surfaces_rib];


end

end
