function generate_forces_bdf(filename, forces, nodes_table)
% GENERATE_FORCES_BDF: Generates a .bdf file for forces and moments applied to nodes.
%
% Inputs:
%   filename    - Name of the output .bdf file.
%   forces      - Table containing forces and moments applied to nodes. Columns:
%                 {'load_id', 'node_id', 'type', 'magnitude', 'direction'}.
%                 'type': 'FORCE' or 'MOMENT'.
%                 'direction': [X, Y, Z] unit vector of direction.
%   nodes_table - Table containing node definitions with columns:
%                 {'global_id', 'x', 'y', 'z'}.
%
% Outputs:
%   Creates a `.bdf` file with forces and moments defined in MSC Nastran format.

    %% 🟢 Validate Input Data
    if isempty(forces)
        error('Forces table is empty. No .bdf file generated.');
    end

    if isempty(nodes_table)
        error('Nodes table is empty. Cannot match forces to nodes.');
    end

    % Ensure all nodes in the forces table exist in nodes_table
    missing_nodes = setdiff(forces.node_id, nodes_table.global_id);
    if ~isempty(missing_nodes)
        error('The following nodes referenced in the forces table are missing in the nodes_table: %s', ...
              num2str(missing_nodes(:)'));
    end

    %% 📝 Open File for Writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    %% 🔄 Write Header
    fprintf(fid, '$ MSC.Nastran Forces and Moments\n');
    fprintf(fid, 'BEGIN BULK\n');

    %% 🔄 Write Forces and Moments
    unique_load_ids = unique(forces.load_id);
    for load_id = unique_load_ids'
        % Get all forces for the current load ID
        current_load_forces = forces(forces.load_id == load_id, :);

        fprintf(fid, '$ Nodal Forces and Moments for Load ID: %d\n', load_id);

        for i = 1:height(current_load_forces)
            force = current_load_forces(i, :);
            type = force.type{1};  % 'FORCE' or 'MOMENT'

            % Extract data
            node_id = force.node_id;
            magnitude = force.magnitude;
            direction = force.direction;

            % Write to file
            if strcmp(type, 'FORCE')
                % fprintf(fid, 'FORCE    %-8d%-8d%-8d%-16.6f%-16.6f%-16.6f%-16.6f\n', ...
                %         load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));
                % ✅ Fixed-field format: FORCE card (exact column spacing)

                % fprintf(fid, 'FORCE   %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                %         load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));

                fprintf(fid, 'FORCE   %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                    load_id, node_id, 0, magnitude, force.dir_x, force.dir_y, force.dir_z);


            elseif strcmp(type, 'MOMENT')
                % fprintf(fid, 'MOMENT   %-8d%-8d%-8d%-16.6f%-16.6f%-16.6f%-16.6f\n', ...
                %         load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));
                fprintf(fid, 'MOMENT  %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                        load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));

            else
                error('Invalid force type: %s. Must be "FORCE" or "MOMENT".', type);
            end
        end
    end

    %% 🔴 Footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    fprintf('Forces .bdf file written successfully to %s\n', filename);
end
