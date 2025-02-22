function quad_surfaces = create_rear_spar_surfaces(combined_nodes, start_rib, end_rib)
% CREATE_REAR_SPAR_SURFACES - Generates quadrilateral surfaces along the rear spar.
%
% Inputs:
%   combined_nodes - Table containing [local_id, x, y, rib_index, stringer_index, tag].
%   start_rib      - Starting rib index for rear spar surface creation.
%   end_rib        - Ending rib index for rear spar surface creation.
%
% Outputs:
%   quad_surfaces  - Table containing quadrilateral surfaces with metadata.

    %% 📝 Initialize Output Table
    quad_surfaces = quad_initialize(); % Uses standardized quad structure
    surface_counter = 1; 

    %% 🔧 Assign Stringer Index to Rear Spar Nodes
    combined_nodes.stringer_index(strcmp(combined_nodes.tag, 'rear spars')) = -2;

    %% 🔍 Extract Rear Spar and First Stringer Nodes
    rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'), :);
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1, :);

    if isempty(rear_spar_nodes) || isempty(stringer_nodes)
        warning('No valid rear spar or stringer nodes found.');
        return;
    end

    %% 🔄 Loop Through Ribs to Create Surfaces
    for index_rib = start_rib:end_rib
        % ✅ Extract Nodes for the Current Rib
        rear_spar_rib1 = filter_nodes(rear_spar_nodes, index_rib);
        rear_spar_rib2 = filter_nodes(rear_spar_nodes, index_rib + 1);
        stringer_rib1 = filter_nodes(stringer_nodes, index_rib);
        stringer_rib2 = filter_nodes(stringer_nodes, index_rib + 1);

        % ❌ Skip if Nodes Are Missing
        if any(cellfun(@isempty, {rear_spar_rib1, rear_spar_rib2, stringer_rib1, stringer_rib2}))
            warning('Skipping rib %d: Missing nodes.', index_rib);
            continue;
        end

        % ✅ Extract Node IDs
        node_1 = rear_spar_rib1.local_id;
        node_2 = stringer_rib1.local_id;
        node_3 = stringer_rib2.local_id;
        node_4 = rear_spar_rib2.local_id;

        % ✅ Define Surface Parameters
        stringer_1 = -2; % Rear spar index
        stringer_2 = 1;  % First stringer index
        rib_1 = index_rib;
        rib_2 = index_rib + 1;
        tag = "quad rear";

        % ✅ Compute Surface & Append If Valid
        [new_surface, is_valid] = create_quad_surface_entry(...
            rear_spar_rib1, stringer_rib1, stringer_rib2, rear_spar_rib2, ...
            stringer_1, stringer_2, rib_1, rib_2, surface_counter, tag);

        if is_valid
            quad_surfaces = [quad_surfaces; new_surface];
            surface_counter = surface_counter + 1;
        end
    end
end
function node = filter_nodes(node_table, rib_index)
% FILTER_NODES - Extracts nodes from a table that match a specific rib index.
%
% Inputs:
%   node_table - Table containing node data.
%   rib_index  - The rib index to filter.
%
% Output:
%   node - The first node found for the given rib index.

    node = node_table(node_table.rib_index == rib_index, :);
    if ~isempty(node)
        node = node(1, :); % Ensure a single node is returned
    end
end

