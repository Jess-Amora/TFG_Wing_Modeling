function [costillas, costilla_medios, load_data, num_costillas, num_costillas_triangulo, costilla_costilla_medio] = ...
         generateCostillas(geom, datosEstructural, cargas, avion)
    % ===========================================================
    % 📌 Function: generateCostillas
    % ===========================================================
    % Computes the rib (costilla) geometry and aerodynamic load distribution.
    %
    % This function determines the **rib intersections**, **midpoints for aerodynamic loads**,
    % and **rib spacing** based on aircraft geometry (`geom`) and structural parameters (`datosEstructural`).
    %
    % Inputs:
    % - geom: Structure containing wing geometry information.
    %     - `Lf`  → Half fuselage length (m)
    %     - `Lw`  → Semi-span of the wing excluding fuselage (m)
    %     - `c1`  → Root chord length (m)
    %     - `c2`  → Tip chord length (m)
    %     - `linea_larg_posterior`  → Rear spar line coordinates
    %     - `linea_larg_anterior`   → Front spar line coordinates
    %     - `pendiente_larg_anterior` → Slope of the front spar
    %     - `alfa_larg_posterior`  → Angle of the rear spar (rad)
    %     - `const_larg_anterior`  → Intercept of the front spar line
    %     - `pendiente_perp`  → Perpendicular slope to rear spar
    % - datosEstructural: Structure containing wing structural parameters.
    %     - `distancia_entre_costillas` → Spacing between ribs (m)
    %     - `n`  → Load factor, typically 2.5 for commercial aircraft
    % - cargas: Structure containing aerodynamic load distribution.
    %     - `schrenk` → Schrenk’s load distribution along the span
    % - avion: Structure containing general aircraft properties.
    %     - `MTOW` → Maximum Take-Off Weight (kg)
    %     - `geometria.y_global_punta_ala_borde_ataque` → Y-coordinate of the wing tip (m)
    %
    % Outputs:
    % - `costillas` → Array (`num_costillas x 2 x numero_points`) storing rib coordinates.
    % - `costilla_medios` → Array (`(num_costillas-1) x 2`) of rib midpoints for aerodynamic loads.
    % - `load_data` → Aerodynamic load per rib midpoint (N/m).
    % - `num_costillas` → Total number of ribs.
    % - `num_costillas_triangulo` → Number of ribs in the triangular root section.
    % - `costilla_costilla_medio` → Alternating endpoints and midpoints between ribs.
    % ===========================================================

    %% Extract Geometry Parameters from `geom`
    Lf = geom.Lf;  % Half fuselage length (m)
    Lw = geom.Lw;  % Semi-span of the wing excluding fuselage (m)
    c1 = geom.c1;  % Root chord length (m)
    c2 = geom.c2;  % Tip chord length (m)
    numero_points = geom.numero_points; % Number of discretization points for interpolation
    linea_larg_posterior = geom.linea_larg_posterior; % Rear spar line (y-coordinates)
    linea_larg_anterior = geom.linea_larg_anterior; % Front spar line (y-coordinates)
    pendiente_larg_anterior = geom.pendiente_larg_anterior; % Slope of front spar
    alfa_larg_posterior = geom.alfa_larg_posterior; % Angle of rear spar (radians)
    const_larg_anterior = geom.const_larg_anterior; % Y-intercept of front spar

    %% Extract Structural Parameters from `datosEstructural`
    distancia_entre_costillas = datosEstructural.distancia_entre_costillas; % Rib spacing (m)

    %% Compute Length of the Posterior Stringer
    % This estimates the total spanwise length of the rear spar.
    x_start = Lf;
    y_start = c1 * geom.Dist_larg_posterior;
    x_end = Lf + Lw;
    y_end = avion.geometria.y_global_punta_ala_borde_ataque + c2 * geom.Dist_larg_posterior;
    longitud_posterior = norm([x_end - x_start, y_end - y_start]); % Total posterior spar length (m)

    %% Determine Number of Ribs (`num_costillas`)
    num_costillas = floor(longitud_posterior / distancia_entre_costillas);

    %% Preallocate Rib Storage (`costillas`)
    % Each rib is stored as a 2D array: [x-coordinates, y-coordinates]
    costillas = zeros(num_costillas, 2, numero_points);

    %% Compute Rib Positions along the Posterior Stringer
    % The ribs are placed along the rear spar, spaced by `distancia_entre_costillas`
    x_cost_post = Lf + (0:(num_costillas-1))' * distancia_entre_costillas * cos(alfa_larg_posterior);
    y_cost_post = interp1(geom.x_local_ala, linea_larg_posterior, x_cost_post, 'spline');

    %% Compute Intersections with the Anterior Stringer
    m_perp = geom.pendiente_perp; % Perpendicular slope to rear spar
    b_cost = y_cost_post - m_perp * x_cost_post; % Intercept of each rib

    % Find intersection points with the front spar
    x_intersections = (const_larg_anterior - b_cost) ./ (m_perp - pendiente_larg_anterior);
    y_intersections = pendiente_larg_anterior * x_intersections + const_larg_anterior;

    %% Construct Ribs from Rear to Front Spar
    for i = 1:num_costillas
        costillas(i,1,:) = linspace(x_cost_post(i), x_intersections(i), numero_points);
        costillas(i,2,:) = linspace(y_cost_post(i), y_intersections(i), numero_points);
    end

    %% Compute Rib Midpoints (`costilla_medios`)
    % Midpoints are used to apply aerodynamic loads.
    costilla_medios = zeros(num_costillas-1, 2);
    for i = 1:(num_costillas-1)
        costilla_medios(i,:) = ([x_intersections(i), y_intersections(i)] + [x_intersections(i+1), y_intersections(i+1)]) / 2;
    end

    %% Compute Aerodynamic Load at Each Rib Midpoint (`load_data`)
    load_data = zeros(num_costillas-1, 1);
    for i = 1:(num_costillas-1)
        load_data(i) = interp1(geom.x_local_ala, cargas.schrenk, costilla_medios(i,1), 'spline');
    end

    % Scale Load Using Load Factor (`n`) and MTOW
    n_val = datosEstructural.n;
    MTOW = avion.MTOW;
    load_data = load_data * n_val * MTOW * 2 / (Lw^2); % Load per rib midpoint (N/m)

    %% Compute Number of Ribs in the Root Triangular Section (`num_costillas_triangulo`)
    num_costillas_triangulo = max(0, floor(num_costillas * 0.3));

    %% Construct Costilla-Costilla Midpoints for FEA (`costilla_costilla_medio`)
    costilla_costilla_medio = zeros(num_costillas*2 - 1, 4);
    idx = 1;
    for i = 1:(num_costillas-1)
        costilla_costilla_medio(idx,:) = [x_cost_post(i), y_cost_post(i), x_intersections(i), y_intersections(i)];
        idx = idx + 1;
        costilla_costilla_medio(idx,:) = (costilla_costilla_medio(idx-1,:) + costilla_costilla_medio(idx-1,:)) / 2;
        idx = idx + 1;
    end
