function write_bdf_full(filename, nodes, lines, quads, tris, forces, BC, material_info, property_info, pshell_info)
% WRITE_BDF_FULL: Combines multiple BDF writing functions into one file.
%
% Inputs:
%   filename      - Path to the output .bdf file.
%   nodes         - Nx6 matrix: [ID, CP, X, Y, Z, CD].
%   lines         - Px4 matrix: [EID, PID, G1, G2].
%   quads         - Nx8 matrix: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
%   tris          - Mx7 matrix: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   forces        - Table with {'load_id', 'node_id', 'type', 'magnitude', 'direction'}.
%   BC            - Struct with boundary condition node groups.
%   material_info - Struct with material properties.
%   property_info - Struct with line property definitions.
%   pshell_info   - Struct with shell property definitions for quads/tris.
%
% Outputs:
%   Creates a single `.bdf` file with all nodes, elements, BC, and forces.

    %% ✅ Ensure Directory Exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
        fprintf('📁 Created directory: %s\n', output_dir);
    end

    %% ✅ Open File for Writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('❌ ERROR: Could not open file: %s', filename);
    end

    %% ✅ Write Header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    %% 🔹 Step 1: Write Nodes
    fprintf(fid, '$ ---- NODES ----\n');
    for i = 1:size(nodes, 1)
        fprintf(fid, 'GRID,%d,%d,%.6f,%.6f,%.6f,%d\n', ...
                nodes(i, 1), nodes(i, 2), nodes(i, 3), nodes(i, 4), nodes(i, 5), nodes(i, 6));
    end

    %% 🔹 Step 2: Write Material Properties
    fprintf(fid, '$ ---- MATERIAL PROPERTIES ----\n');
    if isfield(material_info, 'material_id') && isfield(material_info, 'E') && isfield(material_info, 'nu')
        rho_value = 0;
        if isfield(material_info, 'rho'), rho_value = material_info.rho; end
        fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f\n', ...
                material_info.material_id, material_info.E, rho_value, material_info.nu);
    else
        error('❌ ERROR: Incomplete material properties.');
    end

    %% 🔹 Step 3: Write Shell Property (PSHELL)
    fprintf(fid, '$ ---- SHELL PROPERTY ----\n');
    if isfield(pshell_info, 'property_id') && isfield(pshell_info, 'material_id') && isfield(pshell_info, 'thickness')
        fprintf(fid, 'PSHELL  %-8d%-8d%-16.6f\n', ...
                pshell_info.property_id, pshell_info.material_id, pshell_info.thickness);
    else
        error('❌ ERROR: Incomplete PSHELL properties.');
    end

    %% 🔹 Step 4: Write Lines (CROD)
    fprintf(fid, '$ ---- LINE ELEMENTS ----\n');
    for i = 1:size(lines, 1)
        fprintf(fid, 'CROD    %-8d%-8d%-8d%-8d\n', ...
                lines(i, 1), lines(i, 2), lines(i, 3), lines(i, 4));
    end

    %% 🔹 Step 5: Write Quadrilateral Elements (CQUAD4)
    fprintf(fid, '$ ---- QUADRILATERALS ----\n');
    for i = 1:size(quads, 1)
        fprintf(fid, 'CQUAD4  %-8d%-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
                quads(i, 1), quads(i, 2), quads(i, 3), quads(i, 4), quads(i, 5), quads(i, 6), quads(i, 7), quads(i, 8));
    end

    %% 🔹 Step 6: Write Triangle Elements (CTRIA3)
    fprintf(fid, '$ ---- TRIANGLES ----\n');
    for i = 1:size(tris, 1)
        fprintf(fid, 'CTRIA3  %-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
                tris(i, 1), tris(i, 2), tris(i, 3), tris(i, 4), tris(i, 5), tris(i, 6), tris(i, 7));
    end

    %% 🔹 Step 7: Write Boundary Conditions (SPC1)
    fprintf(fid, '$ ---- BOUNDARY CONDITIONS ----\n');
    for i = 1:height(BC.root_nodes)
        fprintf(fid, 'SPC1     1       123456  %-8d\n', BC.root_nodes.global_id(i));
    end
    fprintf(fid, 'SPC1     2       23      %-8d\n', BC.root_front_spar_intrados.global_id);
    fprintf(fid, 'SPC1     3       3       %-8d\n', BC.root_rear_spar_intrados.global_id);
    for i = 1:height(BC.rib_fuselage_nodes)
        fprintf(fid, 'SPC1     4       156     %-8d\n', BC.rib_fuselage_nodes.global_id(i));
    end
