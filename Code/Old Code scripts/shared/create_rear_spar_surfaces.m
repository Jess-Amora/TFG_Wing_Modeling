function superficie_horizontal_larguero_posterior = create_rear_spar_surfaces(...
    combined_nodes, start_rib, end_rib)
% create_rear_spar_surfaces: Creates horizontal stiffening panels near the rear spar with metadata.
%
% Inputs:
%   combined_nodes: Table containing nodal information with columns:
%       - local_id: Unique node ID
%       - x, y: Node coordinates
%       - rib_index: Rib ID the node belongs to
%       - stringer_index: Stringer ID the node belongs to
%       - tag: String specifying the type of node ('rear spars', 'stringer', etc.)
%   start_rib: Integer specifying the **starting rib index** for surface creation.
%   end_rib: Integer specifying the **ending rib index** for surface creation.
%
% Outputs:
%   superficie_horizontal_larguero_posterior: Table containing surfaces with columns:
%       - local_id: Unique surface ID
%       - node_1, node_2, node_3, node_4: Corner nodes of the surface
%       - stringer_1, stringer_2: Stringer indices for nodes
%       - rib_1, rib_2: Rib indices for nodes
%       - tags: Surface type description
%       - area: Surface area (computed)
%       - aspect_ratio: Aspect ratio for FEM validation

    %% 🛡️ STEP 1: VALIDATE INPUTS
    % Ensure `combined_nodes` is a MATLAB table.
    if ~istable(combined_nodes)
        error('Input "combined_nodes" must be a MATLAB table.');
    end

    % Ensure the required columns exist in `combined_nodes`
    required_vars = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};
    if ~all(ismember(required_vars, combined_nodes.Properties.VariableNames))
        error('Table must contain required columns: %s', strjoin(required_vars, ', '));
    end

    %% 📝 STEP 2: INITIALIZE OUTPUT TABLE
    % Create an empty table for storing rear spar surfaces
    superficie_horizontal_larguero_posterior = table([], [], [], [], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'node_3', 'node_4', ...
                          'stringer_1', 'stringer_2', 'rib_1', 'rib_2', 'tags', ...
                          'area', 'aspect_ratio'});

    surface_counter = 1; % Surface ID counter

    %% 🔧 STEP 3: FILTER REAR SPAR AND FIRST STRINGER NODES
    % Assign stringer_index = -2 for all rear spar nodes
    combined_nodes.stringer_index(strcmp(combined_nodes.tag, 'rear spars')) = -2;

    % Extract nodes for the rear spar and first stringer
    rear_spar_nodes = combined_nodes(strcmp(combined_nodes.tag, 'rear spars'), :);
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer') & combined_nodes.stringer_index == 1, :);

    % Ensure valid nodes exist
    if isempty(rear_spar_nodes) || isempty(stringer_nodes)
        warning('No valid rear spar or stringer nodes found.');
        return;
    end

    %% 🔄 STEP 4: LOOP THROUGH RIBS TO CREATE SURFACES
    for index_costilla = start_rib:end_rib
        % Select rear spar and stringer nodes for the current and next rib
        rear_spar_rib1 = rear_spar_nodes(rear_spar_nodes.rib_index == index_costilla, :);
        rear_spar_rib2 = rear_spar_nodes(rear_spar_nodes.rib_index == index_costilla + 1, :);
        stringer_rib1 = stringer_nodes(stringer_nodes.rib_index == index_costilla, :);
        stringer_rib2 = stringer_nodes(stringer_nodes.rib_index == index_costilla + 1, :);

        % Skip ribs if insufficient data is found
        if isempty(rear_spar_rib1) || isempty(rear_spar_rib2) || isempty(stringer_rib1) || isempty(stringer_rib2)
            warning('Skipping rib %d: Insufficient nodes detected.', index_costilla);
            continue;
        end

        % Assign node IDs for the quad surface
        node_1 = rear_spar_rib1.local_id(1); % Rear spar at rib 1
        node_2 = stringer_rib1.local_id(1);  % First stringer at rib 1
        node_3 = stringer_rib2.local_id(1);  % First stringer at rib 2
        node_4 = rear_spar_rib2.local_id(1); % Rear spar at rib 2

        % Assign rib and stringer indices
        stringer_1 = -2; % Fixed for rear spar
        stringer_2 = 1;  % Fixed for first stringer
        rib_1 = rear_spar_rib1.rib_index(1);
        rib_2 = rear_spar_rib2.rib_index(1);

        % Calculate Area and Aspect Ratio
        surface_coords = [rear_spar_rib1.x(1), rear_spar_rib1.y(1); ...
                          stringer_rib1.x(1), stringer_rib1.y(1); ...
                          stringer_rib2.x(1), stringer_rib2.y(1); ...
                          rear_spar_rib2.x(1), rear_spar_rib2.y(1)];

        [is_valid, aspect_ratio] = check_aspect_ratio(surface_coords, 'quad');
        if ~is_valid
            warning('Skipping surface at rib %d due to poor aspect ratio.', index_costilla);
            continue;
        end
        area = polyarea(surface_coords(:, 1), surface_coords(:, 2));

        % Store surface metadata
        new_surface = table(surface_counter, node_1, node_2, node_3, node_4, ...
                            stringer_1, stringer_2, rib_1, rib_2, "quad rear", ...
                            area, aspect_ratio, ...
                            'VariableNames', superficie_horizontal_larguero_posterior.Properties.VariableNames);

        superficie_horizontal_larguero_posterior = [superficie_horizontal_larguero_posterior; new_surface];
        surface_counter = surface_counter + 1;
    end