end

%% ================================================
% 📌 **Detailed Explanation of `generateCostillas`**
% ================================================
%
% **Purpose:**
% Computes **rib positions, aerodynamic loads, and FEA geometry**.
%
% **Workflow:**
% 1️⃣ **Calculate rib locations along the rear spar**  
% 2️⃣ **Find rib intersections with the front spar**  
% 3️⃣ **Compute midpoints for aerodynamic load interpolation**  
% 4️⃣ **Scale loads using Schrenk’s method**  
% 5️⃣ **Store rib-endpoint relationships for FEA meshing**  
%
% **Future Improvements:**
% - Validate interpolations against FEM solvers.
% - Include variable rib spacing for optimization.
%
%% ================================================
% 📌 **Detailed Explanation of Output Variables in `generateCostillas`**
% ================================================

% **1️⃣ costillas (`num_costillas x 2 x numero_points`)**
% ---------------------------------------------------------
% This variable stores the **rib (costilla) coordinates**.
% Each rib is represented as a **2D curve** extending from the **rear spar**
% to the **front spar**.
%
% **Structure:**
% - `costillas(i,1,:)` → X-coordinates of the i-th rib.
% - `costillas(i,2,:)` → Y-coordinates of the i-th rib.
% - `i` ranges from `1:num_costillas` (total number of ribs).
% - Each rib is discretized into `numero_points` along its length.
%
% **Purpose:**
% - Used for **finite element meshing**.
% - Defines the **skeleton of the wing structure**.

