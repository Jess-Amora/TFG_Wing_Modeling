function export_forces_to_csv(filename, forces)
% EXPORT_FORCES_TO_CSV: Exports force data in Patran-compatible CSV format.
%
% Inputs:
%   - filename: Output CSV file path (e.g., 'forces.csv').
%   - forces: Table containing forces with columns:
%             {'node_id', 'magnitude', 'dir_x', 'dir_y', 'dir_z'}.
%
% Outputs:
%   - Creates a CSV file with forces formatted for Patran import.
%
% Example Usage:
%   export_forces_to_csv('forces.csv', forces)

    %% 🟢 Validate Input Data
    if isempty(forces)
        error('Forces table is empty. No CSV file generated.');
    end

    %% 📝 Open File for Writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    %% 🔄 Write Forces in Patran Format
    for i = 1:height(forces)
        node_id = forces.node_id(i);
        magnitude = forces.magnitude(i);
        dir_x = forces.dir_x(i);
        dir_y = forces.dir_y(i);
        dir_z = forces.dir_z(i);

        % ✅ Compute absolute force components
        Fx = magnitude * dir_x;
        Fy = magnitude * dir_y;
        Fz = magnitude * dir_z;

        % ✅ Write to CSV file in Patran format
        fprintf(fid, 'Node %d,<%.6f, %.6f, %.6f>\n', node_id, Fx, Fy, Fz);
    end

    %% 🔴 Close File
    fclose(fid);
    fprintf('Forces successfully exported to %s\n', filename);
end
