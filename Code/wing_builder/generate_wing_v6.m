function [results] = generate_wing(avion, datosEstructural, cargas, databasePath)
    % ===========================================================
    % 📌 Function: generate_wing
    % ===========================================================
    % Generates the **Finite Element Analysis (FEA) model** for the wing.
    %
    % This function:
    % - Computes the **structural geometry** based on aircraft parameters.
    % - Generates **ribs (`costillas`)** and computes aerodynamic loads at rib midpoints.
    % - Creates a **structural mesh** defining stringer and spar placements.
    % - Computes **aerodynamic load distribution** and integrates it along the span.
    %
    % Inputs:
    % - avion: Structure containing **aircraft geometry**.
    %     - `geometria.Lf`  → Half fuselage length (m)
    %     - `geometria.Lw`  → Semi-span of the wing excluding fuselage (m)
    %     - `geometria.c1`  → Root chord length (m)
    %     - `geometria.c2`  → Tip chord length (m)
    %     - `geometria.flecha_radian` → Wing sweep angle (radians)
    %     - `coordenadas.x_local_ala` → Local x-coordinates along the span
    % - datosEstructural: Structure containing **wing structural parameters**.
    %     - `distancia_larguero_anterior_cuerda_porcentaje` → Front spar % of chord
    %     - `distancia_larguero_posterior_cuerda_porcentaje` → Rear spar % of chord
    %     - `distancia_centro_aerodinamico` → Aerodynamic center position
    %     - `distancia_eje_de_referencia_estructural_cuerda` → Structural reference axis
    %     - `numero_de_puntos_en_las_lineas` → Number of discretization points
    %     - `distancia_entre_costillas` → Spacing between ribs (m)
    %     - `distancia_entre_larguerillo` → Spacing between stringers (m)
    %     - `n` → Load factor, typically 2.5 for commercial aircraft
    % - cargas: Structure containing **aerodynamic load distribution**.
    %     - `schrenk` → Schrenk’s load distribution along the span
    % - databasePath: Path to the database file (used for saving results).
    %
    % Outputs:
    % - `results`: Structure containing the generated wing model.
    %     - `.costillas` → Rib coordinates (`num_costillas x 2 x num_points`).
    %     - `.numero_costillas` → Total number of ribs.
    %     - `.numero_costillas_triangulo` → Number of ribs in the triangular root.
    %     - `.cociente_L_W_inicial` → Integrated aerodynamic load coefficient.
    %     - `.costilla_costilla_medio` → Matrix of endpoints and midpoints between ribs.
    %     - `.larguerillos` → Mesh nodes defining the **stringers**.
    %     - `.x_l, .y_l, .l` → Continuous aerodynamic load distribution.
    %     - `.x_L, .y_L, .L` → Integration points for total load.
    %     - `.coord_aerodinamica_costillas_punto_medio` → Rib intersection midpoints.
    %     - `.geometria` → Structure with computed **structural lines and geometry**.
    %     - `.mesh` → Structure with **wing mesh nodes and connectivity**.
    % ===========================================================

    %% 1️⃣ Compute Structural Geometry
    % Computes key reference lines, spar positions, and chordwise distributions.
    geom = computeStructuralGeometry(avion, datosEstructural);
    
    %% 2️⃣ Generate Costillas (Ribs) and Compute Rib Midpoints & Loads
    % Determines rib coordinates and aerodynamic loading locations.
    [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
        generateCostillas(geom, datosEstructural, cargas, avion);
    
    %% 3️⃣ Generate Wing Mesh and Node Placement
    % Constructs the finite element **structural mesh** including **stringer nodes**.
    mesh = generateWingMesh(geom, costillas, datosEstructural, avion);
    
    %% 4️⃣ Compute Continuous Load Distribution (Integrate aerodynamic load)
    % Computes **aerodynamic loading function** along the wing span.
    [x_l, y_l, l, x_L, y_L, L, cociente_L_W_inicial] = ...
        computeLoadDistribution(geom, costilla_medios, cargas, avion, num_costillas, num_costillas_triangulo, datosEstructural);
    
    %% Assemble Results Structure
    % Stores all computed parameters in `results` for **FEA processing**.
    results = struct();
    results.costillas = costillas;
    results.numero_costillas = num_costillas;
    results.numero_costillas_triangulo = num_costillas_triangulo;
    results.cociente_L_W_inicial = cociente_L_W_inicial;
    results.costilla_costilla_medio = costilla_costilla_medio;
    results.larguerillos = mesh.larguerillos;
    results.x_l = x_l;
    results.y_l = y_l;
    results.l = l;
    results.x_L = x_L;
    results.y_L = y_L;
    results.L = L;
    results.coord_aerodinamica_costillas_punto_medio = costilla_medios;
    results.coord_aerodinamico_costillas = []; % (Optional: Add if computed in future)
    results.geometria = geom;
    results.mesh = mesh;
    
    % (Optional) Save results to the database or use for visualization.
    % save(databasePath, 'results');
    
    disp('✅ Wing model generation complete.');
end

%% ================================================
% 📌 **Detailed Explanation of Output Variables in `generate_wing`**
% ================================================

% **1️⃣ results.costillas (`num_costillas x 2 x num_points`)**
% ---------------------------------------------------------
% - Stores the **rib coordinates** as 2D sections spanning from **posterior spar to anterior spar**.
% - Used in **structural meshing** and **aerodynamic load application**.

% **2️⃣ results.numero_costillas (scalar)**
% ---------------------------------------------------------
% - Defines the **total number of ribs** in the wing.
% - Computed based on the **rib spacing (`distancia_entre_costillas`)**.

% **3️⃣ results.numero_costillas_triangulo (scalar)**
% ---------------------------------------------------------
% - Number of ribs in the **triangular root section**.
% - Helps define the **internal structure near the fuselage**.

% **4️⃣ results.cociente_L_W_inicial (scalar)**
% ---------------------------------------------------------
% - Represents the **ratio of aerodynamic load to MTOW** (dimensionless).
% - Useful for **comparing different wing designs**.

% **5️⃣ results.costilla_costilla_medio (`(2*num_costillas - 1) x 4`)**
% ---------------------------------------------------------
% - Alternates between **rib endpoints and midpoints**.
% - Used in **FEA meshing for connectivity between ribs**.

% **6️⃣ results.larguerillos (`num_larguerillos_total x 2 x num_costillas`)**
% ---------------------------------------------------------
% - Contains the **stringer node coordinates**.
% - Contributes to **structural stiffness** and **aerodynamic panel meshing**.

% **7️⃣ results.x_l, y_l, l (`num_costillas-1 x 1`)**
% ---------------------------------------------------------
% - `x_l, y_l`: Load application points (rib midpoints).
% - `l`: Aerodynamic force per unit span (N/m).

% **8️⃣ results.x_L, y_L, L (`num_costillas-2 x 1`)**
% ---------------------------------------------------------
% - `x_L, y_L`: Integration points for total load calculation.
% - `L`: Integrated aerodynamic force (N).

% **9️⃣ results.geometria (struct)**
% ---------------------------------------------------------
% - Stores computed **structural lines and geometry**.

% **🔟 results.mesh (struct)**
% ---------------------------------------------------------
% - Contains **mesh nodes, stringers, and connectivity**.

% ================================================
% 📌 **Future Improvements**
% ================================================
% - Extend support for **multiple wing configurations**.
% - Implement **error handling for non-physical values**.
% - Improve **load validation with CFD/FEM simulations**.
%
% ================================================
