function combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, ...
    m, p, t, num_points, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, show_graph)
% GENERATE_3D_NODES Combines 2D wing and fuselage node tables into a single 3D table,
% mapping wing nodes onto a NACA 6-series airfoil with a variable chord distribution and
% computing the fuselage thickness from the wing at x = Lf for continuity.
%
%   combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, ...
%         m, p, t, num_points, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, show_graph)
%
%   Inputs:
%       combined_nodes        - Table of 2D wing nodes with columns:
%                               {'local_id','x','y','rib_index','stringer_index','tag'}.
%                               Here, x is the spanwise coordinate and y is the global chordwise coordinate.
%       combined_nodes_fuselaje
%                             - Table of 2D fuselage nodes with the same columns.
%       m, p, t, num_points, show_graph
%                             - Parameters for computing the NACA 6-series airfoil.
%       Lf                    - Spanwise coordinate of the wing/fuselage junction (root).
%       Lw                    - Wing span such that the wing tip is at x = Lf + Lw.
%       y_global_punta_ala_borde_ataque
%                             - Global chordwise coordinate of the leading edge at the wing tip.
%       c1                    - Global chordwise coordinate of the trailing edge at the root.
%       c2                    - Offset so that at the tip the trailing edge is at
%                             y = c2 + y_global_punta_ala_borde_ataque.
%
%   Output:
%       combined_nodes_3D     - Table containing 3D nodes for both wing and fuselage with columns:
%                               {'local_id','x','y','z','rib_index','stringer_index','tag','h'}.
%
%   Wing nodes:
%       For each wing node, the local leading and trailing edge positions are computed by linear
%       interpolation:
%           y_le = interp1([Lf, Lf+Lw], [0, y_global_punta_ala_borde_ataque], x)
%           y_te = interp1([Lf, Lf+Lw], [c1, c2+y_global_punta_ala_borde_ataque], x)
%
%       The local chord is c_local = y_te - y_le, and the relative chordwise coordinate is:
%           xi = (y_global_node - y_le) / c_local
%
%       A unit-chord airfoil is computed via naca6series and then scaled by c_local to assign the z‑coordinate.
%
%   Fuselage nodes:
%       Instead of an input thickness H, we compute H from the wing at x = Lf.
%       At x = Lf the leading edge is y_le = 0 and the trailing edge is y_te = c1 so that c_root = c1.
%       A unit-chord airfoil (with chord = 1) is computed to obtain the maximum relative thickness, h_max.
%       Then, H is defined as:
%           H = h_max * c_root.
%
%       Fuselage nodes are assigned constant z-values of +H/2 (extrados) and -H/2 (intrados).
%
%   Example:
%       % Define wing nodes table
%       combined_nodes = table( ...
%           (1:3)', ...                     % local_id
%           [Lf; Lf+0.5*Lw; Lf+Lw], ...      % x (spanwise)
%           [0.05; 0.15; 0.25], ...          % y (global chordwise)
%           [1; 1; 2], ...                  % rib_index
%           [1; 2; 2], ...                  % stringer_index
%           ["spar1"; "stringer"; "spar2"], ... % tag
%           'VariableNames', {'local_id','x','y','rib_index','stringer_index','tag'});
%
%       % Define fuselage nodes table similarly...
%
%       % NACA parameters and chord distribution parameters:
%       m = 0.02; p = 0.4; t = 0.12; num_points = 100; show_graph = false;
%       Lf = 1.0; Lw = 3.0; y_global_punta_ala_borde_ataque = 0.2;
%       c1 = 0.3; c2 = 0.1;
%
%       % Generate 3D nodes
%       combined_nodes_3D = generate_3D_nodes(combined_nodes, combined_nodes_fuselaje, ...
%           m, p, t, num_points, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, show_graph);
%
%   -------------------------------------------------------------------------
%   Author: Your Name
%   Date:   [Today’s Date]
%   -------------------------------------------------------------------------

    %% 1. Handle edge cases
    if isempty(combined_nodes) && isempty(combined_nodes_fuselaje)
        warning('Both wing and fuselage tables are empty. Returning an empty 3D node table.');
        combined_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
        return;
    end

    %% 2. Compute fuselage thickness H from the wing at the root (x = Lf)
    % Compute a unit-chord airfoil (chord = 1) once for scaling.
    airfoil_unit = naca6series(m, p, t, 1, num_points, false);
    % At x = Lf, the leading edge is y_le = 0 and trailing edge is y_te = c1.
    c_root = c1;  % local chord at the root
    H = airfoil_unit.h_max * c_root;  % fuselage thickness based on the wing airfoil at the root

    %% 3. Process wing nodes using the NACA 6-series airfoil with variable chord
    if ~isempty(combined_nodes)
        % Reuse the unit-chord airfoil computed above for scaling.
        
        % Initialize copies for extrados and intrados
        wing_extrados = combined_nodes;
        wing_intrados = combined_nodes;
        
        % Preallocate arrays for z-coordinate
        z_extrados = zeros(height(combined_nodes), 1);
        z_intrados  = zeros(height(combined_nodes), 1);
        
        % Loop over each wing node
        for i = 1:height(combined_nodes)
            x_val = combined_nodes.x(i);
            y_global = combined_nodes.y(i);
            
            % Compute local leading-edge and trailing-edge positions via linear interpolation:
            % Leading edge: from 0 at x = Lf to y_global_punta_ala_borde_ataque at x = Lf+Lw.
            % Trailing edge: from c1 at x = Lf to c2+y_global_punta_ala_borde_ataque at x = Lf+Lw.
            y_le = interp1([Lf, Lf+Lw], [0, y_global_punta_ala_borde_ataque], x_val, 'linear', 'extrap');
            y_te = interp1([Lf, Lf+Lw], [c1, c2+y_global_punta_ala_borde_ataque], x_val, 'linear', 'extrap');
            
            % Local chord length
            c_local = y_te - y_le;
            
            % Relative chordwise coordinate (xi ideally between 0 and 1)
            xi = (y_global - y_le) / c_local;
            
            % Scale the unit airfoil geometry by the local chord to obtain the z-coordinate.
            z_extrados(i) = c_local * interp1(airfoil_unit.x, airfoil_unit.y_upper, xi, 'linear', 'extrap');
            z_intrados(i)  = c_local * interp1(airfoil_unit.x, airfoil_unit.y_lower, xi, 'linear', 'extrap');
        end
        
        % Assign computed z-values and surface tags
        wing_extrados.z = z_extrados;
        wing_extrados.h = repmat("extrados", height(wing_extrados), 1);
        
        wing_intrados.z = z_intrados;
        wing_intrados.h = repmat("intrados", height(wing_intrados), 1);
        
        wing_nodes_3D = [wing_extrados; wing_intrados];
    else
        wing_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
    end

    %% 4. Process fuselage nodes using the computed thickness H
    if ~isempty(combined_nodes_fuselaje)
        fuselage_extrados = combined_nodes_fuselaje;
        fuselage_extrados.z = repmat(H/2, height(combined_nodes_fuselaje), 1);
        fuselage_extrados.h = repmat("extrados", height(combined_nodes_fuselaje), 1);
        
        fuselage_intrados = combined_nodes_fuselaje;
        fuselage_intrados.z = repmat(-H/2, height(combined_nodes_fuselaje), 1);
        fuselage_intrados.h = repmat("intrados", height(combined_nodes_fuselaje), 1);
        
        fuselage_nodes_3D = [fuselage_extrados; fuselage_intrados];
    else
        fuselage_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
    end

    %% 5. Concatenate wing and fuselage 3D node tables
    combined_nodes_3D = [wing_nodes_3D; fuselage_nodes_3D];

    %% 6. Reorder columns to match the desired specification
    desiredOrder = {'local_id','x','y','z','rib_index','stringer_index','tag','h'};
    combined_nodes_3D = combined_nodes_3D(:, desiredOrder);
end
