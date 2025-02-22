function check_mesh_quality(quads_matrix, tris_matrix, nodes_table)
% CHECK_MESH_QUALITY: Computes and verifies aspect ratio, angles, and skewness of QUAD4 and TRIA3 elements.
%
% Inputs:
%   quads_matrix - Nx6 matrix for quads: [EID, PID, G1, G2, G3, G4, THETA, ZOFFS].
%   tris_matrix  - Mx5 matrix for tris: [EID, PID, G1, G2, G3, THETA, ZOFFS].
%   nodes_table  - Table containing node coordinates with columns: [global_id, x, y, z].
%
% Outputs:
%   Warnings for bad aspect ratio, skewness, and angles.

    fprintf('🔍 Checking Mesh Quality...\n');

    % Initialize issue counters
    bad_aspect_count = 0;
    bad_angle_count = 0;
    bad_skew_count = 0;

    %% 🟢 Check QUAD4 Elements
    fprintf('\n🔹 Checking QUAD4 Elements (CQUAD4)...\n');
    for i = 1:size(quads_matrix, 1)
        % Extract node IDs
        node_ids = quads_matrix(i, 3:6);
        
        % Get node coordinates
        coords = get_node_coords(node_ids, nodes_table);

        % Compute Aspect Ratio
        aspect_ratio = calculate_aspect_ratio(coords, 'quad');

        % Compute Interior Angles
        angles = calculate_quad_angles(coords);

        % Check for bad elements
        if aspect_ratio > 5
            fprintf('⚠️ QUAD4 %d has a high aspect ratio (%.2f > 5)\n', quads_matrix(i, 1), aspect_ratio);
            bad_aspect_count = bad_aspect_count + 1;
        end
        if min(angles) < 30 || max(angles) > 150
            fprintf('⚠️ QUAD4 %d has bad angles (%.2f° - %.2f°)\n', quads_matrix(i, 1), min(angles), max(angles));
            bad_angle_count = bad_angle_count + 1;
        end
    end

    %% 🟢 Check TRIA3 Elements
    fprintf('\n🔹 Checking TRIA3 Elements (CTRIA3)...\n');
    for i = 1:size(tris_matrix, 1)
        % Extract node IDs
        node_ids = tris_matrix(i, 3:5);

        % Get node coordinates
        coords = get_node_coords(node_ids, nodes_table);

        % Compute Aspect Ratio
        aspect_ratio = calculate_aspect_ratio(coords, 'tri');

        % Compute Skewness
        skewness = calculate_triangle_skew(coords);

        % Check for bad elements
        if aspect_ratio > 5
            fprintf('⚠️ TRIA3 %d has a high aspect ratio (%.2f > 5)\n', tris_matrix(i, 1), aspect_ratio);
            bad_aspect_count = bad_aspect_count + 1;
        end
        if skewness < 10
            fprintf('⚠️ TRIA3 %d has a low skew angle (%.2f° < 10°)\n', tris_matrix(i, 1), skewness);
            bad_skew_count = bad_skew_count + 1;
        end
    end

    % Summary
    fprintf('\n✅ Mesh Quality Check Completed\n');
    fprintf('⚠️ %d QUAD4 elements with bad aspect ratio or angles\n', bad_aspect_count);
    fprintf('⚠️ %d TRIA3 elements with bad aspect ratio or skewness\n', bad_skew_count);
end
