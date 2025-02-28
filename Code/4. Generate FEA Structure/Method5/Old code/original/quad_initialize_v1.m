function quad_table = quad_initialize()
% QUAD_INITIALIZE - Creates an empty table for quadrilateral surfaces
% 
% OUTPUT:
%   quad_table - An empty table with the correct variable names
%
% USAGE:
%   quad_surfaces_regular = quad_initialize();

    quad_table = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
end
