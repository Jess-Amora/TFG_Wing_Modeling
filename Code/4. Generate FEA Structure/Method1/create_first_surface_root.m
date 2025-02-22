function [tri_surfaces, warnings] = create_first_surface_root(combined_nodes)
% create_first_surface_root: Creates the initial triangular surface at the wing root.
%
% Inputs:
%   combined_nodes - Table containing structural nodes with columns:
%       - local_id: Unique node identifier.
%       - x, y: Node coordinates.
%       - rib_index: Index of the rib associated with the node.
%       - stringer_index: Index of the stringer associated with the node.
%       - tag: Node category ('stringer', 'rear spars', etc.).
%
% Outputs:
%   tri_surfaces - Table containing triangular surface elements with columns:
%       - local_id: Unique identifier for the surface.
%       - node_1, node_2, node_3: Local node IDs forming the triangle.
%       - stringer_1, stringer_2: Stringer indices associated with the surface.
%       - rib_1, rib_2: Rib indices defining the surface.
%       - tag: Description of the surface type.
%       - area: Computed area of the triangle.
%       - aspect_ratio: Aspect ratio of the triangle.
%   warnings - Cell array containing warnings about missing or invalid nodes.

    %% 📝 STEP 1: INITIALIZATION
    % 🔹 Create an **empty table** for triangular surfaces.
    tri_surfaces = tri_initialize();
    warnings = {}; % Initialize warnings storage.

    %% 📌 STEP 2: IDENTIFY STRINGER AND SPAR NODES
    % 🔹 Define the **first stringer** (stringer_index = 1).
    stringer_index = 1;

    % 🔹 Extract all nodes belonging to **stringer 1**.
    current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index, :);

    % 🔹 Extract all nodes belonging to **stringer 2** (for adjacency).
    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1, :);

    % 🔹 Analyze the stringer-rib structure.
    [~, ~, ~, rib_ranges] = analyze_stringer_rib_data(combined_nodes);
    
    % 🔹 Identify the **starting rib index** (typically at the root).
    start_rib = rib_ranges(1,2);

    %% 🔍 STEP 3: VALIDATE NODE AVAILABILITY
    if ~isempty(current_stringer_nodes) && ~isempty(next_stringer_nodes)
        % 🔹 Identify **three key nodes** for the triangular surface.
        node_1 = current_stringer_nodes(current_stringer_nodes.rib_index == start_rib, :);
        node_2 = combined_nodes(combined_nodes.tag == 'rear spars' & combined_nodes.rib_index == start_rib, :);
        node_3 = current_stringer_nodes(current_stringer_nodes.rib_index == -1, :);

        % 🚨 **Check if any node is missing**.
        if isempty(node_1) || isempty(node_2) || isempty(node_3)
            warnings{end+1} = sprintf('Skipping root triangular surface due to missing nodes at stringer %d.', stringer_index);
            return;
        end

        %% 📐 STEP 4: COMPUTE TRIANGULAR SURFACE PROPERTIES
        % 🔹 Extract **coordinates** for the triangle.
        surface_coords = [
            node_1.x, node_1.y;
            node_2.x, node_2.y;
            node_3.x, node_3.y
        ];

        % 🔹 Compute the **area** of the triangle.
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % 🔹 Compute the **aspect ratio**.
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'triangle');

        % 🚨 **Check for poor aspect ratio**.
        if ~is_valid
            warnings{end+1} = sprintf('Skipped triangular surface due to poor aspect ratio at stringer %d.', stringer_index);
            return;
        end

        %% 📝 STEP 5: STORE TRIANGULAR SURFACE
        % 🔹 Append the new surface to the table.
        tri_surfaces = [tri_surfaces; table( ...
            1, ...       % local_id
            node_1.local_id, ...   % node_1
            node_2.local_id, ...   % node_2
            node_3.local_id, ...   % node_3
            -2, ...                % stringer_1 (rear spar)
            1, ...                 % stringer_2 (first stringer)
            -1, ...                % rib_1 (root rib)
            start_rib, ...         % rib_2 (adjacent rib)
            "tri corner root", ... % tag
            area, ...              % area
            aspect_ratio, ...      % aspect_ratio
            'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', ...
                              'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tag', ...
                              'area', 'aspect_ratio'})];
    end
end


%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: CREATE_FIRST_SURFACE_ROOT
% ========================================================================
%
% 🛠️ **Function Overview**
% This function **creates a triangular surface** at the root of the wing structure.
% It identifies the first **stringer**, the corresponding **rear spar node**, 
% and the first **root rib node**, then generates a **triangular surface** connecting them.
%
% 🔍 **Why is this function important?**
% - **Defines the boundary** of the wing root structure.
% - **Ensures proper connectivity** between **stringers, spars, and ribs**.
% - **Prepares the mesh** for the wing-fuselage interaction.
%
% 📂 **Key Applications**
% - Used to **close off the wing root** in the finite element mesh.
% - Essential for **structural analysis** in FEM.
% - Ensures **correct intersection detection** at **the wing-fuselage interface**.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Extracts Relevant Nodes**
%     - Finds the first **stringer**, **rear spar**, and **root rib** nodes.
%
% 2️⃣ **Validates Node Availability**
%     - Ensures all required nodes exist before creating the triangular surface.
%
% 3️⃣ **Computes Surface Properties**
%     - Calculates **area** and **aspect ratio** of the triangle.
%
% 4️⃣ **Stores the Surface**
%     - Saves the triangular panel in the `tri_surfaces` table.
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | node_1 | node_2 | node_3 | stringer_1 | stringer_2 | rib_1 | rib_2 | tag            | area  | aspect_ratio |
% |----------|--------|--------|--------|------------|------------|-------|-------|----------------|-------|--------------|
% | 1        | 100    | 150    | 200    | -2         | 1          | -1    | 2     | tri corner root | 0.25  | 1.5          |
%
% ========================================================================