function write_bdf_full(filename, combined_nodes_3D_processed, lines, quads, tris, forces, material_info, property_info, pshell_info, rib_ranges, Lf)
% WRITE_BDF_FULL: Generates a single BDF file including all structural elements, BC, and forces.
%
% Inputs:
%   filename      - Path to the output .bdf file.
%   combined_nodes_3D_processed - Table of all processed nodes.
%   lines         - Px4 matrix: [EID, PID, G1, G2].
%   quads         - Nx8 matrix: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
%   tris          - Mx7 matrix: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   forces        - Table with {'load_id', 'node_id', 'type', 'magnitude', 'direction'}.
%   material_info - Struct with material properties.
%   property_info - Struct with line property definitions.
%   pshell_info   - Struct with shell property definitions for quads/tris.
%   rib_ranges    - Rib index ranges for processing specific BC nodes.
%   Lf            - Fuselage length at root for BC filtering.
%
% Outputs:
%   Creates a single `.bdf` file with all elements, BC, and forces.

    %% ✅ Ensure Directory Exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
        fprintf('📁 Created directory: %s\n', output_dir);
    end

    %% ✅ Open File for Writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('❌ ERROR: Could not open file: %s', filename);
    end

    %% ✅ Write Header
    fprintf(fid, 'CEND\nBEGIN BULK\n');

    %% 🔹 Step 1: Write Nodes
    fprintf(fid, '$ ---- NODES ----\n');
    for i = 1:size(combined_nodes_3D_processed, 1)
        fprintf(fid, 'GRID,%d,%d,%.6f,%.6f,%.6f,%d\n', ...
                combined_nodes_3D_processed.global_id(i), 0, ...
                combined_nodes_3D_processed.x(i), combined_nodes_3D_processed.y(i), ...
                combined_nodes_3D_processed.z(i), 0);
    end

    %% 🔹 Step 2: Write Material Properties
    fprintf(fid, '$ ---- MATERIAL PROPERTIES ----\n');
    if isfield(material_info, 'material_id') && isfield(material_info, 'E') && isfield(material_info, 'nu')
        rho_value = 0;
        if isfield(material_info, 'rho'), rho_value = material_info.rho; end
        fprintf(fid, 'MAT1    %-8d%-16.6f%-16.6f%-16.6f\n', ...
                material_info.material_id, material_info.E, rho_value, material_info.nu);
    else
        error('❌ ERROR: Incomplete material properties.');
    end

    %% 🔹 Step 3: Write Shell Property (PSHELL)
    fprintf(fid, '$ ---- SHELL PROPERTY ----\n');
    if isfield(pshell_info, 'property_id') && isfield(pshell_info, 'material_id') && isfield(pshell_info, 'thickness')
        fprintf(fid, 'PSHELL  %-8d%-8d%-16.6f\n', ...
                pshell_info.property_id, pshell_info.material_id, pshell_info.thickness);
    else
        error('❌ ERROR: Incomplete PSHELL properties.');
    end

    %% 🔹 Step 4: Write Line Elements (CROD)
    fprintf(fid, '$ ---- LINE ELEMENTS ----\n');
    for i = 1:size(lines, 1)
        fprintf(fid, 'CROD    %-8d%-8d%-8d%-8d\n', ...
                lines(i, 1), lines(i, 2), lines(i, 3), lines(i, 4));
    end

    %% 🔹 Step 5: Write Quadrilateral Elements (CQUAD4)
    fprintf(fid, '$ ---- QUADRILATERALS ----\n');
    for i = 1:size(quads, 1)
        fprintf(fid, 'CQUAD4  %-8d%-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
                quads(i, 1), quads(i, 2), quads(i, 3), quads(i, 4), quads(i, 5), quads(i, 6), quads(i, 7), quads(i, 8));
    end

    %% 🔹 Step 6: Write Triangle Elements (CTRIA3)
    fprintf(fid, '$ ---- TRIANGLES ----\n');
    for i = 1:size(tris, 1)
        fprintf(fid, 'CTRIA3  %-8d%-8d%-8d%-8d%-8d%-8.1f%-8.1f\n', ...
                tris(i, 1), tris(i, 2), tris(i, 3), tris(i, 4), tris(i, 5), tris(i, 6), tris(i, 7));
    end

    %% 🔹 Step 7: **Calculate & Write Boundary Conditions Automatically**
    fprintf(fid, '$ ---- BOUNDARY CONDITIONS ----\n');

    % Fully Fix Root Nodes
    root_nodes = filter_root_nodes(combined_nodes_3D_processed, Lf);
    for i = 1:height(root_nodes)
        fprintf(fid, 'SPC1     1       123456  %-8d\n', root_nodes.global_id(i));
    end

    % Constrain Front Spar Intrados at Root (DOFs 2, 3)
    root_front_spar_intrados = combined_nodes_3D_processed( ...
        combined_nodes_3D_processed.tag == "front spars" & ...
        combined_nodes_3D_processed.rib_index == 1e5 & ...
        combined_nodes_3D_processed.h == "intrados", :);
    fprintf(fid, 'SPC1     2       23      %-8d\n', root_front_spar_intrados.global_id);

    % Constrain Rear Spar Intrados at Root (DOF 3)
    root_rear_spar_intrados = combined_nodes_3D_processed( ...
        combined_nodes_3D_processed.tag == "rear spars" & ...
        combined_nodes_3D_processed.rib_index == rib_ranges(1, 2) & ...
        combined_nodes_3D_processed.h == "intrados", :);
    fprintf(fid, 'SPC1     3       3       %-8d\n', root_rear_spar_intrados.global_id);

    % Apply Symmetry Conditions on First Rib in Fuselage (DOFs 1, 5, 6)
    rib_fuselage_nodes = combined_nodes_3D_processed( ...
        combined_nodes_3D_processed.rib_index == 1 & ...
        (combined_nodes_3D_processed.tag == "stringer fuselaje" | ...
         combined_nodes_3D_processed.tag == "rear spars fuselaje" | ...
         combined_nodes_3D_processed.tag == "front spars fuselaje"), :);
    for i = 1:height(rib_fuselage_nodes)
        fprintf(fid, 'SPC1     4       156     %-8d\n', rib_fuselage_nodes.global_id(i));
    end

    %% 🔹 Step 8: Write Forces
    fprintf(fid, '$ ---- FORCES ----\n');
    for i = 1:height(forces)
        fprintf(fid, 'FORCE   %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                forces.load_id(i), forces.node_id(i), 0, forces.magnitude(i), ...
                forces.direction{i}(1), forces.direction{i}(2), forces.direction{i}(3));
    end

    %% 🔹 Step 9: Write Footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    fprintf('✅ BDF file written successfully to %s\n', filename);
end

    %% 🔹 Step 8: Write Forces (FORCE / MOMENT)
    fprintf(fid, '$ ---- FORCES ----\n');
    unique_load_ids = unique(forces.load_id);
    for load_id = unique_load_ids'
        current_forces = forces(forces.load_id == load_id, :);
        fprintf(fid, '$ Forces for Load ID: %d\n', load_id);
        for i = 1:height(current_forces)
            type = current_forces.type{i};
            node_id = current_forces.node_id(i);
            magnitude = current_forces.magnitude(i);
            direction = current_forces.direction{i};
            if strcmp(type, 'FORCE')
                fprintf(fid, 'FORCE   %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                        load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));
            elseif strcmp(type, 'MOMENT')
                fprintf(fid, 'MOMENT  %8d%8d%8d%16.6f%16.6f%16.6f%16.6f\n', ...
                        load_id, node_id, 0, magnitude, direction(1), direction(2), direction(3));
            else
                error('❌ ERROR: Invalid force type.');
            end
        end
    end

    %% 🔹 Step 9: Write Footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    fprintf('✅ BDF file written successfully to %s\n', filename);
end
