function [combined_nodes, Inserted_node] = add_perpendicular_node_to_front_spar(combined_nodes, stringer_index, geometria, datosEstructural)
% add_perpendicular_node_to_front_spar: Adds a new node **perpendicular** to the front spar 
% at the endpoint of a given stringer.
%
% Inputs:
%   combined_nodes: Table containing existing nodes with columns:
%       - local_id: Unique node ID.
%       - x, y: Node coordinates.
%       - rib_index: Index of the rib to which the node belongs.
%       - stringer_index: Index of the stringer to which the node belongs.
%       - tag: Node category ('stringer', 'rear spars', etc.).
%   stringer_index: Integer specifying the **current stringer index**.
%   geometria: Structure containing **wing geometry parameters**.
%   datosEstructural: Structure containing **structural properties**.
%
% Outputs:
%   combined_nodes: Updated table containing the new inserted node.
%   Inserted_node: The new node added to the structure.

    %% 📝 STEP 1: EXTRACT GEOMETRICAL PARAMETERS
    % 🔹 Extract **geometrical properties** from input structures.
    alfa_larguero_posterior_radianes = geometria.alfa_larguero_posterior_radianes;  % Rear spar angle (rad)
    pendiente_perpendicular_larguero_posterior = geometria.pendiente_perpendicular_larguero_posterior;  % Perpendicular slope to rear spar
    distancia_entre_larguerillo = datosEstructural.distancia_entre_larguerillo;  % Spacing between stringers

    %% 🔍 STEP 2: IDENTIFY END POINT NEAR FRONT SPAR
    % Locate the **stringer endpoint** closest to the **front spar**.
    end_point = combined_nodes(combined_nodes.stringer_index == stringer_index + 1 & ...
                               combined_nodes.rib_index == -2, :);

    % 🚨 If no valid end point is found, display a warning and exit.
    if isempty(end_point)
        warning('No end point found for stringer index %d near the front spar.', stringer_index + 1);
        Inserted_node = [];  % Return empty result
        return;
    end

    %% 🔄 STEP 3: COMPUTE PERPENDICULAR NODE POSITION
    % The **new node** is positioned **perpendicular** to the **front spar** 
    % using the extracted geometrical parameters.

    % 🔹 Compute the vertical spacing adjusted for the rear spar angle
    distancia_entre_larguerillo_vertical = distancia_entre_larguerillo / cos(alfa_larguero_posterior_radianes);

    % 🔹 Compute **perpendicular offsets** (Δx, Δy)
    delta_x = distancia_entre_larguerillo_vertical * cos(alfa_larguero_posterior_radianes) / ...
              sqrt(1 + pendiente_perpendicular_larguero_posterior^2);
    delta_y = pendiente_perpendicular_larguero_posterior * delta_x;

    % 🔹 Compute the **new node coordinates**:
    x_new = end_point.x - delta_x;  % Move left along perpendicular
    y_new = end_point.y - delta_y;  % Move down along perpendicular

    %% ➕ STEP 4: INSERT NEW NODE INTO COMBINED NODES
    % 🔹 Create a new table entry for the **inserted node**.
    %    - Assigns an **arbitrarily high rib index (2e5)** to indicate special status.
    %    - Categorized as a **"stringer"** node.
    Inserted_node = table(1, x_new, y_new, 2e5, stringer_index, "stringer", ...
        'VariableNames', {'local_id', 'x', 'y', 'rib_index', 'stringer_index', 'tag'});

    % 🔹 Add the new node to the combined structure.
    combined_nodes = add_nodes_to_combined_nodes(combined_nodes, Inserted_node);

    % ✅ Success Message (Optional)
    % disp('✅ Perpendicular node successfully added to front spar.');

end


%% ========================================================================
% 📌 FUNCTION DOCUMENTATION: ADD_PERPENDICULAR_NODE_TO_FRONT_SPAR
% ========================================================================
%
% 🛠️ **Function Overview**
% This function **adds a new node** that is **perpendicular to the front spar** 
% at the **end of a stringer**, ensuring proper structural connectivity.
%
% 🔍 **Why is this function important?**
% - **Structural Connectivity**: Ensures correct **stringer-to-front-spar** connection.
% - **Mesh Consistency**: Prevents errors in **irregular regions** by enforcing **perpendicularity**.
% - **Automatic Node Placement**: Computes **new node coordinates** dynamically.
%
% 📂 **Key Applications**
% - Used in **irregular regions** where stringers meet the **front spar**.
% - Ensures **correct positioning** of elements in **Finite Element Analysis (FEA)**.
% - Improves **structural accuracy** in wing meshing.
%
% ========================================================================
% 🏗️ FUNCTION WORKFLOW:
%
% 1️⃣ **Identify the End Point Near the Front Spar**
%     - Searches for a **stringer endpoint** close to the **front spar**.
%
% 2️⃣ **Compute the Perpendicular Offset**
%     - Uses **slope equations** to determine the **new node position**.
%
% 3️⃣ **Insert the New Node**
%     - Updates the `combined_nodes` table with the **newly created node**.
%
% ========================================================================
% 🔹 **OUTPUT STRUCTURE**
%
% | local_id | x      | y      | rib_index | stringer_index | tag      |
% |----------|--------|--------|-----------|----------------|----------|
% | 105      | 14.32  | 3.89   | 200000    | 7              | stringer |
%
% ========================================================================
