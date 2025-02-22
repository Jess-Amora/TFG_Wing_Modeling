function geom = computeStructuralGeometry(avion, datosEstructural)
    % ===========================================================
    % 📌 Function: computeStructuralGeometry
    % ===========================================================
    % Computes the key structural lines and parameters for the wing.
    %
    % This function calculates the **chord lines, slopes, intercepts, and
    % other geometric parameters** necessary for the structural analysis 
    % of the wing. It utilizes aircraft geometry (`avion`) and structural 
    % parameters (`datosEstructural`).
    %
    % Inputs:
    % - avion: Structure containing aircraft geometry and coordinates.
    %          Fields used:
    %          - `geometria.Lf` (Half fuselage length)
    %          - `geometria.Lw` (Semi-span of the wing excluding fuselage)
    %          - `geometria.c1` (Root chord length)
    %          - `geometria.c2` (Tip chord length)
    %          - `geometria.y_global_punta_ala_borde_ataque` (y-coord of tip)
    %          - `geometria.flecha_radian` (Sweep angle in radians)
    %          - `coordenadas.x_local_ala` (Local x-coordinates of the wing)
    %
    % - datosEstructural: Structure containing wing structural parameters.
    %          Fields used:
    %          - `distancia_larguero_anterior_cuerda_porcentaje` (Front spar % of chord)
    %          - `distancia_larguero_posterior_cuerda_porcentaje` (Rear spar % of chord)
    %          - `distancia_centro_aerodinamico` (Aerodynamic center position)
    %          - `distancia_eje_de_referencia_estructural_cuerda` (Structural ref. axis)
    %          - `numero_de_puntos_en_las_lineas` (Number of discretization points)
    %
    % Output:
    % - geom: Structure containing computed wing geometry:
    %          - `.linea_larg_anterior`, `.linea_larg_posterior` (Spar lines)
    %          - `.linea_centro` (Aerodynamic center line)
    %          - `.linea_eje` (Reference axis line)
    %          - `.pendiente_*` (Slopes of structural elements)
    %          - `.const_*` (Intercepts of structural lines)
    % ===========================================================

    %% Extract aircraft geometry parameters
    Lf = avion.geometria.Lf; % Half fuselage length
    Lw = avion.geometria.Lw; % Semi-span of the wing excluding fuselage
    c1 = avion.geometria.c1; % Root chord length
    c2 = avion.geometria.c2; % Tip chord length
    y_global = avion.geometria.y_global_punta_ala_borde_ataque; % Tip y-coord
    flecha = avion.geometria.flecha_radian; % Sweep angle (radians)
    
    %% Extract structural parameters from datosEstructural
    Dist_anterior = datosEstructural.distancia_larguero_anterior_cuerda_porcentaje; % Front spar %
    Dist_posterior = datosEstructural.distancia_larguero_posterior_cuerda_porcentaje; % Rear spar %
    distancia_centro = datosEstructural.distancia_centro_aerodinamico; % Aero center %
    distancia_eje = datosEstructural.distancia_eje_de_referencia_estructural_cuerda; % Struct ref. axis %
    numero_points = datosEstructural.numero_de_puntos_en_las_lineas; % Discretization points
    
    %% Extract x-coordinates along the wing
    x_local_ala = avion.coordenadas.x_local_ala; % Local x-coordinates

    %% Compute Structural Lines
    % These define the chord-based placement of key structural elements
    linea_larg_anterior = linspace(c1 * Dist_anterior, y_global + c2 * Dist_anterior, numero_points);
    linea_larg_posterior = linspace(c1 * Dist_posterior, y_global + c2 * Dist_posterior, numero_points);
    linea_centro = linspace(c1 * distancia_centro, c1 * distancia_centro + Lw * sin(flecha), numero_points);
    linea_eje = linspace(c1 * distancia_eje, c2 * distancia_eje + y_global, numero_points);
    
    %% Compute Structural Slopes (Pendiente)
    pendiente_larg_anterior = (linea_larg_anterior(end) - linea_larg_anterior(1)) / Lw;
    pendiente_larg_posterior = (linea_larg_posterior(end) - linea_larg_posterior(1)) / Lw;
    pendiente_eje = (linea_eje(end) - linea_eje(1)) / Lw;

    % Compute perpendicular slope to the rear spar (avoid division by zero)
    tol = 1e-8;
    if abs(pendiente_larg_posterior) < tol
        pendiente_perp = Inf; % Vertical line
    else
        pendiente_perp = -1 / pendiente_larg_posterior; % Perpendicular slope
    end
    alfa_larg_posterior = atan(pendiente_larg_posterior); % Spar angle (radians)
    
    %% Compute Intercepts (Ordenada al origen) at x = Lf
    const_larg_anterior = linea_larg_anterior(1) - pendiente_larg_anterior * Lf;
    const_larg_posterior = linea_larg_posterior(1) - pendiente_larg_posterior * Lf;
    const_eje = linea_eje(1) - pendiente_eje * Lf;

    %% Package into Output Structure
    geom = struct();
    geom.Lf = Lf;
    geom.Lw = Lw;
    geom.c1 = c1;
    geom.c2 = c2;
    geom.flecha = flecha;
    geom.x_local_ala = x_local_ala;
    geom.linea_larg_anterior = linea_larg_anterior;
    geom.linea_larg_posterior = linea_larg_posterior;
    geom.linea_centro = linea_centro;
    geom.linea_eje = linea_eje;
    geom.pendiente_larg_anterior = pendiente_larg_anterior;
    geom.pendiente_larg_posterior = pendiente_larg_posterior;
    geom.pendiente_eje = pendiente_eje;
    geom.pendiente_perp = pendiente_perp;
    geom.alfa_larg_posterior = alfa_larg_posterior;
    geom.const_larg_anterior = const_larg_anterior;
    geom.const_larg_posterior = const_larg_posterior;
    geom.const_eje = const_eje;
    geom.numero_points = numero_points;
    geom.Dist_larg_anterior = Dist_anterior;
    geom.Dist_larg_posterior = Dist_posterior;
end

%% ================================================
% 📌 **Detailed Explanation of `computeStructuralGeometry`**
% ================================================
%
% **Purpose:**
% This function calculates the **chord lines, slopes, intercepts, and 
% reference positions** required to define the **main structural lines** 
% of the wing. These parameters serve as the foundation for **meshing, 
% rib placement, and finite element modeling**.
%
% **Workflow:**
% 1️⃣ **Extract Aircraft Geometry & Structural Percentages**  
% - Reads wing root chord (`c1`), tip chord (`c2`), spanwise distances, and sweep angle.  
% - Reads structural locations based on **percentage of chord**.  
%
% 2️⃣ **Compute Structural Lines**  
% - `linea_larg_anterior` (Front spar line).  
% - `linea_larg_posterior` (Rear spar line).  
% - `linea_centro` (Aerodynamic center line).  
% - `linea_eje` (Structural reference axis).  
%
% 3️⃣ **Compute Structural Slopes & Intercepts**  
% - Slopes (`pendiente_*`) define **spar and reference line angles**.  
% - Perpendicular slope (`pendiente_perp`) ensures proper spar alignment.  
% - Intercepts (`const_*`) allow later **rib intersection calculations**.  
%
% **Future Improvements:**
% - Implement **error handling** for non-physical values (e.g., `c1 < c2`).
% - Allow user-defined **variable discretization density**.
%
% ================================================
