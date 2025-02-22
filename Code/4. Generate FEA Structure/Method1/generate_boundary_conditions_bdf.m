function generate_boundary_conditions_bdf(filename, root_nodes, root_front_spar_intrados, root_rear_spar_intrados, rib_fuselage_nodes)
% GENERATE_BOUNDARY_CONDITIONS_BDF: Generates a .bdf file with boundary conditions for the wing root and symmetry plane.
%
% Inputs:
%   filename                   - Name of the output .bdf file.
%   root_nodes                 - Table containing nodes of the root rib.
%   root_front_spar_intrados   - Row containing the node at the root-front spar intrados.
%   root_rear_spar_intrados    - Row containing the node at the root-rear spar intrados.
%   rib_fuselage_nodes         - Table containing nodes of the first rib inside the fuselage.
%
% Outputs:
%   Creates a `.bdf` file with boundary conditions for export to Patran/MSC Nastran.
%
% Node Table Format (Columns Required):
%   global_id - Unique node ID.
%   x, y, z  - Coordinates of the node.
%

    %% 📝 Initialize Variables
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    % Write Header
    fprintf(fid, 'BEGIN BULK\n');
    fprintf(fid, '$ Boundary Conditions for Wing Root and Symmetry\n');

    %% 🔄 1. Fully Fix Root Rib Nodes
    fprintf(fid, '$ Fully Fix Root Rib Nodes (All DOFs: 1-6)\n');
    for i = 1:height(root_nodes)
        fprintf(fid, 'SPC1     1       123456  %-8d\n', root_nodes.global_id(i));
    end

    %% 🔄 2. Root-Front Spar Intrados (Constrain DOFs 2 and 3)
    fprintf(fid, '$ Root-Front Spar Intrados (DOFs 2: Y-Translation and 3: Z-Translation)\n');
    fprintf(fid, 'SPC1     2       23      %-8d\n', root_front_spar_intrados.global_id);

    %% 🔄 3. Root-Rear Spar Intrados (Constrain DOF 3)
    fprintf(fid, '$ Root-Rear Spar Intrados (DOF 3: Z-Translation)\n');
    fprintf(fid, 'SPC1     3       3       %-8d\n', root_rear_spar_intrados.global_id);

    %% 🔄 4. First Rib in Fuselage (Symmetry Conditions)
    fprintf(fid, '$ First Rib in Fuselage (Symmetry Conditions: DOFs 1, 5, 6)\n');
    for i = 1:height(rib_fuselage_nodes)
        fprintf(fid, 'SPC1     4       156     %-8d\n', rib_fuselage_nodes.global_id(i));
    end

    %% 📝 Footer
    fprintf(fid, 'ENDDATA\n');
    fclose(fid);

    fprintf('Boundary conditions written to %s successfully.\n', filename);
end
