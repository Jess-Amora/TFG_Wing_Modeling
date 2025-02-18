function results = calculate_final_forces_v2(ala, avion, cargas)
    % CALCULATE_FINAL_FORCES Computes the final forces applied to the wing 
    % considering aerodynamic and mass forces, following the TFG guide.
    %
    % Inputs:
    %   - ala: Struct containing wing geometry and rib locations.
    %   - avion: Struct with aircraft properties (MTOW, n, etc.).
    %   - cargas: Struct with aerodynamic load distribution.
    %
    % Outputs:
    %   - results: Struct containing final aerodynamic and mass forces.

%% 📌 Load Inputs
MTOW = avion.MTOW;
n = avion.datosEstructural.n;
Lw = avion.geometria.Lw;
numero_costillas = ala.numero_costillas;
pendiente_perpendicular_larguero_posterior = ala.geometria.pendiente_perpendicular_larguero_posterior;

x_local_ala = avion.coordenadas.x_local_ala;
x_l = ala.x_l;
y_l = ala.y_l;

coord_aerodinamica_costillas_punto_medio = ala.coord_aerodinamica_costillas_punto_medio;

schrenk = cargas.schrenk;

% ✅ Schrenk’s Interpolation
l = spline(x_local_ala, schrenk, coord_aerodinamica_costillas_punto_medio);  
l = l * n * MTOW * 2 / Lw^2;  % Scale by load factor and weight

%% ✨ **Discretization of Aerodynamic Forces**
% We exclude the first and last coordinate (see guide)
size_L = length(l) - 2;
x_L = coord_aerodinamica_costillas_punto_medio(2:end-1);
y_L = zeros(size(x_L));

L = zeros(size_L, 1);
for i = 2:numel(x_L)-1
    L(i-1) = (1/6) * (x_L(i+1) - x_L(i)) * (2*l(i) + l(i+1)) ...
           + (1/6) * (x_L(i) - x_L(i-1)) * (l(i) + 2*l(i-1));
end

y_intercept = y_l - pendiente_perpendicular_larguero_posterior * x_l;
coord_interseccion_paralela_costillas_pasa_por_A = zeros(size(y_intercept,1),2,3);
% Dimension: [number of ribs] x (X,Y) x (anterior spar, posterior spar, structural axis)

%% ✅ **Compute Weight Forces**
peso_ala = 0.1 * MTOW;  % Estimated from guide
peso_combustible = 0.2 * MTOW;
W_ala = peso_ala * (x_L / max(x_L)).^3; % Distributed by chord^3
W_comb = peso_combustible * (x_L / max(x_L)).^3;

%% 🔹 **Discretization of Forces at Rib Intersections**
h_A_aero = zeros(size_L, 1);
h_R_aero = zeros(size_L, 1);
l1_A = zeros(size_L, 1);
l2_A = zeros(size_L, 1);
l1_R = zeros(size_L, 1);
l2_R = zeros(size_L, 1);

P_A_aero = zeros(size_L, 1);
P_R_aero = zeros(size_L, 1);
R1_A_aero = zeros(size_L, 1);
R2_A_aero = zeros(size_L, 1);
R1_R_aero = zeros(size_L, 1);
R2_R_aero = zeros(size_L, 1);
V = struct();

for i = 1:size_L
    h_A_aero(i) = norm([x_L(i) y_L(i)] - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 1));
    h_R_aero(i) = norm([x_L(i) y_L(i)] - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 2));

    l1_A(i) = norm(ala.costillas(i+1, :, end) - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 1));
    l2_A(i) = norm(ala.costillas(i+2, :, end) - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 1));
    l1_R(i) = norm(ala.costillas(i+1, :, 1) - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 2));
    l2_R(i) = norm(ala.costillas(i+2, :, 1) - coord_interseccion_paralela_costillas_pasa_por_A(i+1, :, 2));

    P_A_aero(i) = L(i) * h_R_aero(i) / (h_A_aero(i) + h_R_aero(i));
    P_R_aero(i) = L(i) * h_A_aero(i) / (h_A_aero(i) + h_R_aero(i));
    
    R1_A_aero(i) = P_A_aero(i) * l2_A(i) / (l1_A(i) + l2_A(i));
    R2_A_aero(i) = P_A_aero(i) * l1_A(i) / (l1_A(i) + l2_A(i));
    R1_R_aero(i) = P_R_aero(i) * l2_R(i) / (l1_R(i) + l2_R(i));
    R2_R_aero(i) = P_R_aero(i) * l1_R(i) / (l1_R(i) + l2_R(i));

end

V.rear(1) = R1_R_aero(1);
V.front(1) = R1_A_aero(1);
V.rear(size_L+1) = R2_R_aero(end);
V.front(size_L+1) = R2_A_aero(end);

for i = 2:size_L
    
    V.rear(i) = R1_R_aero(i) + R2_R_aero(i-1);
    V.front(i) = R1_A_aero(i) + R2_A_aero(i-1);

end




%% 🔹 **Verify Load Summation Consistency**
total_aero_force = sum(V);
total_mass_force = sum(W_ala + W_comb);
total_lift_required = n * MTOW / 2;

error_check = abs(total_aero_force - total_lift_required);
if error_check > 1e-3
    warning('❌ Load imbalance detected! Adjustments may be needed.');
else
    disp('✅ Load distribution verified successfully.');
end

%% ✨ **Compute Rib–Spar Intersection Coordinates (R_i)**
% Since the aerodynamic forces are applied only at the internal ribs,
% we restrict R_i to the same ribs (from rib 2 to rib end-1).
R_i.anterior = squeeze(ala.costillas(2:end-1, :, end));
R_i.posterior = squeeze(ala.costillas(2:end-1, :, 1));
% The structural (eje) axis is taken as 40% of the distance from the anterior spar.
R_i.eje = R_i.anterior + 0.4 * (R_i.posterior - R_i.anterior);

%% ✨ **Return Results**
results = struct();
results.L = L;
results.W_ala = W_ala;
results.W_comb = W_comb;
results.P_A_aero = P_A_aero;
results.P_R_aero = P_R_aero;
results.R1_A_aero = R1_A_aero;
results.R2_A_aero = R2_A_aero;
results.R1_R_aero = R1_R_aero;
results.R2_R_aero = R2_R_aero;
results.total_lift_required = total_lift_required;
results.error_check = error_check;
results.R_i = R_i;  % Rib–spar intersection coordinates (for internal ribs only).
results.V = V;


end
