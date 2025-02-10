function [x_l, y_l, l, x_L, y_L, L, cociente_L_W_inicial] = ...
         computeLoadDistribution(geom, costilla_medios, cargas, avion, num_costillas, num_costillas_triangulo, datosEstructural)
    % ===========================================================
    % 📌 Function: computeLoadDistribution
    % ===========================================================
    % Computes the **continuous aerodynamic load distribution** along the wing.
    %
    % This function:
    % - Defines **load application points** using **rib midpoints (`costilla_medios`)**.
    % - Interpolates the **aerodynamic load (`cargas.schrenk`)** at these points.
    % - Computes the **scaled aerodynamic load (`l`)** considering the load factor (`n`).
    % - Uses **numerical integration (trapezoidal rule)** to obtain the **total applied load (`L`)**.
    % - Computes the **load coefficient (`cociente_L_W_inicial`)**, which represents the normalized load distribution.
    %
    % Inputs:
    % - geom: Structure containing wing geometry information.
    %     - `Lw`  → Semi-span of the wing excluding fuselage (m)
    %     - `x_local_ala` → X-coordinates along the wing span
    % - costilla_medios: (`(num_costillas-1) x 2`) Array containing rib midpoints.
    % - cargas: Structure containing aerodynamic load distribution.
    %     - `schrenk` → Schrenk’s load distribution along the span
    % - avion: Structure containing general aircraft properties.
    %     - `MTOW` → Maximum Take-Off Weight (kg)
    % - num_costillas: Total number of ribs.
    % - num_costillas_triangulo: Number of ribs in the triangular root section.
    % - datosEstructural: Structure containing wing structural parameters.
    %     - `n`  → Load factor, typically 2.5 for commercial aircraft
    %
    % Outputs:
    % - `x_l`: X-coordinates of load application points (rib midpoints).
    % - `y_l`: Y-coordinates of load application points (rib midpoints).
    % - `l`: Aerodynamic load per unit span (N/m).
    % - `x_L`: X-coordinates of integration points (for total load).
    % - `y_L`: Y-coordinates of integration points (for total load).
    % - `L`: Integrated aerodynamic load (N) at each section.
    % - `cociente_L_W_inicial`: Load coefficient representing the ratio of aerodynamic load to MTOW.
    % ===========================================================

    %% 1️⃣ Define Load Application Points (Rib Midpoints)
    % The load is applied at the **midpoints of the ribs (`costilla_medios`)**.
    % These points represent the locations where **aerodynamic forces** act.
    x_l = costilla_medios(:, 1); % X-coordinates of midpoints
    y_l = costilla_medios(:, 2); % Y-coordinates of midpoints

    %% 2️⃣ Interpolate the Aerodynamic Load at Each Midpoint
    % The aerodynamic load (`cargas.schrenk`) is **interpolated at each midpoint**.
    % This ensures a **continuous load distribution** rather than discrete values.
    l = interp1(geom.x_local_ala, cargas.schrenk, x_l, 'spline'); % N/m²

    %% 3️⃣ Scale the Load Using Load Factor (`n`) and MTOW
    % The total aerodynamic load is scaled to account for:
    % - **Load factor (`n_val`)**: Accounts for structural loads during flight maneuvers.
    % - **Maximum Take-Off Weight (`MTOW`)**: Ensures correct normalization.
    % - **Wing semi-span (`Lw`)**: Converts per-unit span load into meaningful force values.
    n_val = datosEstructural.n; % Load factor
    MTOW = avion.MTOW; % Maximum Take-Off Weight (kg)
    l = l * n_val * MTOW * 2 / (geom.Lw^2); % Final aerodynamic load (N/m)

    %% 4️⃣ Compute Integrated Load (`L`) Using the Trapezoidal Rule
    % The total **aerodynamic force** is computed via numerical integration:
    % - **Trapezoidal rule** is used to approximate the integral.
    % - Each segment’s force is calculated as `0.5 * (l1 + l2) * dx`.
    L_vec = zeros(length(x_l)-1, 1); % Preallocate storage for integrated load
    for i = 1:length(x_l)-1
        L_vec(i) = 0.5 * (l(i) + l(i+1)) * (x_l(i+1) - x_l(i)); % Trapezoidal rule
    end
    L = L_vec; % Store integrated load (N)

    %% 5️⃣ Define Integration Points (`x_L`, `y_L`)
    % These are the **midpoints of `x_l` and `y_l`**, **excluding the first and last values**.
    % This ensures accurate integration without double-counting boundary points.
    x_L = x_l(2:end-1); % X-coordinates of integration points
    y_L = y_l(2:end-1); % Y-coordinates of integration points

    %% 6️⃣ Compute Load Coefficient (`cociente_L_W_inicial`)
    % This coefficient represents the **ratio of the aerodynamic load to the total aircraft weight**.
    % It is a **dimensionless parameter** that helps in comparing different load distributions.
    cociente_L_W_inicial = 2 * sum(L) / (n_val * MTOW); % Load coefficient (dimensionless)
end

%% ================================================
% 📌 **Detailed Explanation of Output Variables in `computeLoadDistribution`**
% ================================================

% **1️⃣ x_l (`num_costillas-1 x 1`)**
% ---------------------------------------------------------
% This variable contains the **X-coordinates of the load application points**.
% These points represent the **midpoints of the ribs (`costilla_medios`)**.
%
% **Purpose:**
% - Used to define where **aerodynamic forces are applied**.
% - Serves as the basis for **interpolating aerodynamic load (`l`)**.

% **2️⃣ y_l (`num_costillas-1 x 1`)**
% ---------------------------------------------------------
% This variable contains the **Y-coordinates of the load application points**.
%
% **Purpose:**
% - Defines the **vertical distribution of applied forces**.

% **3️⃣ l (`num_costillas-1 x 1`)**
% ---------------------------------------------------------
% This variable contains the **aerodynamic force per unit span (N/m)** at each rib midpoint.
%
% **Computation:**
% - It is interpolated from **Schrenk's aerodynamic load distribution** (`cargas.schrenk`).
% - It is then scaled using **n (`load factor`) and MTOW** to represent actual structural loads.
%
% **Purpose:**
% - Defines the **aerodynamic loading function** for structural analysis.
% - Serves as input for **bending moment and shear force calculations**.

% **4️⃣ x_L (`num_costillas-2 x 1`) & y_L (`num_costillas-2 x 1`)**
% ---------------------------------------------------------
% These variables store the **X and Y coordinates of integration points**.
%
% **Computation:**
% - Defined as **midpoints of `x_l` and `y_l`**, excluding endpoints.
%
% **Purpose:**
% - Used in **numerical integration** to calculate the total applied force.

% **5️⃣ L (`num_costillas-1 x 1`)**
% ---------------------------------------------------------
% This variable contains the **integrated aerodynamic force (N)** at each section.
%
% **Computation:**
% - Computed using the **trapezoidal rule** to integrate **`l(x)`** along the wing span.
%
% **Purpose:**
% - Defines the **total applied aerodynamic force** on each section.

% **6️⃣ cociente_L_W_inicial (scalar)**
% ---------------------------------------------------------
% This is the **load coefficient**, which is a **dimensionless parameter**.
%
% **Computation:**
% - Defined as:
%   ```
%   cociente_L_W_inicial = 2 * sum(L) / (n_val * MTOW);
%   ```
%
% **Purpose:**
% - Normalizes the aerodynamic load.
% - Useful for **comparing different aircraft configurations**.
%
% ================================================
