function write_bdf_v1(filename, nodes, elements, materials, constraints, loads)
%WRITE_BDF  Generate a simplified .bdf file for MSC/Nastran from input arrays.
%
% SYNTAX:
%   write_bdf(filename, nodes, elements, materials, constraints, loads)
%
% DESCRIPTION:
%   This function writes a .bdf file (Bulk Data File) to define a basic
%   finite element model in MSC/Nastran or Patran. The .bdf file includes:
%   - GRID cards for nodes
%   - CQUAD4 elements
%   - MAT1 material definitions
%   - SPC constraints
%   - FORCE loads
%
%   Users can extend this script to include additional card types such as
%   PSHELL, CBAR, CBUSH, PLOADn, etc.
%
% INPUTS:
%   filename    : Output .bdf file name, e.g., 'model.bdf'
%   nodes       : Nx6 array defining GRID cards. Format:
%                 [ID, CP, X, Y, Z, CD]
%                 - ID : Node ID (integer, > 0)
%                 - CP : Coordinate system for input (typically 0)
%                 - X, Y, Z : Node coordinates
%                 - CD : Output coordinate system (typically 0)
%
%   elements    : Ex6 array defining CQUAD4 elements. Format:
%                 [ID, PID, G1, G2, G3, G4]
%                 - ID  : Element ID (integer, > 0)
%                 - PID : Property ID (link to shell property, assumed 1 here)
%                 - G1..G4 : Node IDs of the 4 corners
%
%   materials   : Mx4 array defining MAT1 cards. Format:
%                 [MID, E, G, NU]
%                 - MID : Material ID (integer, > 0)
%                 - E   : Young's modulus
%                 - G   : Shear modulus
%                 - NU  : Poisson's ratio
%
%   constraints : Cx3 array specifying constraints as SPC cards. Format:
%                 [NodeID, DOF, Value]
%                 - NodeID : ID of constrained node
%                 - DOF    : Degrees of freedom to constrain (e.g., 123
%                            to fix x,y,z). If you want to fix all 6,
%                            it might be 123456, etc.
%                 - Value  : Typically 0.0 for a fixed boundary.
%
%   loads       : Lx3 array specifying loads as FORCE cards. Format:
%                 [NodeID, DOF, Magnitude]
%                 - NodeID    : ID of the node to apply the load
%                 - DOF       : Direction (1=X, 2=Y, 3=Z, etc.)
%                 - Magnitude : Load value (e.g., 1000 N)
%
% OUTPUT:
%   A file named 'filename' containing Nastran Bulk Data. Example structure:
%   BEGIN BULK
%   GRID,1,0,0.0,0.0,0.0,0
%   ...
%   CQUAD4,1,1,1,2,3,4
%   ...
%   MAT1,1,210E9,8.0E10,0.3
%   ...
%   SPC,1,123,0.0
%   FORCE,2,1,1000.0
%   ENDDATA
%
% NOTES:
%   - This is a minimal example. Production models often include
%     PSHELL/PCOMP properties, separate property IDs, multiple loads,
%     more advanced boundary conditions, etc.
%   - The function checks for duplicate IDs and invalid references
%     (e.g., element referencing a non-existent node).
%   - Confirm your data meets Nastran's numeric and formatting
%     requirements for final usage.

% -----------------------------
% 1) Basic Error Checks
% -----------------------------

if nargin < 6
    error('write_bdf requires 6 inputs: filename, nodes, elements, materials, constraints, loads.');
end

% Check that input arrays are not empty
if isempty(nodes)
    warning('NODES array is empty. No GRID cards will be written.');
end
if isempty(elements)
    warning('ELEMENTS array is empty. No CQUAD4 cards will be written.');
end
if isempty(materials)
    warning('MATERIALS array is empty. No MAT1 cards will be written.');
end

% Duplicate ID checks for nodes, elements
nodeIDs = nodes(:,1);
if numel(unique(nodeIDs)) < numel(nodeIDs)
    error('Duplicate Node IDs found in "nodes" array.');
end
% 
% elemIDs = elements(:,1);
% if numel(unique(elemIDs)) < numel(elemIDs)
%     error('Duplicate Element IDs found in "elements" array.');
% end

% Optional: Check element references to node IDs
validNodeIDs = unique(nodeIDs);  % valid node IDs in the model
for i = 1:size(elements,1)
    nodeRefs = elements(i, 3:6);
    if ~all(ismember(nodeRefs, validNodeIDs))
        error(['Element ID ' num2str(elements(i,1)) ...
               ' references an invalid node ID.']);
    end
end

% -----------------------------
% 2) Open File for Writing
% -----------------------------
fid = fopen(filename, 'w');
if fid == -1
    error('Could not open file "%s" for writing.', filename);
end

