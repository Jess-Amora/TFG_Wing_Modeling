function combined_nodes_modified = add_nodes_to_combined_nodes(combined_nodes, new_nodes)
% add_nodes_to_combined_nodes: Adds new nodes to the `combined_nodes` table 
% while ensuring each node has a **unique local_id** within its category (`tag`).
%
% Inputs:
%   combined_nodes: Table with existing nodes. Columns:
%       - local_id: Unique node identifier.
%       - x, y: Node coordinates.
%       - rib_index: Index of the rib where the node is located.
%       - stringer_index: Index of the stringer where the node is located.
%       - tag: Node category ('stringer', 'rear spars', 'front spars', etc.).
%   new_nodes: Table containing **additional nodes** to be added.
%       - Must have the same structure as `combined_nodes`.
%
% Outputs:
%   combined_nodes_modified: Updated table containing both **existing** 
%                            and **newly added** nodes.

    %% 📝 STEP 1: INITIALIZATION
    % 🔹 Create a **copy** of `combined_nodes` to store modifications.
    combined_nodes_modified = combined_nodes;

    %% 🔍 STEP 2: VALIDATE INPUT STRUCTURE
    % Define the required table columns.
    required_columns = {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'};

    % 🚨 Ensure `new_nodes` has all necessary columns.
    if ~all(ismember(required_columns, new_nodes.Properties.VariableNames))
        error('new_nodes must have the following columns: %s', strjoin(required_columns, ', '));
    end

    %% 🔄 STEP 3: HANDLE MISSING LOCAL IDs (NaN)
    % If any node has `NaN` as `local_id`, assign **temporary placeholder (-1)**
    missing_local_id_mask = isnan(new_nodes.local_id);
    if any(missing_local_id_mask)
        new_nodes.local_id(missing_local_id_mask) = -1;
    end

    %% 🔢 STEP 4: ASSIGN UNIQUE LOCAL IDs BASED ON NODE CATEGORY (`TAG`)
    % Get **unique node categories** in `new_nodes`
    unique_tags = unique(new_nodes.tag);

    % 🔹 Iterate through each node category (`tag`) to assign IDs sequentially
    for i = 1:length(unique_tags)
        current_tag = unique_tags{i}; % Select the current category

        % 🔹 Extract **existing nodes** with the same category (`tag`)
        existing_tag_nodes = combined_nodes(strcmp(combined_nodes.tag, current_tag), :);

        if ~isempty(existing_tag_nodes)
            % If the tag exists, **start IDs from the highest existing local_id + 1**
            max_local_id_for_tag = max(existing_tag_nodes.local_id);
            start_local_id = max_local_id_for_tag + 1;
        else
            % If the tag does not exist yet, start from **1**
            start_local_id = 1;
        end

        % 🔹 Assign new `local_id` values for nodes of this category
        tag_mask = strcmp(new_nodes.tag, current_tag);
        tag_indices = find(tag_mask); % Get **row indices** for this tag
        new_nodes.local_id(tag_indices) = (start_local_id:(start_local_id + length(tag_indices) - 1))';
    end

    %% ➕ STEP 5: APPEND NEW NODES TO COMBINED_NODES
    % **Merge** the updated `new_nodes` into `combined_nodes_modified`
    combined_nodes_modified = [combined_nodes_modified; new_nodes];

    % ✅ Success Message (Optional)
    % disp('✅ Nodes added successfully to combined_nodes.');
end



%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: ADD_NODES_TO_COMBINED_NODES
% ========================================================================
%
% 🛠️ **Function Overview**
% This function **adds new nodes** to the existing `combined_nodes` table, 
% while ensuring that each node receives a **unique local_id** within its 
% respective **category (`tag`)**.
%
% 🔍 **Why is this function important?**
% - **Ensures Unique Node IDs**: Avoids conflicts in node numbering.
% - **Maintains Data Organization**: Keeps nodes sorted by their **category (`tag`)**.
% - **Prepares for Finite Element Analysis (FEA)**: Helps in structured meshing.
%
% 📂 **Key Applications**
% - Used for **adding new nodes** dynamically while preserving structural organization.
% - **Essential in irregular geometries** where additional nodes are required.
% - Prevents **NaN or duplicate IDs**, ensuring proper **mesh connectivity**.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Validate Input Structure**
%     - Ensures `new_nodes` has **correct columns**.
%
% 2️⃣ **Handle Missing Local IDs**
%     - Assigns **temporary placeholders** for `NaN` values.
%
% 3️⃣ **Assign Unique Local IDs Per Category**
%     - Finds the **maximum existing ID** for each `tag` and **increments accordingly**.
%
% 4️⃣ **Append New Nodes to `combined_nodes`**
%     - Merges the updated `new_nodes` table into `combined_nodes`.
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | x      | y      | rib_index | stringer_index | tag      |
% |----------|--------|--------|-----------|----------------|----------|
% | 54       | 3.25   | 2.88   | 10        | 3              | stringer |
% | 55       | 3.60   | 2.92   | 11        | 3              | stringer |
% | 120      | 5.00   | 3.10   | 20        | 5              | front_spar |
%
% ========================================================================
