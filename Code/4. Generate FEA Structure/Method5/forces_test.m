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
tolerance = 1e-6;

y_global_punta_ala_borde_ataque = avion.geometria.y_global_punta_ala_borde_ataque;

combined_nodes_3D = generate_3D_nodes(combined_nodes, [], ...
    avion.perfil.airfoil, Lf, Lw, y_global_punta_ala_borde_ataque, c1, c2, false);

[nodes,combined_nodes_3D_processed] = process_nodes(combined_nodes_3D);

posterior_points = ala.mesh.nodos_posterior';
anterior_points = ala.mesh.nodos_anterior';
posterior_points_x = posterior_points(:,1);
posterior_points_y = posterior_points(:,2);
anterior_points_x = anterior_points(:,1);
anterior_points_y = anterior_points(:,2);

posterior_points_x_weight = posterior_points_x(1:2:end);
posterior_points_y_weight = posterior_points_y(1:2:end);
anterior_points_x_weight = anterior_points_x(1:2:end);
anterior_points_y_weight = anterior_points_y(1:2:end);

V_mass_wing_n1 = avion.weight_n1.V_mass_wing;
V_mass_wing_n_lim = avion.weight_n_lim.V_mass_wing;
V_mass_wing_n_ult = avion.weight_n_ult.V_mass_wing;

V_mass_comb_n1 = avion.weight_n1.V_mass_comb;
V_mass_comb_n_lim = avion.weight_n_lim.V_mass_comb;
V_mass_comb_n_ult = avion.weight_n_ult.V_mass_comb;

%% Fuerzas másicas
weight_wing_n1 = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_wing_n1.rear'; V_mass_wing_n1.front']], combined_nodes_3D_processed, tolerance);
weight_wing_n_lim = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_wing_n_lim.rear'; V_mass_wing_n_lim.front']], combined_nodes_3D_processed, tolerance);
weight_wing_n_ult = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_wing_n_ult.rear'; V_mass_wing_n_ult.front']], combined_nodes_3D_processed, tolerance);


export_forces_to_csv(fullfile(avion.folder.data,"\weight_wing_n1.csv"), [weight_wing_n1] );
export_forces_to_csv(fullfile(avion.folder.data,"\weight_wing_n_lim.csv"), [weight_wing_n_lim] );
export_forces_to_csv(fullfile(avion.folder.data,"\weight_wing_n_ult.csv"), [weight_wing_n_ult] );

weight_comb_n1 = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_comb_n1.rear'; V_mass_comb_n1.front']], combined_nodes_3D_processed, tolerance);
weight_comb_n_lim = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_comb_n_lim.rear'; V_mass_comb_n_lim.front']], combined_nodes_3D_processed, tolerance);
weight_comb_n_ult = generate_input_forces_table([[posterior_points_x_weight; anterior_points_x_weight],[posterior_points_y_weight;anterior_points_y_weight], ...
                                        -1.*[V_mass_comb_n_ult.rear'; V_mass_comb_n_ult.front']], combined_nodes_3D_processed, tolerance);


export_forces_to_csv(fullfile(avion.folder.data,"\weight_comb_n1.csv"), [weight_comb_n1] );
export_forces_to_csv(fullfile(avion.folder.data,"\weight_comb_n_lim.csv"), [weight_comb_n_lim] );
export_forces_to_csv(fullfile(avion.folder.data,"\weight_comb_n_ult.csv"), [weight_comb_n_ult] );
%% Fuerza aerodinámica
posterior_points_x = posterior_points_x(3:2:end-1);
anterior_points_x = anterior_points_x(3:2:end-1);
posterior_points_y = posterior_points_y(3:2:end-1);
anterior_points_y = anterior_points_y(3:2:end-1);

V_n1 = avion.forces_n1.V;
V_n_lim = avion.forces_n_lim.V;
V_n_ult = avion.forces_n_ult.V;


forces_n1 = generate_input_forces_table([[posterior_points_x; anterior_points_x],[posterior_points_y;anterior_points_y], ...
                                        [V_n1.rear'; V_n1.front']], combined_nodes_3D_processed, tolerance);
forces_n_lim = generate_input_forces_table([[posterior_points_x; anterior_points_x],[posterior_points_y;anterior_points_y], ...
                                        [V_n_lim.rear'; V_n_lim.front']], combined_nodes_3D_processed, tolerance);
forces_n_ult = generate_input_forces_table([[posterior_points_x; anterior_points_x],[posterior_points_y;anterior_points_y], ...
                                        [V_n_ult.rear'; V_n_ult.front']], combined_nodes_3D_processed, tolerance);


export_forces_to_csv(fullfile(avion.folder.data,"\forces_n1.csv"), [forces_n1] );
export_forces_to_csv(fullfile(avion.folder.data,"\forces_n_lim.csv"), [forces_n_lim] );
export_forces_to_csv(fullfile(avion.folder.data,"\forces_n_ult.csv"), [forces_n_ult] );
