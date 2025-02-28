% addpath('./5. FEA validation');
addpath('./4. Generate FEA Structure');
addpath('./4. Generate FEA Structure/Method5');
%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
combined_nodes = avion.elements.nodes;
avion = TFG_Amora.aviones.Airbus_A380_Structural_parameters_A350;
ala = avion.ala;

Lf = avion.geometria.Lf;
Lw = avion.geometria.Lw;
c1 = avion.geometria.c1;
c2 = avion.geometria.c2;
b = avion.geometria.b;

y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;

combined_nodes_3D = generate_3D_nodes(combined_nodes, [], ...
    avion.perfil.airfoil, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, false);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);

posterior_points = ala.mesh.nodos_posterior';
posterior_points_x = posterior_points(:,1);
posterior_points_x = posterior_points_x(3:2:end-1);
posterior_points_y = posterior_points(:,2);
posterior_points_y = posterior_points_y(3:2:end-1);
V = avion.forces_n1.V;
input_matrix = [posterior_points_x,posterior_points_y, V.rear'];
tolerance = 1e-6;
forces = generate_input_forces_table(input_matrix, combined_nodes_3D_processed, tolerance)

export_forces_to_csv(fullfile(avion.folder.data,"\forces.csv"), [forces] );