% -----------------------------
% 3) Write the Bulk Data Header
% -----------------------------
fprintf(fid, 'BEGIN BULK\n');

% -----------------------------
% 4) Write GRID (Node) Cards
% -----------------------------
for i = 1:size(nodes,1)
    nid = nodes(i,1);
    cp  = nodes(i,2);
    x   = nodes(i,3);
    y   = nodes(i,4);
    z   = nodes(i,5);
    cd  = nodes(i,6);
    % A standard Nastran GRID card format:
    % GRID, NID, CP, X, Y, Z, CD
    fprintf(fid, 'GRID,%d,%d,%.4f,%.4f,%.4f,%d\n', ...
        nid, cp, x, y, z, cd);
end

% -----------------------------
% 5) Write CQUAD4 (Element) Cards
% -----------------------------
for i = 1:size(elements,1)
    eid = elements(i,1);
    pid = elements(i,2);   % property ID, often 1 if referencing a single shell property
    g1  = elements(i,3);
    g2  = elements(i,4);
    g3  = elements(i,5);
    g4  = elements(i,6);
    % Format: CQUAD4,EID,PID,G1,G2,G3,G4
    fprintf(fid, 'CQUAD4,%d,%d,%d,%d,%d,%d\n', ...
        eid, pid, g1, g2, g3, g4);
end

% -----------------------------
% 6) Write MAT1 (Material) Cards
% -----------------------------
for i = 1:size(materials,1)
    mid = materials(i,1);
    e   = materials(i,2);
    g   = materials(i,3);
    nu  = materials(i,4);
    % Format: MAT1,MID,E,G,NU
    % Additional fields (rho, A, TREF, etc.) can be appended if needed
    fprintf(fid, 'MAT1,%d,%.4g,%.4g,%.4g\n', mid, e, g, nu);
end

% -----------------------------
% 7) Write SPC (Constraints)
% -----------------------------
% We'll use an SPC card for each constraint row:
% Format: SPC, NodeID, DOF, <Enforced value>
for i = 1:size(constraints,1)
    nodeID = constraints(i, 1);
    dof    = constraints(i, 2);  % can be 1, 123, 123456, etc.
    val    = constraints(i, 3);
    % For convenience, we treat the "dof" as a single integer or integer combination.
    % E.g., 123 means X,Y,Z are fixed. Many Nastran examples use e.g. 123 to represent that.
    fprintf(fid, 'SPC,%d,%s,%.4f\n', nodeID, num2str(dof), val);
end

% -----------------------------
% 8) Write FORCE (Loads)
% -----------------------------
% Format: FORCE, NodeID, DOF, Magnitude
% Typically: FORCE, EID?, NodeID, DirectionVector?
% In minimal form, a simplified card can be:
% FORCE, <SID>, <G>, <CID>, <F>, <N1>, <N2>, <N3>
% But for simplicity, we'll store a "direction" in DOF (1,2,3) and
% apply the entire magnitude along that axis.
%
% We'll do a simplified card: FORCE,<SID=loads(i,1)>, NodeID, DOF, Magnitude
% **But note that standard Nastran format is: FORCE SID G CID F N1 N2 N3
% You usually specify a vector direction (N1,N2,N3).
%
% This example uses a trick: if DOF=1 => [1,0,0], DOF=2 => [0,1,0], DOF=3 => [0,0,1]
% and sets a default coordinate system (CID=0).
%
% If your real model needs torque or more complex loads, adjust accordingly.
for i = 1:size(loads,1)
    nodeID    = loads(i,1);
    direction = loads(i,2);
    magnitude = loads(i,3);
    
    if direction < 1 || direction > 6
        error('Invalid DOF for load. Must be 1..6 in this simplified example.');
    end
    
    % Convert direction to a (N1,N2,N3)
    switch direction
        case 1, vec = [1, 0, 0];
        case 2, vec = [0, 1, 0];
        case 3, vec = [0, 0, 1];
        case 4, vec = [0, 0, 0];  % Rotation about X - placeholder
        case 5, vec = [0, 0, 0];  % Rotation about Y
        case 6, vec = [0, 0, 0];  % Rotation about Z
        otherwise
            vec = [0,0,0];
    end
    
    % For demonstration, let the "SID" match the node ID or some fixed ID, e.g. 1
    % (You may want a single SUBCASE load ID or a separate load collector approach.)
    SID = nodeID;
    CID = 0;  % default coordinate system
    fprintf(fid, 'FORCE,%d,%d,%d,%.4f,%.3f,%.3f,%.3f\n', ...
        SID, nodeID, CID, magnitude, vec(1), vec(2), vec(3));
end

% -----------------------------
% 9) End Bulk Data
% -----------------------------
fprintf(fid, 'ENDDATA\n');

% Close the file
fclose(fid);

fprintf('BDF file "%s" created successfully.\n', filename);

end
