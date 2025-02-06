function root_nodes = filter_root_nodes_v2(combined_nodes_3D_processed, Lf, rib_ranges)
% FILTER_ROOT_NODES: Filters nodes at the root plane (x = Lf) for Y-Z boundary conditions.
%
% Inputs:
%   combined_nodes_3D_processed - Table containing all 3D nodes with columns:
%                                 {'global_id', 'x', 'y', 'z', 'tag', 'rib_index', 'h'}.
%   Lf                          - Length of the fuselage where the wing root lies (x = Lf).
%   rib_ranges                  - Matrix defining rib index ranges, used to determine root rear spar intrados.
%
% Outputs:
%   root_nodes                  - Subset of nodes at x = Lf, excluding front and rear spar intrados.

    %% ✅ 1. Filter Nodes at x = Lf
    tolerance = 1e-6; % Adjust as needed for numerical accuracy
    is_at_root = abs(combined_nodes_3D_processed.x - Lf) < tolerance;
    root_nodes = combined_nodes_3D_processed(is_at_root, :);

    %% 🚫 2. Exclude Front & Rear Spar Intrados Nodes
    % Identify nodes to exclude
    exclude_nodes = (root_nodes.tag == "front spars" & root_nodes.rib_index == 1e5 & root_nodes.h == "intrados") | ...
                    (root_nodes.tag == "rear spars" & root_nodes.rib_index == rib_ranges(1,2) & root_nodes.h == "intrados");

    % Remove those nodes
    root_nodes = root_nodes(~exclude_nodes, :);

    %% 🔴 3. Error Handling: Ensure Non-Empty Output
    if isempty(root_nodes)
        error('No valid root nodes found at x = %.6f. Check Lf or node coordinates.', Lf);
    end

end
