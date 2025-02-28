function root_nodes = filter_root_nodes_v3(combined_nodes_3D_processed, rib_ranges)
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
    root_nodes_1 = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'stringer' & combined_nodes_3D_processed.rib_index == -1,:);
    root_nodes_2 = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars' & combined_nodes_3D_processed.rib_index == rib_ranges(1,2) & combined_nodes_3D_processed.h == 'extrados',:);
    root_nodes_3 = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'rear spars' & combined_nodes_3D_processed.rib_index < rib_ranges(1,2) ,:);
    root_nodes_4 = combined_nodes_3D_processed(combined_nodes_3D_processed.tag == 'front spars' & combined_nodes_3D_processed.rib_index == 1e5 & combined_nodes_3D_processed.h == 'extrados',:);
    
    root_nodes = [root_nodes_1; root_nodes_2; root_nodes_3; root_nodes_4];
end
