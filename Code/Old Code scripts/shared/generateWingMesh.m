function mesh = generateWingMesh(geom, costillas, datosEstructural, avion)
    % ===========================================================
    % 📌 Function: generateWingMesh
    % ===========================================================
    % Constructs the finite element mesh for the wing by defining node placement.
    %
    % This function:
    % - Extracts **rib nodal coordinates**.
    % - Generates **chordwise node placement** (posterior and anterior spar nodes).
    % - Computes **stringer (larguerillos) nodes** via **linear interpolation**.
    %
    % Inputs:
    % - geom: Structure containing wing geometry information.
    %     - `Lf`  → Half fuselage length (m)
    %     - `Lw`  → Semi-span of the wing excluding fuselage (m)
    %     - `c1`  → Root chord length (m)
    %     - `c2`  → Tip chord length (m)
    % - costillas: Array (`num_costillas x 2 x numero_points`) containing rib node positions.
    % - datosEstructural: Structure containing wing structural parameters.
    %     - `distancia_entre_larguerillo` → Spacing between stringers (m)
    % - avion: Structure containing general aircraft properties.
    %
    % Outputs:
    % - `mesh`: Structure containing:
    %     - `.nodos_posterior` → Posterior spar nodes (`2 x num_costillas`).
    %     - `.nodos_anterior` → Anterior spar nodes (`2 x num_costillas`).
    %     - `.larguerillos` → Stringer nodes (`num_larguerillos_total x 2 x num_costillas`).
    % ===========================================================

    %% Extract Nodal Coordinates from Ribs
    % The posterior spar nodes (rear of the ribs)
    nodos_posterior = squeeze(costillas(:, :, 1))';  % dimensions: 2 x num_costillas
    % The anterior spar nodes (front of the ribs)
    nodos_anterior = squeeze(costillas(:, :, end))'; % dimensions: 2 x num_costillas
    
    % (Optional) Interleaving function could be used to reorder nodes if needed
    % nodos_posterior = interleave_matrices(squeeze(costillas(:,:,1))', []);
    % nodos_anterior = interleave_matrices(squeeze(costillas(:,:,end))', []);
    
    %% Compute the Number of Chordwise Nodes
    num_nodos = size(nodos_posterior, 2); % Number of ribs (costillas)

    %% Estimate the Total Number of Stringers (Larguerillos)
    % The number of stringers is determined based on chord length and predefined spacing.
    chord_length = norm(nodos_anterior(:,1) - nodos_posterior(:,1)); % Length of chord
    num_larguerillos_total = floor(chord_length / datosEstructural.distancia_entre_larguerillo);

    %% Generate Stringers (Larguerillos) via Linear Interpolation
    % Stringers (larguerillos) are additional structural elements running along the chord.
    % These are created between the posterior and anterior nodes.
    larguerillos = zeros(num_larguerillos_total, 2, num_nodos);
    for i = 1:num_larguerillos_total
        t = i / (num_larguerillos_total + 1); % Interpolation parameter
        larguerillos(i, :, :) = (1 - t) * nodos_posterior + t * nodos_anterior;
    end

    %% Assemble Mesh Structure
    mesh = struct();
    mesh.nodos_posterior = nodos_posterior; % Posterior spar nodes
    mesh.nodos_anterior = nodos_anterior;   % Anterior spar nodes
    mesh.larguerillos = larguerillos;       % Stringer nodes
end

%% ================================================
% 📌 **Detailed Explanation of Output Variables in `generateWingMesh`**
% ================================================

% **1️⃣ mesh.nodos_posterior (`2 x num_costillas`)**
% ---------------------------------------------------------
% This variable contains the **posterior spar node positions**, which define
% the **rear edges of the ribs**.
%
% **Structure:**
% - `mesh.nodos_posterior(1, i)` → X-coordinate of rib `i` at the rear spar.
% - `mesh.nodos_posterior(2, i)` → Y-coordinate of rib `i` at the rear spar.
% - `i` ranges from `1:num_costillas` (total number of ribs).
%
% **Purpose:**
% - Defines **rear rib positions** for **finite element analysis (FEA)**.
% - Used to **generate stringers** that run along the wing chord.

% **2️⃣ mesh.nodos_anterior (`2 x num_costillas`)**
% ---------------------------------------------------------
% This variable contains the **anterior spar node positions**, which define
% the **front edges of the ribs**.
%
% **Structure:**
% - `mesh.nodos_anterior(1, i)` → X-coordinate of rib `i` at the front spar.
% - `mesh.nodos_anterior(2, i)` → Y-coordinate of rib `i` at the front spar.
% - `i` ranges from `1:num_costillas` (total number of ribs).
%
% **Purpose:**
% - Defines **front rib positions** for **structural meshing**.
% - Used to create **chordwise structural elements** (like spars and skins).

% **3️⃣ mesh.larguerillos (`num_larguerillos_total x 2 x num_costillas`)**
% ---------------------------------------------------------
% This variable contains **the coordinates of stringer nodes** placed between
% the **posterior and anterior spars** along the chord.
%
% **Structure:**
% - `mesh.larguerillos(j,1,i)` → X-coordinate of stringer `j` at rib `i`.
% - `mesh.larguerillos(j,2,i)` → Y-coordinate of stringer `j` at rib `i`.
% - `j` ranges from `1:num_larguerillos_total` (total number of stringers).
% - `i` ranges from `1:num_costillas` (total number of ribs).
%
% **Computation:**
% - Each stringer position is **linearly interpolated** between `nodos_posterior`
%   and `nodos_anterior` using the interpolation factor:
%   ```
%   t = i / (num_larguerillos_total + 1);
%   larguerillos(i, :, :) = (1 - t) * nodos_posterior + t * nodos_anterior;
%   ```
%
% **Purpose:**
% - Represents **intermediate structural elements** (stringers).
% - Contributes to **structural stiffness** and **aerodynamic panel meshing**.

% ================================================
% 📌 **Overall Function Purpose & Future Improvements**
% ================================================
%
% **Purpose of `generateWingMesh`**
% - Generates **chordwise node placements** for **FEM meshing**.
% - Defines **stringers (larguerillos)**, which are crucial for **structural strength**.
% - Organizes **posterior and anterior spar nodes** for mesh connectivity.
%
% **Future Improvements:**
% - Implement **automatic validation** for `distancia_entre_larguerillo` to prevent
%   cases where `num_larguerillos_total` is too low (leading to under-refined meshes).
% - Add **mesh connectivity definitions** to facilitate **direct FEM export**.
% - Optimize the **stringer distribution method** (currently linear interpolation).
%
% ================================================
