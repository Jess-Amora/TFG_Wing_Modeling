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
    forces = table([], [], [], [], [], [], [], ...
        'VariableNames', {'load_id', 'node_id', 'type', 'magnitude', 'dir_x', 'dir_y', 'dir_z'});


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
        % Get the current node position
        x = combined_nodes.x(i);
        y = combined_nodes.y(i);
        z = combined_nodes.z(i);
    
        % 🔵 Compute the normal vector (approximation using finite differences)
        if i < height(combined_nodes)
            dx = combined_nodes.x(i+1) - x;
            dy = combined_nodes.y(i+1) - y;
            dz = combined_nodes.z(i+1) - z;
        else
            dx = x - combined_nodes.x(i-1);
            dy = y - combined_nodes.y(i-1);
            dz = z - combined_nodes.z(i-1);
        end
        
        % 🔵 Normal approximation: Cross product of local chord & span direction
        span_vector = [dx, dy, dz];  
        chord_vector = [1, 0, 0];  % Assuming x-direction as chord (modify if needed)
    
        % Compute normal as cross product (spanwise × chordwise)
        force_direction = cross(span_vector, chord_vector);
        force_direction = force_direction / norm(force_direction);  % Normalize
    
        % Compute Schrenk force magnitude
        y_pos = combined_nodes.y(i);
        L_elliptical = sqrt(1 - (2 * y_pos / b)^2);
        L_planform = 1;  % Assuming constant chord
        schrenk_force = 0.5 * (L_elliptical + L_planform);
        force_magnitude = (schrenk_force / num_nodes) * L_total;
    
        % ✅ Store properly as a numeric array, NOT a cell
        forces = [forces; table(load_id, combined_nodes.global_id(i), {'FORCE'}, force_magnitude, ...
                                force_direction(1), force_direction(2), force_direction(3), ...
                                'VariableNames', {'load_id', 'node_id', 'type', 'magnitude', 'dir_x', 'dir_y', 'dir_z'})];
    end

end
