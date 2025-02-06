function cleaned_nodes = remove_unused_nodes(combined_nodes_3D_processed, quads_matrix, tris_matrix, lines_matrix)
% REMOVE_UNUSED_NODES: Removes nodes that are not referenced in any element.
%
% Inputs:
%   combined_nodes_3D_processed - Table of all nodes (including unused ones).
%   quads_matrix - Nx8 matrix for quads: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
%   tris_matrix  - Mx7 matrix for tris: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   lines_matrix - Px4 matrix for lines: [EID, PID, G1, G2].
%
% Output:
%   cleaned_nodes - Table of only used nodes.

    fprintf('🔍 Checking for unused nodes...\n');

    % Extract node IDs from each element type
    quad_nodes = quads_matrix(:, 3:6);  % 4 nodes per quad
    tri_nodes  = tris_matrix(:, 3:5);   % 3 nodes per triangle
    line_nodes = lines_matrix(:, 3:4);  % 2 nodes per line

    % Convert to row vector and get unique node IDs
    used_nodes = unique([quad_nodes(:); tri_nodes(:); line_nodes(:)]);

    % Find nodes that are actually used
function cleaned_nodes = remove_unused_nodes(combined_nodes_3D_processed, quads_matrix, tris_matrix, lines_matrix)
% REMOVE_UNUSED_NODES: Removes nodes that are not referenced in any element.
%
% Inputs:
%   combined_nodes_3D_processed - Table of all nodes (including unused ones).
%   quads_matrix - Nx8 matrix for quads: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
%   tris_matrix  - Mx7 matrix for tris: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   lines_matrix - Px4 matrix for lines: [EID, PID, G1, G2].
%
% Output:
%   cleaned_nodes - Table of only used nodes.

    fprintf('🔍 Checking for unused nodes...\n');

    % ✅ Ensure input is a table
    if ~istable(combined_nodes_3D_processed)
        error('❌ ERROR: combined_nodes_3D_processed must be a table.');
    end

    % ✅ Ensure "global_id" column exists before filtering
    if ~ismember('global_id', combined_nodes_3D_processed.Properties.VariableNames)
        error('❌ ERROR: "global_id" column is missing from combined_nodes_3D_processed.');
    end

    % ✅ Convert global_id to double if needed
    if ~isa(combined_nodes_3D_processed.global_id, 'double')
        combined_nodes_3D_processed.global_id = str2double(combined_nodes_3D_processed.global_id);
    end

    % Extract node IDs from each element type
    quad_nodes = quads_matrix(:, 3:6);  % 4 nodes per quad
    tri_nodes  = tris_matrix(:, 3:5);   % 3 nodes per triangle
    line_nodes = lines_matrix(:, 3:4);  % 2 nodes per line

    % Convert to row vector and get unique node IDs
    used_nodes = unique([quad_nodes(:); tri_nodes(:); line_nodes(:)]);

    % ✅ Ensure `used_nodes` is a double vector
    used_nodes = double(used_nodes); 

    % ✅ Find and keep only used nodes
    cleaned_nodes = combined_nodes_3D_processed(ismember(combined_nodes_3D_processed.global_id, used_nodes), :);

    % Display results
    num_removed = height(combined_nodes_3D_processed) - height(cleaned_nodes);
    fprintf('✅ Removed %d unused nodes. Remaining nodes: %d\n', num_removed, height(cleaned_nodes));
end
    cleaned_nodes = combined_nodes_3D_processed(ismember(combined_nodes_3D_processed.global_id, used_nodes), :);

    % Display results
    num_removed = height(combined_nodes_3D_processed) - height(cleaned_nodes);
    fprintf('✅ Removed %d unused nodes. Remaining nodes: %d\n', num_removed, height(cleaned_nodes));
end
