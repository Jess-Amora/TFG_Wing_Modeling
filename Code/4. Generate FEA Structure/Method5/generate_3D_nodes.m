function combined_nodes_3D = generate_3D_nodes( ...
    combined_nodes, combined_nodes_fuselaje, ...
    airfoil, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, show_graph)
% GENERATE_3D_NODES Creates a 3D wing-fuselage node table ensuring continuity at x=Lf.
%
%   combined_nodes_3D = generate_3D_nodes( ...
%       combined_nodes, combined_nodes_fuselaje, ...
%       m, p, t, num_points, Lf, Lw, ...
%       y_global_punta_ala_borde_ataque, c1, c2, show_graph)
%
%   Inputs:
%       combined_nodes        - 2D wing nodes with columns:
%                               {'local_id','x','y','rib_index','stringer_index','tag'}.
%                               - x: spanwise coordinate
%                               - y: global chordwise coordinate
%       combined_nodes_fuselaje
%                             - 2D fuselage nodes with the same columns.
%
%       m, p, t, num_points, show_graph
%                             - Parameters for the NACA 6-series airfoil.
%
%       Lf                    - Spanwise coordinate of the wing root (where fuselage meets wing).
%       Lw                    - Wing span (so tip is at x = Lf + Lw).
%       y_global_punta_ala_borde_ataque
%                             - y-value of the leading edge at the wing tip.
%       c1                    - Trailing-edge y-value at the root.
%       c2                    - Additional offset so trailing edge at tip is c2 + leading-edge tip.
%
%   Behavior:
%       1) The wing is computed as before: each node's (x,y) is mapped onto a
%          variable-chord NACA 6-series airfoil for z.
%       2) The fuselage's top/bottom surfaces are forced to match the wing's
%          extrados/intrados at x = Lf for each chordwise y. This ensures
%          continuous geometry at the root. In this simple version, the fuselage
%          shape is effectively a "copy" of the root airfoil shape for *all*
%          fuselage x-values.
%
%   Output:
%       combined_nodes_3D     - A single table of 3D nodes for both wing & fuselage:
%                               {'local_id','x','y','z','rib_index','stringer_index','tag','h'}.
%
%   Example:
%       % Wing nodes:
%       combined_nodes = table( ...
%           (1:3)', ...                   % local_id
%           [Lf; Lf+0.5*Lw; Lf+Lw], ...    % x (spanwise)
%           [0.05; 0.15; 0.25], ...        % y (global chordwise)
%           [1; 1; 2], ...                % rib_index
%           [1; 2; 2], ...                % stringer_index
%           ["spar1"; "stringer"; "spar2"], ... % tag
%           'VariableNames', ...
%           {'local_id','x','y','rib_index','stringer_index','tag'});
%
%       % Fuselage nodes (example):
%       combined_nodes_fuselaje = table( ...
%           (4:5)', ...
%           [0.5; 0.8], ...  % x < Lf, purely fuselage region
%           [0.10; 0.25], ...
%           [0; 0], ...
%           [0; 0], ...
%           ["fuse_node1"; "fuse_node2"], ...
%           'VariableNames', ...
%           {'local_id','x','y','rib_index','stringer_index','tag'});
%
%       % NACA parameters:
%       m = 0.02; p = 0.4; t = 0.12; num_points = 100; show_graph = false;
%       Lf = 1.0; Lw = 3.0; y_global_punta_ala_borde_ataque = 0.2;
%       c1 = 0.3; c2 = 0.1;
%
%       % Generate 3D
%       combined_nodes_3D = generate_3D_nodes( ...
%           combined_nodes, combined_nodes_fuselaje, ...
%           m, p, t, num_points, Lf, Lw, ...
%           y_global_punta_ala_borde_ataque, c1, c2, show_graph);
%
%       disp(combined_nodes_3D);
%
%   -------------------------------------------------------------------------
%   Author: Your Name
%   Date:   [Today’s Date]
%   -------------------------------------------------------------------------


 m = airfoil.m;
 p = airfoil.p;
 t = airfoil.t;
 num_points = airfoil.num_points;
    %% 1. Handle edge cases
    if isempty(combined_nodes) && isempty(combined_nodes_fuselaje)
        warning('Both wing and fuselage tables are empty. Returning an empty 3D node table.');
        combined_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
        return;
    end

    %% 2. Compute a "unit-chord" airfoil for the wing, to scale later
    airfoil_unit = naca6series(m, p, t, 1, num_points, show_graph);

    %% 3. Generate the wing extrados & intrados as before
    if ~isempty(combined_nodes)
        wing_extrados = combined_nodes;
        wing_intrados = combined_nodes;

        z_extrados = zeros(height(combined_nodes), 1);
        z_intrados = zeros(height(combined_nodes), 1);

        for i = 1:height(combined_nodes)
            x_val = combined_nodes.x(i);
            y_global = combined_nodes.y(i);

            % Interpolate leading & trailing edge in global y
            y_le = interp1([Lf, Lf+Lw], [0, y_global_punta_ala_borde_ataque], x_val, 'linear', 'extrap');
            y_te = interp1([Lf, Lf+Lw], [c1, c2 + y_global_punta_ala_borde_ataque], x_val, 'linear', 'extrap');
            c_local = y_te - y_le;  % local chord

            % Relative chordwise coordinate
            xi = (y_global - y_le) / c_local;

            % Map onto scaled airfoil
            z_extrados(i) = c_local * interp1(airfoil_unit.x, airfoil_unit.y_upper, xi, 'linear', 'extrap');
            z_intrados(i) = c_local * interp1(airfoil_unit.x, airfoil_unit.y_lower, xi, 'linear', 'extrap');
        end

        wing_extrados.z = z_extrados;
        wing_extrados.h = repmat("extrados", height(wing_extrados), 1);

        wing_intrados.z = z_intrados;
        wing_intrados.h = repmat("intrados", height(wing_intrados), 1);

        wing_nodes_3D = [wing_extrados; wing_intrados];
    else
        wing_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
    end

    %% 4. For fuselage, match the wing's root shape at x=Lf for continuity
    %
    %  In this simplified approach, we treat every fuselage node as if
    %  it belongs to the "root chord" (chord = c1). That is:
    %     y_le_root = 0,  y_te_root = c1
    %     c_root = c1
    %
    %  Then for each fuselage node's chordwise position y, we find
    %  xi = (y - y_le_root)/c_root
    %  and read z from the same unit airfoil, scaled by c_root.
    %
    %  This ensures that the fuselage extrados/intrados at x=Lf match
    %  exactly the wing extrados/intrados. For x < Lf or x > Lf, we
    %  still use the same "root shape," giving a constant thickness
    %  fuselage along x. Adjust as needed for more complex fuselage
    %  geometry.
    %
    if ~isempty(combined_nodes_fuselaje)
        fuselage_extrados = combined_nodes_fuselaje;
        fuselage_intrados = combined_nodes_fuselaje;

        z_extrados_fus = zeros(height(combined_nodes_fuselaje), 1);
        z_intrados_fus = zeros(height(combined_nodes_fuselaje), 1);

        % Root chord = c1
        c_root = c1;
        y_le_root = 0;  % Leading edge at root
        y_te_root = c1; % Trailing edge at root (so c_root = c1)

        for i = 1:height(combined_nodes_fuselaje)
            y_global_fus = combined_nodes_fuselaje.y(i);

            % Relative chordwise coordinate (clamped or direct)
            xi_fus = (y_global_fus - y_le_root) / c_root;

            % Map onto the same unit airfoil shape used at the wing root
            z_extrados_fus(i) = c_root * interp1(airfoil_unit.x, airfoil_unit.y_upper, xi_fus, 'linear', 'extrap');
            z_intrados_fus(i) = c_root * interp1(airfoil_unit.x, airfoil_unit.y_lower, xi_fus, 'linear', 'extrap');
        end

        fuselage_extrados.z = z_extrados_fus;
        fuselage_extrados.h = repmat("extrados", height(fuselage_extrados), 1);

        fuselage_intrados.z = z_intrados_fus;
        fuselage_intrados.h = repmat("intrados", height(fuselage_intrados), 1);

        fuselage_nodes_3D = [fuselage_extrados; fuselage_intrados];
    else
        fuselage_nodes_3D = table([], [], [], [], [], [], [], [], ...
            'VariableNames', {'local_id','x','y','z','rib_index','stringer_index','tag','h'});
    end

    %% 5. Combine wing and fuselage
    combined_nodes_3D = [wing_nodes_3D; fuselage_nodes_3D];

    %% 6. Reorder columns to match the desired specification
    desiredOrder = {'local_id','x','y','z','rib_index','stringer_index','tag','h'};
    combined_nodes_3D = combined_nodes_3D(:, desiredOrder);
end
