function generate_forces_bdf_v3(filename, forces, nodes_table)
% GENERATE_FORCES_BDF_V3: Generates a .bdf file for forces and moments applied to nodes.
%
% Inputs:
%   - filename: Name of the output `.bdf` file.
%   - forces: Table containing forces and moments. Columns:
%             {'load_id', 'node_id', 'type', 'magnitude', 'dir_x', 'dir_y', 'dir_z'}.
%   - nodes_table: Table containing nodes {'global_id', 'x', 'y', 'z'}.

    %% 🟢 Validate Input Data
    if isempty(forces)
        error('Forces table is empty. No .bdf file generated.');
    end

    if isempty(nodes_table)
        error('Nodes table is empty. Cannot match forces to nodes.');
    end

    % Ensure all nodes in forces exist in nodes_table
    missing_nodes = setdiff(forces.node_id, nodes_table.global_id);
    if ~isempty(missing_nodes)
        error('Missing nodes in nodes_table: %s', num2str(missing_nodes(:)'));
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
        % Extract all forces for the current load case
        current_forces = forces(forces.load_id == load_id, :);
        fprintf(fid, '$ Nodal Forces and Moments for Load ID: %d\n', load_id);

        for i = 1:height(current_forces)
            force = current_forces(i, :);
            type = force.type; % 'FORCE' or 'MOMENT'

            % Extract data
            node_id = force.node_id;
            magnitude = force.magnitude;
            dir_x = force.dir_x;
            dir_y = force.dir_y;
            dir_z = force.dir_z;

            % ✅ Compute absolute force components
            Fx = magnitude * dir_x;
            Fy = magnitude * dir_y;
            Fz = magnitude * dir_z;

            %% 🔹 **Fixed-Field Format Handling**
            % If total line length exceeds 80 characters, use continuation lines
            force_line = sprintf('%-8s%8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                                 type, load_id, node_id, 0, magnitude, Fx, Fy, Fz);

            if length(force_line) > 80  % If line is too long, use continuation format
                fprintf(fid, '%-8s%8d%8d%8d%16.6f\n', type, load_id, node_id, 0, magnitude);
                fprintf(fid, '*       %16.6f%16.6f%16.6f\n', Fx, Fy, Fz);
            else
                fprintf(fid, force_line);
            end
        end
    end

    %% 🔴 Footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    fprintf('Forces .bdf file successfully written to %s\n', filename);
end
