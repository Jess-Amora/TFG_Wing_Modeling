function combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H)
% GENERATE_3D_NODES Combines 2D wing and fuselage node tables into a single 3D table.
%
%   combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H)
%
%   Inputs:
%       combined_nodes        - Table of 2D wing nodes. Must contain columns:
%                               {'local_id','x','y','rib_index','stringer_index','tag'}.
%       combined_nodes_fuselaje
%                           - Table of 2D fuselage nodes. Must contain the same
%                             columns as combined_nodes.
%       H                   - Scalar representing the total thickness of the structure.
%
%   Output:
%       combined_nodes_3D    - Table containing 3D nodes (extrados & intrados). 
%                             Columns:
%                               {'local_id','x','y','z','rib_index','stringer_index','tag','h'}.
%                             The 'z' coordinate is set to ±(H/2) depending on 
%                             whether the node belongs to the extrados or intrados. 
%                             The 'h' column is set to 'extrados' or 'intrados' for clarity.
%
%   Example:
%       % Create a small wing table (combined_nodes)
%       combined_nodes = table( ...
%           (1:3)', ...                      % local_id
%           [0.0; 1.0; 2.0], ...             % x
%           [0.0; 0.2; 0.4], ...             % y
%           [1; 1; 2], ...                   % rib_index
%           [1; 2; 2], ...                   % stringer_index
%           ["front spar"; "stringer"; "rear spar"], ... % tag
%           'VariableNames', ...
%           {'local_id','x','y','rib_index','stringer_index','tag'});
%
%       % Create a small fuselage table (combined_nodes_fuselaje)
%       combined_nodes_fuselaje = table( ...
%           (4:5)', ...                      % local_id
%           [0.5; 1.5], ...                  % x
%           [0.1; 0.3], ...                  % y
%           [0; 0], ...                      % rib_index (fuselage might not use this)
%           [0; 0], ...                      % stringer_index (or some fuselage index)
%           ["front spar fuselage"; "OnlyNode"], ... % tag
%           'VariableNames', ...
%           {'local_id','x','y','rib_index','stringer_index','tag'});
%
%       % Thickness
%       H = 0.02;
%
%       % Generate the 3D node table
%       combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, H);
%
%       % Display results
%       disp(combined_nodes_3D);
%   
%   -------------------------------------------------------------------------
%   Author: Jess Bern Amora Ycong
%   Date:   18-Jan-2025
%   -------------------------------------------------------------------------

    %% 1. Handle edge cases
    if isempty(combined_nodes) && isempty(combined_nodes_fuselaje)
        warning('Both wing and fuselage tables are empty. Returning an empty 3D node table.');
        combined_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
        return;
    end
    
    %% 2. Concatenate the wing and fuselage 2D tables
    %    We stack them vertically to get a single set of 2D nodes.
    if isempty(combined_nodes)
        all_2D_nodes = combined_nodes_fuselaje;
    elseif isempty(combined_nodes_fuselaje)
        all_2D_nodes = combined_nodes;
    else
        all_2D_nodes = [combined_nodes; combined_nodes_fuselaje];
    end
    
    %% 3. Create extrados (top) and intrados (bottom) node tables
    %    For extrados: z = +H/2, h = 'extrados'
    %    For intrados: z = -H/2, h = 'intrados'
    extrados = all_2D_nodes; 
    intrados = all_2D_nodes;
    
    % Add 'z' and 'h' columns to extrados
    extrados.z =  repmat(H/2, height(extrados), 1);
    extrados.h =  repmat("extrados", height(extrados), 1);
    
    % Add 'z' and 'h' columns to intrados
    intrados.z = repmat(-H/2, height(intrados), 1);
    intrados.h = repmat("intrados", height(intrados), 1);
    
    %% 4. Concatenate extrados and intrados to form the final 3D table
    combined_nodes_3D = [extrados; intrados];
    
    %% 5. Reorder or verify columns if needed (optional)
    %    Ensure the output columns match the desired specification
    desiredOrder = {'local_id','x','y','z','rib_index','stringer_index','tag','h'};
    combined_nodes_3D = combined_nodes_3D(:, desiredOrder);

end
