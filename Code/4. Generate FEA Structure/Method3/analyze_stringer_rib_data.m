function [num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data(combined_nodes)
% analyze_stringer_rib_data_v5: Analyzes stringer and rib data, including bounded ranges for both stringers and ribs.
%
% Inputs:
%   combined_nodes - Table with columns [local_id, x, y, rib_index, stringer_index, tag].
%
% Outputs:
%   num_stringers_last_rib  - Number of stringers that reach the last rib.
%   max_rib_index           - Maximum rib index (ignoring special indices like -1, 0, or >= special cutoff).
%   max_stringer_index      - Maximum stringer index.
%   rib_ranges              - Nx3 matrix where each row corresponds to a stringer:
%                             [stringer_index, min_rib_index, max_rib_index].
%   rib_ranges_by_ribs      - Mx3 matrix where each row corresponds to a rib:
%                             [rib_index, min_stringer_index, max_stringer_index].
%   special_rib_indices     - Struct containing information about special rib indices.
%   max_ribs_fuselaje       - Maximum rib index for nodes tagged as 'stringer fuselaje'.

    %% 📝 Filter Relevant Nodes
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);
    fuselage_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer fuselaje'), :);

    % Ensure there are stringer nodes
    if isempty(stringer_nodes)
        warning('No stringer nodes found in combined_nodes.');
        num_stringers_last_rib = 0;
        max_rib_index = NaN;
        max_stringer_index = NaN;
        rib_ranges = [];
        rib_ranges_by_ribs = [];
        special_rib_indices = struct('exists_rib_zero', false, ...
                                     'exists_negative_ribs', false, ...
                                     'special_ribs', []);
        max_ribs_fuselaje = NaN;
        return;
    end

    %% 🔍 Detect and Filter Special Rib Indices
    special_rib_cutoff = 1e4; % Define special rib indices as >= 1e4
    special_ribs = unique(stringer_nodes.rib_index(stringer_nodes.rib_index >= special_rib_cutoff)); % Detect special indices

    % Filter out special indices for regular ribs
    regular_ribs = stringer_nodes.rib_index(stringer_nodes.rib_index > 0 & stringer_nodes.rib_index < special_rib_cutoff);
    
    % Compute the max rib index only for regular ribs
    max_rib_index = max(regular_ribs);

    % Compute max stringer index
    max_stringer_index = max(stringer_nodes.stringer_index);

    % Compute max ribs for fuselage nodes
    if ~isempty(fuselage_nodes)
        max_ribs_fuselaje = max(fuselage_nodes.rib_index);
    else
        max_ribs_fuselaje = NaN;
        % warning('No fuselage nodes (tag == "stringer fuselaje") found in combined_nodes.');
    end

    %% ✅ Detect Special Rib Indices
    exists_rib_zero = any(stringer_nodes.rib_index == 0); % Check if rib_index = 0 exists
    exists_negative_ribs = any(stringer_nodes.rib_index <= -3); % Check if rib_index <= -3 exists

    % Store results in a struct
    special_rib_indices = struct('exists_rib_zero', exists_rib_zero, ...
                                 'exists_negative_ribs', exists_negative_ribs, ...
                                 'special_ribs', special_ribs);

    %% 🔄 Calculate Stringer Rib Ranges
    rib_ranges = zeros(max_stringer_index, 3); % Preallocate [stringer_index, min_rib, max_rib]
    num_stringers_last_rib = 0;

    for stringer_idx = 1:max_stringer_index
        % Extract nodes for the current stringer
        current_stringer_nodes = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        if isempty(current_stringer_nodes)
            continue; % Skip if no nodes for this stringer
        end

        % Exclude special rib indices when calculating min and max rib indices
        positive_ribs = current_stringer_nodes.rib_index(current_stringer_nodes.rib_index > 0 & current_stringer_nodes.rib_index < special_rib_cutoff);
        min_rib = min(positive_ribs);
        max_rib = max(positive_ribs);

        % Check if the stringer reaches the last rib
        if any(positive_ribs == max_rib_index)
            num_stringers_last_rib = num_stringers_last_rib + 1;
        end

        % Store stringer data in rib_ranges
        rib_ranges(stringer_idx, :) = [stringer_idx, min_rib, max_rib];
    end

    rib_ranges = rib_ranges(any(rib_ranges, 2), :); % Remove rows with all zeros

    %% 🔄 Calculate Rib Ranges
    unique_ribs = unique(stringer_nodes.rib_index(stringer_nodes.rib_index > 0 & stringer_nodes.rib_index < special_rib_cutoff));
    rib_ranges_by_ribs = zeros(length(unique_ribs), 3); % Preallocate [rib_index, min_stringer, max_stringer]

    for i = 1:length(unique_ribs)
        rib = unique_ribs(i);

        % Extract nodes for the current rib
        current_rib_nodes = stringer_nodes(stringer_nodes.rib_index == rib, :);

        % Find min and max stringer indices for this rib
        min_stringer = min(current_rib_nodes.stringer_index);
        max_stringer = max(current_rib_nodes.stringer_index);

        % Store rib data in rib_ranges_by_ribs
        rib_ranges_by_ribs(i, :) = [rib, min_stringer, max_stringer];
    end

    %% ✅ Output Results
    % Uncomment to display results
    % disp('Rib ranges for each rib:');
    % disp(array2table(rib_ranges_by_ribs, 'VariableNames', {'Rib_Index', 'Min_Stringer', 'Max_Stringer'}));
