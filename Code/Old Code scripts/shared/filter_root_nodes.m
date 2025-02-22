function root_nodes = filter_root_nodes(combined_nodes_3D_processed, Lf)
% FILTER_ROOT_NODES: Filters nodes at the root plane (x = Lf) for Y-Z boundary conditions.
%
% Inputs:
%   combined_nodes_3D_processed - Table containing all 3D nodes with columns:
%                                 {'local_id', 'x', 'y', 'z', ...}.
%   Lf                          - Length of the fuselage where the wing root lies (x = Lf).
%
% Outputs:
%   root_nodes                  - Subset of nodes with x = Lf, representing the Y-Z plane at the root.

    %% 🟢 Filter Nodes at x = Lf
    % Identify nodes where x-coordinate matches Lf (tolerance for floating-point precision)
    tolerance = 1e-6; % Adjust as needed for numerical accuracy
    is_at_root = abs(combined_nodes_3D_processed.x - Lf) < tolerance;

    % Extract nodes at the root plane
    root_nodes = combined_nodes_3D_processed(is_at_root, :);

    %% 🔴 Error Handling: Ensure Non-Empty Output
    if isempty(root_nodes)
        error('No nodes found at x = %.6f. Check Lf or node coordinates.', Lf);
    end

end
