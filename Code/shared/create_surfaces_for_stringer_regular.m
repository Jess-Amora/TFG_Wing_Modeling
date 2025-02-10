function [quad_surfaces, warnings] = create_surfaces_for_stringer_regular(...
    combined_nodes, stringer_index, start_rib, end_rib, threshold_distance)
% create_surfaces_for_stringer_regular: Generates structured quad elements between adjacent stringers.
%
% Inputs:
%   combined_nodes: Table containing nodal data with columns:
%       - local_id: Unique node ID
%       - x, y: Node coordinates
%       - rib_index: Rib ID the node belongs to
%       - stringer_index: Stringer ID the node belongs to
%       - tag: Node category ('stringer', 'rear spars', etc.)
%   stringer_index: Integer specifying the **current stringer index**.
%   start_rib: Integer specifying the **starting rib index**.
%   end_rib: Integer specifying the **ending rib index**.
%   threshold_distance: Minimum allowable distance for surface validity.
%
% Outputs:
%   quad_surfaces: Table containing generated quadrilateral surfaces with columns:
%       - local_id: Unique surface ID.
%       - node_1, node_2, node_3, node_4: Local node IDs defining the surface.
%       - stringer_1, stringer_2: Stringer indices for connectivity.
%       - rib_1, rib_2: Rib indices defining the surface.
%       - tags: Surface type description.
%       - area: Surface area (computed).
%       - aspect_ratio: Aspect ratio for FEM validation.
%   warnings: Cell array containing warning messages.

    %% 📝 STEP 1: INITIALIZATION
    % Create an empty table to store quadrilateral surfaces
    quad_surfaces = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});
    warnings = {};  % Initialize empty cell array for warning messages
    surface_counter = 1;  % Surface ID counter

    %% 🔍 STEP 2: FILTER NODES BY STRINGER AND RIB INDICES
    % Select nodes belonging to the **current stringer** within the rib range
    current_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index & ...
                                            combined_nodes.rib_index >= start_rib & ...
                                            combined_nodes.rib_index <= end_rib, :);

    % Select nodes belonging to the **next stringer** within the rib range
    next_stringer_nodes = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                                         combined_nodes.rib_index >= start_rib & ...
                                         combined_nodes.rib_index <= end_rib, :);

    % Handle cases where nodes are missing
    if isempty(current_stringer_nodes) || isempty(next_stringer_nodes)
        warnings{end+1} = sprintf('No valid nodes found for stringer %d.', stringer_index);
        return;
    end

    %% 🔄 STEP 3: LOOP THROUGH RIBS TO CREATE QUAD ELEMENTS
    % Define number of ribs based on available nodes
    num_ribs = min(height(current_stringer_nodes), height(next_stringer_nodes)) - 1;

    % Check if there are enough ribs to proceed
    if num_ribs < 1
        warnings{end+1} = sprintf('Insufficient nodes for stringer %d in the rib range.', stringer_index);
        return;
    end

    for i = 1:num_ribs
        % Extract the four corner nodes for the quadrilateral surface
        node_1 = current_stringer_nodes(i, :);       % Bottom-left
        node_4 = current_stringer_nodes(i + 1, :);   % Top-left
        node_3 = next_stringer_nodes(i + 1, :);      % Top-right
        node_2 = next_stringer_nodes(i, :);          % Bottom-right

        % Ensure nodes are valid (not empty)
        if isempty(node_1) || isempty(node_2) || isempty(node_3) || isempty(node_4)
            warnings{end+1} = sprintf('Skipping surface at rib %d due to missing nodes.', start_rib + i - 1);
            continue;
        end

        % Extract coordinates for surface property calculations
        surface_coords = [
            node_1.x(1), node_1.y(1);
            node_2.x(1), node_2.y(1);
            node_3.x(1), node_3.y(1);
            node_4.x(1), node_4.y(1)
        ];

        % Compute area and aspect ratio
        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warnings{end+1} = sprintf('Poor aspect ratio at rib pair %d-%d.', start_rib + i - 1, start_rib + i);
            continue;
        end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Append new surface to the table
        new_surface = table( ...
            surface_counter, ...        % Unique surface ID
            node_1.local_id, ...        % Bottom-left node
            node_2.local_id, ...        % Bottom-right node
            node_3.local_id, ...        % Top-right node
            node_4.local_id, ...        % Top-left node
            stringer_index, ...         % First stringer
            stringer_index + 1, ...     % Second stringer
            node_1.rib_index, ...       % Rib 1
            node_3.rib_index, ...       % Rib 2
            "quad regular", ...         % Surface tag
            area, ...                   % Computed area
            aspect_ratio, ...           % Computed aspect ratio
            'VariableNames', quad_surfaces.Properties.VariableNames);
        
        % Add the new surface to the table
        quad_surfaces = [quad_surfaces; new_surface];

        % Increment surface counter
        surface_counter = surface_counter + 1;
    end
end

%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: CREATE_SURFACES_FOR_STRINGER_REGULAR
% ========================================================================
%
% 🛠️ **Function Overview**
% This function generates **regular quadrilateral (quad) surface elements** between
% adjacent stringers within a **specified rib range**.
%
% 🔍 **Why is this function important?**
% - Ensures proper **meshing and connectivity** between **stringers and ribs**.
% - Generates **structural panels** that define the **wing’s stiffness and strength**.
% - Provides **geometric validation (aspect ratio & area calculations)** for FEM models.
%
% 📂 **Key Applications**
% - **Finite Element Analysis (FEA)**: Generates structured **quad elements**.
% - **Structural Mesh Generation**: Helps in defining the **aerodynamic shape of the wing**.
% - **Load Transfer Between Stringers**: Connects stringers to ensure **correct force distribution**.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Initialize Surface Table and Warnings**
%     - Creates an empty **table to store surfaces**.
%     - Initializes **warnings array** for error handling.
%
% 2️⃣ **Filter Nodes by Stringer and Rib Indices**
%     - Extracts **nodes belonging to the current and next stringer**.
%     - Ensures valid node data exists before proceeding.
%
% 3️⃣ **Loop Through Ribs to Create Surfaces**
%     - Iterates over ribs from `start_rib` to `end_rib`.
%     - Identifies **four corner nodes** required for **quad formation**.
%     - Computes **surface area and aspect ratio** for mesh validation.
%
% 4️⃣ **Return Surface Table and Warnings**
%     - Returns a **structured table** containing **quad panels**.
%     - Logs **warnings** for potential errors in node selection.
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | node_1 | node_2 | node_3 | node_4 | stringer_1 | stringer_2 | rib_1 | rib_2 | tags          | area  | aspect_ratio |
% |----------|--------|--------|--------|--------|------------|------------|-------|-------|--------------|-------|--------------|
% | 1        | 34     | 45     | 56     | 67     | 2          | 3          | 4     | 5     | 'quad regular' | 2.45  | 1.2          |
%
% ========================================================================
