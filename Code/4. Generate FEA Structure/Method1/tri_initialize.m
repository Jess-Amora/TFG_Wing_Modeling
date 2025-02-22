function tri_table = tri_initialize()
% TRI_INITIALIZE - Creates an empty table for triangular surfaces
%
% OUTPUT:
%   tri_table - An empty table with the correct variable names
%
% USAGE:
%   tri_surfaces = tri_initialize();

    tri_table = table([], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                          'area', 'aspect_ratio'});
end
