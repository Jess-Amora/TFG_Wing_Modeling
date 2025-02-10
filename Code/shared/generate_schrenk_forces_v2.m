function forces = generate_schrenk_forces_v2(front_spar_extrados, rear_spar_extrados, b, L_total)
% GENERATE_SCHRENK_FORCES: Computes and distributes Schrenk forces on front and rear spars.

    %% 📝 Initialize Force Table (Ensure columns match exactly)
    forces = table([], [], [], [], [], [], [], ...
        'VariableNames', {'load_id', 'node_id', 'type', 'magnitude', 'dir_x', 'dir_y', 'dir_z'});

    %% 🔄 Combine Spar Nodes and Compute Schrenk Forces
    combined_nodes = [front_spar_extrados; rear_spar_extrados];
    num_nodes = height(combined_nodes);

    for i = 1:num_nodes
        % Extract node coordinates
        x = combined_nodes.x(i);
        y = combined_nodes.y(i);
        z = combined_nodes.z(i);

        % 🔵 Compute approximate normal direction
        if i < num_nodes
            dx = combined_nodes.x(i+1) - x;
            dy = combined_nodes.y(i+1) - y;
            dz = combined_nodes.z(i+1) - z;
        else
            dx = x - combined_nodes.x(i-1);
            dy = y - combined_nodes.y(i-1);
            dz = z - combined_nodes.z(i-1);
        end

        % 🔵 Compute normal as a cross product
        span_vector = [dx, dy, dz];  
        chord_vector = [1, 0, 0];  % Assumed chord direction

        force_direction = cross(span_vector, chord_vector);
        force_direction = force_direction / norm(force_direction);  % Normalize

        % Compute Schrenk force magnitude
        L_elliptical = sqrt(1 - (2 * y / b)^2);
        L_planform = 1;
        schrenk_force = 0.5 * (L_elliptical + L_planform);
        force_magnitude = (schrenk_force / num_nodes) * L_total;

        % ✅ Correctly format table row (avoid cell array issues)
        forces = [forces; table(1, combined_nodes.global_id(i), "FORCE", force_magnitude, ...
                                force_direction(1), force_direction(2), force_direction(3), ...
                                'VariableNames', forces.Properties.VariableNames)];
    end
end