end
%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: CREATE_REAR_SPAR_SURFACES
% ========================================================================
%
% 🛠️ **Function Overview**
% This function generates **horizontal stiffening panels** along the **rear spar** of an aircraft wing structure.
% It creates a structured table containing **quad surface elements** that connect the **rear spar** and the **first stringer**.
%
% 🔍 **Why is this function important?**
% - Defines **structural stiffening elements** for **finite element models (FEM)**.
% - Ensures proper **meshing and connectivity** between spars and stringers.
% - Provides **metadata (area, aspect ratio, and element tags)** for analysis.
%
% 📂 **Key Applications**
% - **Finite Element Modeling (FEM)**: Helps generate **shell elements** for the **rear spar structure**.
% - **Structural Strengthening**: Defines **load-bearing panels** between **rear spar** and **first stringer**.
% - **Aeroelasticity Analysis**: Facilitates **aero-structural coupling** in simulations.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Validate Inputs**  
%     - Ensures `combined_nodes` is a **valid MATLAB table**.
%     - Checks if the required columns exist.
%
% 2️⃣ **Initialize Output Table**  
%     - Creates an **empty table** to store surface data.
%
% 3️⃣ **Filter Rear Spar and First Stringer Nodes**  
%     - Extracts **nodes** corresponding to the **rear spar** and **first stringer**.
%     - Updates **stringer index** for rear spar nodes (`-2`).
%
% 4️⃣ **Loop Through Ribs to Create Surfaces**  
%     - Iterates through ribs from **start_rib to end_rib**.
%     - Identifies **four corner nodes** needed for **quad elements**.
%     - Computes **surface area and aspect ratio**.
%     - Stores **element metadata** in the output table.
%
% 5️⃣ **Return the Surface Table**  
%     - Returns a structured **table containing rear spar surfaces**.
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | node_1 | node_2 | node_3 | node_4 | stringer_1 | stringer_2 | rib_1 | rib_2 | tags             | area  | aspect_ratio |
% |----------|--------|--------|--------|--------|------------|------------|-------|-------|------------------|-------|--------------|
% | 1        | 34     | 45     | 56     | 67     | -2         | 1          | 2     | 3     | 'quad rear'      | 2.45  | 1.2          |
%
% ========================================================================
