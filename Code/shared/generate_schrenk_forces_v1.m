function forces = generate_schrenk_forces(front_spar_extrados, rear_spar_extrados, b, L_total)
% GENERATE_SCHRENK_FORCES: Computes and distributes Schrenk forces on front and rear spars.
%
% Inputs:
%   front_spar_extrados - Table of nodes on the front spar extrados (columns: global_id, x, y, z).
%   rear_spar_extrados  - Table of nodes on the rear spar extrados (columns: global_id, x, y, z).
%   b                   - Wingspan (total span in meters).
%   L_total             - Total lift force to be distributed (in Newtons).
%
% Outputs:
%   forces              - Table of nodal forces for use in .bdf file generation.

    %% 📝 Initialize Force Table
    forces = table([], [], [], [], [], ...
        'VariableNames', {'load_id', 'node_id', 'type', 'magnitude', 'direction'});

    %% 🔄 Combine Spar Nodes and Compute Schrenk Forces
    % Combine nodes from front and rear spars
    combined_nodes = [front_spar_extrados; rear_spar_extrados];

    % Compute total number of nodes for equal distribution
    num_nodes = height(combined_nodes);

    % Initialize unit vector for force direction (assume Z-negative for lift)
    force_direction = [0, 0, -1];

    % Iterate over nodes to compute Schrenk force
    load_id = 1; % Single load case
    for i = 1:height(combined_nodes)
        % Spanwise position (y-coordinate of the node)
        y = combined_nodes.y(i);

        % Elliptical lift distribution (normalized)
        L_elliptical = sqrt(1 - (2 * y / b)^2);

        % Planform distribution (proportional to chord length, assumed constant for simplicity)
        c_y = 1; % Assuming chord length is constant across the span for simplicity
        L_planform = c_y;

        % Schrenk force at this position
        schrenk_force = 0.5 * (L_elliptical + L_planform);

        % Scale force by total lift
        force_magnitude = (schrenk_force / num_nodes) * L_total;

        % ✅ Store direction as a numeric array, not a cell
        forces = [forces; table(load_id, combined_nodes.global_id(i), {'FORCE'}, force_magnitude, ...
                    force_direction, 'VariableNames', forces.Properties.VariableNames)];

    end
end
