function quads_3D = preprocess_3D_quads(quads_2D)
% PREPROCESS_3D_QUADS Prepares the 3D quadrilateral elements by adding extrados & intrados.
%
%   quads_3D = preprocess_3D_quads(quads_2D)
%
%   Inputs:
%       quads_2D - Table of 2D quadrilateral elements.
%                 Expected columns:
%                 {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', 
%                  'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', 
%                  'area', 'aspect_ratio'}
%
%   Output:
%       quads_3D - Table containing both extrados & intrados quadrilateral elements.
%                 Additional column:
%                 {'h'} - Identifies the surface ('extrados' or 'intrados').
%
%   Example:
%       quads_3D = preprocess_3D_quads(quads_2D);
%
%   -------------------------------------------------------------------------
%   Author: Jess Bern Amora Ycong
%   Date:   29-Jan-2025
%   -------------------------------------------------------------------------

    %% 1. Handle edge cases
    if isempty(quads_2D)
        warning('Input 2D quad table is empty. Returning an empty table.');
        quads_3D = table([], [], [], [], [], [], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                              'area', 'aspect_ratio', 'h'});
        return;
    end

    %% 2. Create extrados and intrados versions
    extrados_quads = quads_2D;
    intrados_quads = quads_2D;

    % Assign the 'h' column
    extrados_quads.h = repmat("extrados", height(quads_2D), 1);
    intrados_quads.h = repmat("intrados", height(quads_2D), 1);

    %% 3. Adjust local_id for intrados to maintain uniqueness
    intrados_quads.local_id = intrados_quads.local_id + height(quads_2D);

    %% 4. Combine extrados and intrados quads
    quads_3D = [extrados_quads; intrados_quads];

end
