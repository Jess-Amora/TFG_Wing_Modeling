function tris_3D = preprocess_3D_tris(tris_2D)
% PREPROCESS_3D_TRIS Prepares the 3D triangular elements by adding extrados & intrados.
%
%   tris_3D = preprocess_3D_tris(tris_2D)
%
%   Inputs:
%       tris_2D - Table of 2D triangular elements.
%                 Expected columns:
%                 {'local_id', 'node_1', 'node_2', 'node_3',
%                  'stringer_1', 'rib_1', 'rib_2', 'tag',
%                  'area', 'aspect_ratio'}
%
%   Output:
%       tris_3D - Table containing both extrados & intrados triangular elements.
%                 Additional column:
%                 {'h'} - Identifies the surface ('extrados' or 'intrados').
%
%   Example:
%       tris_3D = preprocess_3D_tris(tris_2D);
%
%   -------------------------------------------------------------------------
%   Author: Jess Bern Amora Ycong
%   Date:   06-Feb-2025
%   -------------------------------------------------------------------------

    %% 1. Handle edge cases
    if isempty(tris_2D)
        warning('Input 2D triangle table is empty. Returning an empty table.');
        tris_3D = table([], [], [], [], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                              'stringer_1', 'rib_1', 'rib_2', 'tag', ...
                              'area', 'aspect_ratio', 'h'});
        return;
    end

    %% 2. Create extrados and intrados versions
    extrados_tris = tris_2D;
    intrados_tris = tris_2D;

    % Assign the 'h' column
    extrados_tris.h = repmat("extrados", height(tris_2D), 1);
    intrados_tris.h = repmat("intrados", height(tris_2D), 1);

    %% 3. Adjust local_id for intrados to maintain uniqueness
    intrados_tris.local_id = intrados_tris.local_id + height(tris_2D);

    %% 4. Combine extrados and intrados triangles
    tris_3D = [extrados_tris; intrados_tris];

end
