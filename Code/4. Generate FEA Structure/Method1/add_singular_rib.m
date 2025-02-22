function combined_nodes_modified = add_singular_rib(combined_nodes, point_1, point_2, rib_index, tag)
% add_singular_rib: Adds a new rib by computing intersections with stringers.
%
% Inputs:
%   combined_nodes - Table with existing nodes. Columns:
%       - local_id: Unique node identifier.
%       - x, y: Node coordinates.
%       - rib_index: Rib index where the node is located.
%       - stringer_index: Stringer index where the node is located.
%       - tag: Node category ('stringer', 'constructed', etc.).
%   point_1 - [x, y] coordinates of the first point defining the rib.
%   point_2 - [x, y] coordinates of the second point defining the rib.
%   rib_index - The rib index assigned to the new rib.
%   tag - Tag for the newly constructed nodes (e.g., 'constructed').
%
% Output:
%   combined_nodes_modified - Updated table with newly inserted rib nodes.

    %% 📝 STEP 1: INITIALIZATION
    % 🔹 Create a **copy** of `combined_nodes` for modification.
    combined_nodes_modified = combined_nodes;
    warnings = {}; % Store warnings if needed.
    added_nodes = zeros(0, 2); % Keep track of inserted nodes.

    % 🔹 Find the **maximum existing local_id** for constructed nodes.
    constructed_nodes = combined_nodes(strcmp(combined_nodes.tag, 'constructed'), :);

    if isempty(constructed_nodes)
        % If no constructed nodes exist, start after the **highest existing node ID**.
        next_local_id = max(combined_nodes.local_id) + 1;
    else
        % Otherwise, continue numbering from the **highest constructed node ID**.
        next_local_id = max(constructed_nodes.local_id) + 1;
    end

    %% 📐 STEP 2: COMPUTE RIB LINE EQUATION
    % Extract coordinates for the rib line.
    x1 = point_1(1); y1 = point_1(2);
    x2 = point_2(1); y2 = point_2(2);

    % 🔹 Calculate slope (`m_rib`) and intercept (`b_rib`).
    if abs(x2 - x1) < 1e-8
        % **Vertical Line Case** (Avoids division by zero).
        m_rib = Inf;
        b_rib = x1; % The x-coordinate remains constant.
    else
        % **Regular Line Case** (y = mx + b).
        m_rib = (y2 - y1) / (x2 - x1);
        b_rib = y1 - m_rib * x1;
    end

    %% 🔄 STEP 3: PROCESS EACH STRINGER
    % 🔹 Extract all nodes tagged as **stringers**.
    stringer_nodes = combined_nodes(strcmp(combined_nodes.tag, 'stringer'), :);
    unique_stringers = unique(stringer_nodes.stringer_index);

    % 🔹 Iterate through **each stringer**.
    for stringer_idx = unique_stringers'
        % Select nodes belonging to the **current stringer**.
        stringer_points = stringer_nodes(stringer_nodes.stringer_index == stringer_idx, :);

        % 🔹 Ensure the stringer has **at least two nodes**.
        if height(stringer_points) < 2
            warnings{end+1} = sprintf('Skipping stringer %d: Insufficient nodes.', stringer_idx);
            continue;
        end

        %% 🔄 STEP 4: LOOP THROUGH STRINGER SEGMENTS
        for i = 1:height(stringer_points) - 1
            % Extract **two consecutive nodes** (defining a segment).
            p1_stringer = stringer_points(i, :);
            p2_stringer = stringer_points(i + 1, :);

            x3 = p1_stringer.x; y3 = p1_stringer.y;
            x4 = p2_stringer.x; y4 = p2_stringer.y;

            % 🔹 Compute slope (`m_stringer`) and intercept (`b_stringer`).
            if abs(x4 - x3) < 1e-8
                m_stringer = Inf;
                b_stringer = x3; % Vertical case.
            else
                m_stringer = (y4 - y3) / (x4 - x3);
                b_stringer = y3 - m_stringer * x3;
            end

            % 📌 Compute Intersection Point
            cortes = cortes_de_dos_funciones_lineales([x1, y1], m_rib, [x3, y3; x4, y4], m_stringer);

            % Round intersection points to **8 decimal places**.
            intersection_x = round(cortes(1, 1, 1), 8);
            intersection_y = round(cortes(1, 1, 2), 8);

            % 📌 Ensure intersection is **within segment bounds**.
            if (intersection_x >= min(x3, x4) && intersection_x <= max(x3, x4)) && ...
               (intersection_y >= min(y3, y4) && intersection_y <= max(y3, y4))
               
                % 🚀 **Check for Duplicate Nodes**
                if ~ismember([intersection_x, intersection_y], added_nodes, 'rows')
                    % 🔹 Add **new constructed node**.
                    combined_nodes_modified = [combined_nodes_modified; table( ...
                        next_local_id, intersection_x, intersection_y, rib_index, ...
                        stringer_idx, string(tag), ... % Convert tag to string format.
                        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'})];

                    % 🔹 Store the added node.
                    added_nodes = [added_nodes; intersection_x, intersection_y];
                    next_local_id = next_local_id + 1;
                end
            end
        end
    end

    %% ✅ STEP 5: OUTPUT RESULTS
    if ~isempty(warnings)
        disp('Warnings:');
        disp(warnings);
    end

    disp('✅ Singular rib added successfully.');
end

%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: ADD_SINGULAR_RIB
% ========================================================================
%
% 🛠️ **Function Overview**
% This function **adds a new rib** to the `combined_nodes` table by computing
% **intersections** between **stringers** and the line passing through two 
% given points (`point_1` and `point_2`). 
%
% 🔍 **Why is this function important?**
% - **Dynamically inserts ribs** in specific regions.
% - **Identifies and inserts intersection points** between the rib and stringers.
% - **Improves FEM connectivity** by ensuring structured nodal placement.
%
% 📂 **Key Applications**
% - Used for **reinforcing the structure** by adding an extra rib.
% - Applied near the **wing root** for extra support.
% - Ensures **correct intersection detection** between **stringers and ribs**.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Initialize Variables** 
%     - Extracts **current max local_id**.
%
% 2️⃣ **Compute Rib Line Equation**
%     - Calculates **slope (`m_rib`)** and **intercept (`b_rib`)** of the rib.
%
% 3️⃣ **Loop Through Stringers**
%     - Finds **intersections** between the rib and **each stringer segment**.
%
% 4️⃣ **Validate and Store New Nodes**
%     - Ensures **valid intersections** within segment bounds.
%     - Prevents **duplicate nodes**.
%
% 5️⃣ **Append New Nodes to `combined_nodes`**
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | x      | y      | rib_index | stringer_index | tag       |
% |----------|--------|--------|-----------|----------------|-----------|
% | 154      | 3.12   | 2.86   |  5        | 3              | stringer  |
% | 155      | 3.60   | 2.92   |  5        | 4              | stringer  |
% | 200      | 5.00   | 3.10   | 10        | 6              | stringer  |
%
% ========================================================================
