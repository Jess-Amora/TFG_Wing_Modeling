function forces = generate_schrenk_forces_v4(nodes, b, L_total)
% GENERATE_SCHRENK_FORCES_V4: Computes Schrenk forces and formats for Patran CSV export.
%
% Inputs:
%   - nodes: Table with node data {'global_id', 'x', 'y', 'z'}.
%   - b: Wingspan (meters).
%   - L_total: Total lift force (Newtons).
%
% Outputs:
%   - forces: Table {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'}.

    %% 🟢 Validate Input Data
    if isempty(nodes)
        error('Node table is empty. No forces generated.');
    end

    num_nodes = height(nodes); % Total number of nodes

    %% 🔵 Initialize Forces Table with Correct Column Types
    forces = table([], [], [], [], [], ...
        'VariableNames', {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'});

    %% 🔄 Compute Schrenk's Lift Distribution
    for i = 1:num_nodes
        node_id = nodes.global_id(i);
        y = nodes.y(i); % Spanwise position

        % 🔹 Elliptical Lift Distribution (Normalized)
        L_elliptical = sqrt(1 - (2 * y / b)^2);

        % 🔹 Planform Lift Distribution (Assuming Constant Chord)
        L_planform = 1;

        % 🔹 Compute Schrenk’s Lift Distribution at this node
        schrenk_force = 0.5 * (L_elliptical + L_planform);

        % 🔹 Scale Force by Total Lift
        force_magnitude = (schrenk_force / num_nodes) * L_total;

        % 🔹 Assume Lift Direction is in the -Z Direction
        dir_x = 0;
        dir_y = 0;
        dir_z = -1;

        % ✅ Fix: Ensure All Variables Match Correctly
        new_force = table(node_id, force_magnitude, dir_x, dir_y, dir_z, ...
                         'VariableNames', forces.Properties.VariableNames);
        
        forces = [forces; new_force];
    end
end