% **2️⃣ costilla_medios (`(num_costillas-1) x 2`)**
% ---------------------------------------------------------
% This variable stores the **midpoints between adjacent ribs**.
% These points are important because **aerodynamic loads** are applied at 
% **rib midpoints** rather than at the ribs themselves.
%
% **Structure:**
% - `costilla_medios(i,1)` → X-coordinate of the midpoint between rib `i` and `i+1`.
% - `costilla_medios(i,2)` → Y-coordinate of the midpoint between rib `i` and `i+1`.
% - `i` ranges from `1:num_costillas-1` (midpoints exist between adjacent ribs).
%
% **Purpose:**
% - Used for **aerodynamic load interpolation**.
% - Helps in determining **load distribution across the wing**.

% **3️⃣ load_data (`(num_costillas-1) x 1`)**
% ---------------------------------------------------------
% This variable stores the **aerodynamic force per unit span** (N/m)
% at each rib midpoint.
%
% **Structure:**
% - `load_data(i)` → Aerodynamic load (N/m) at midpoint `i`.
% - `i` ranges from `1:num_costillas-1` (since loads are applied at midpoints).
%
% **Computation:**
% - The function **interpolates the aerodynamic load (`cargas.schrenk`)** at each midpoint.
% - The total aerodynamic force is then scaled using:
%   ```
%   load_data = load_data * n * MTOW * 2 / (Lw^2);
%   ```
%   where `n` is the **load factor** and `MTOW` is the **aircraft weight**.
%
% **Purpose:**
% - Essential for **structural analysis** and **finite element modeling**.
% - Determines the **bending moment distribution along the wing**.

% **4️⃣ num_costillas_triangulo (scalar)**
% ---------------------------------------------------------
% This variable defines the **number of ribs in the triangular root section** 
% near the wing-fuselage junction.
%
% **Computation:**
% - It is defined as:
%   ```
%   num_costillas_triangulo = max(0, floor(num_costillas * 0.3));
%   ```
% - This assumes that **30% of the ribs** are located in the triangular region.
%
% **Purpose:**
% - Helps in **defining the internal structure near the wing root**.
% - Used for **FEA mesh refinement in the root region**.

% **5️⃣ costilla_costilla_medio (`(2*num_costillas - 1) x 4`)**
% ---------------------------------------------------------
% This variable **alternates between rib endpoints and their midpoints** to 
% help create a **structured connection between ribs** for FEA meshing.
%
% **Structure:**
% - `costilla_costilla_medio(i,1)` → X-coordinate of the start of rib segment `i`.
% - `costilla_costilla_medio(i,2)` → Y-coordinate of the start of rib segment `i`.
% - `costilla_costilla_medio(i,3)` → X-coordinate of the end of rib segment `i`.
% - `costilla_costilla_medio(i,4)` → Y-coordinate of the end of rib segment `i`.
%
% **Computation:**
% - Every **odd row** contains the endpoints of a rib.
% - Every **even row** contains the midpoint of a rib segment.
%
% **Purpose:**
% - Used for **defining elements in the finite element model**.
% - Helps in **mesh connectivity between ribs and spars**.
%
% ================================================