end
%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: ANALYZE_STRINGER_RIB_DATA
% ========================================================================
%
% 🛠️ **Function Overview**
% This function analyzes the geometric relationships between **stringers** and **ribs** in an aircraft wing or fuselage structure. 
% It identifies **rib and stringer boundaries**, detects **special rib indices**, and determines the maximum rib and stringer indices.
%
% 🔍 **Why is this function important?**
% In **finite element modeling (FEM)** and **structural analysis**, understanding how **stringers (stiffeners)** are distributed along 
% the ribs is **critical** for defining load paths and ensuring proper meshing.
%
% 📂 **Key Applications**
% - **Structural Modeling:** Helps define the **connectivity** between stringers and ribs in the FEM mesh.
% - **Load Distribution:** Determines where **stiffeners contribute to load-bearing capacity**.
% - **Finite Element Analysis (FEA):** Assists in **meshing strategies** for wing and fuselage structures.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Filter Relevant Nodes**  
%     - Extracts nodes tagged as **'stringer'** and **'stringer fuselaje'**.  
%     - If no stringers exist, it **returns empty outputs** to avoid errors.  
%
% 2️⃣ **Detect and Filter Special Rib Indices**  
%     - Identifies **special ribs** (e.g., indices ≥ 10,000) which are often used for **root ribs, spars, or constraints**.  
%     - Excludes these from **regular rib indexing**.  
%
% 3️⃣ **Find Maximum Rib and Stringer Indices**  
%     - Determines the **maximum rib index**, ignoring special indices.  
%     - Computes the **maximum stringer index**, which is useful for **looping through stringers later**.  
%
% 4️⃣ **Detect Special Cases (Zero or Negative Ribs)**  
%     - Identifies cases where **rib_index == 0** (e.g., centerline nodes).  
%     - Checks for **negative ribs**, which sometimes indicate **reference points or dummy nodes**.  
%
% 5️⃣ **Calculate Rib Ranges for Each Stringer**  
%     - For each **stringer**, finds its **starting (min) and ending (max) rib indices**.  
%     - Stores this data in **rib_ranges** (`[stringer_index, min_rib, max_rib]`).  
%     - Counts the **number of stringers reaching the last rib**.  
%
% 6️⃣ **Calculate Stringer Ranges for Each Rib**  
%     - For each **rib**, finds its **smallest and largest stringer indices**.  
%     - Stores this data in **rib_ranges_by_ribs** (`[rib_index, min_stringer, max_stringer]`).  
%
% 7️⃣ **Return Computed Data**  
%     - Outputs matrices and structs that describe the **geometric relationships between stringers and ribs**.  
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURES**
%
% 1️⃣ **rib_ranges (Nx3 matrix)**  
%    | Stringer Index | Min Rib Index | Max Rib Index |
%    |--------------|--------------|--------------|
%    | 1            | 2            | 10           |
%    | 2            | 3            | 12           |
%
% 2️⃣ **rib_ranges_by_ribs (Mx3 matrix)**  
%    | Rib Index | Min Stringer Index | Max Stringer Index |
%    |----------|------------------|------------------|
%    | 1        | 1                | 5                |
%    | 2        | 1                | 6                |
%
% 3️⃣ **special_rib_indices (struct)**  
%    | Field               | Description |
%    |-----------------|--------------------------------------------------|
%    | exists_rib_zero | `true` if a rib with index 0 exists              |
%    | exists_negative_ribs | `true` if negative rib indices exist       |
%    | special_ribs    | List of ribs with indices >= 1e4 (special cases) |
%
% ========================================================================
% 🚀 **POSSIBLE FUTURE IMPROVEMENTS**
% - 🔄 **Optimize Memory Usage:** Convert `rib_ranges` and `rib_ranges_by_ribs` into **sparse matrices** for large models.  
% - ⚡ **Vectorization:** Reduce loops for rib-range computation using **MATLAB's built-in functions**.  
% - 📊 **Visualization:** Integrate a **plot function** to display rib and stringer connectivity.  
%
% ========================================================================
% 🎯 **FINAL REMARKS**
% - This function is **essential** for pre-processing **structural models** in MATLAB.  
% - It **organizes geometric data** efficiently, making it easier to **generate meshes** for simulations.  
%
% ========================================================================
