function [horizontal_stringers,vertical_stringers,lines_spars] = create_stringers_v6(combined_nodes_3D)

%% 📝 Initialization 

horizontal_stringers = line_initialize(true);
vertical_stringers = line_initialize(true);

warnings = {};
line_counter = 1;

[~, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, ~, max_ribs_fuselaje] = analyze_stringer_rib_data(combined_nodes_3D);
start_rib = rib_ranges(1,2);

%% Creación de cordón en el larguero posterior en extrados

cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);
cordon_fuselage = [cordon_fuselage(1:end-1,:); cordon_wing(1,:)];

% cordon_posterior = [cordon_fuselage; cordon_wing];

[cordon_posterior_extrados_fuselaje, line_counter] = create_lines_from_stringer_horizontal(cordon_fuselage, -2, "rear spar fuselaje", "extrados", 1);
[cordon_posterior_extrados, line_counter] = create_lines_from_stringer_horizontal(cordon_wing, -2, "rear spar", "extrados", 1);

%% Creación de cordón en el larguero anterior en extrados

cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'extrados',:);
cordon_wing = sortrows(cordon_wing,5);
cordon_wing = [cordon_wing(end,:); cordon_wing(1:end-1,:)];
cordon_fuselage = [cordon_fuselage(1:end-1,:); cordon_wing(1,:)];

% OnlyNode = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == 1e5,:);
% cordon_anterior = [cordon_fuselage(1:end-1,:); OnlyNode; cordon_wing];

[cordon_anterior_extrados_fuselaje, line_counter] = create_lines_from_stringer_horizontal(cordon_fuselage, -1, "front spar fuselaje", "extrados", 1);
[cordon_anterior_extrados, line_counter] = create_lines_from_stringer_horizontal(cordon_wing, -1, "front spar", "extrados", 1);

%% Creación de cordón en el larguero posterior en intrados

cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'intrados',:);
cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);
cordon_fuselage = [cordon_fuselage(1:end-1,:); cordon_wing(1,:)];

% cordon_posterior = [cordon_fuselage; cordon_wing];

[cordon_posterior_intrados_fuselaje, line_counter] = create_lines_from_stringer_horizontal(cordon_fuselage, -2, "rear spar fuselaje", "intrados", 1);
[cordon_posterior_intrados, line_counter] = create_lines_from_stringer_horizontal(cordon_wing, -2, "rear spar", "intrados", 1);

%% Creación de cordón en el larguero anterior en intrados

cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'intrados',:);
cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'intrados',:);
cordon_wing = sortrows(cordon_wing,5);
cordon_wing = [cordon_wing(end,:); cordon_wing(1:end-1,:)];
cordon_fuselage = [cordon_fuselage(1:end-1,:); cordon_wing(1,:)];

% OnlyNode = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == 1e5,:);
% cordon_anterior = [cordon_fuselage(1:end-1,:); OnlyNode; cordon_wing];

[cordon_anterior_intrados_fuselaje, line_counter] = create_lines_from_stringer_horizontal(cordon_fuselage, -1, "front spar fuselaje", "intrados", 1);
[cordon_anterior_intrados, line_counter] = create_lines_from_stringer_horizontal(cordon_wing, -1, "front spar", "intrados", 1);

%% Creación de larguerillos/barras encastre-punta

% Extrados
for index_larguerillo = 1:max_stringer_index

    larguerillo_fuselage = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer fuselaje' & ...
                           combined_nodes_3D.h == 'extrados',:);
    encastre = combined_nodes_3D(combined_nodes_3D.stringer_index==index_larguerillo & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -1,:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -2,:);
    larguerillo_wing = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);
    
     % Include 'inserted' nodes for this stringer index
    inserted_nodes_root = combined_nodes_3D(combined_nodes_3D.tag == 'stringer' & combined_nodes_3D.stringer_index == index_larguerillo & ...
                          combined_nodes_3D.rib_index == 3e5 & combined_nodes_3D.h == 'extrados', :);
    inserted_nodes_front = combined_nodes_3D(combined_nodes_3D.tag == 'stringer' & combined_nodes_3D.stringer_index == index_larguerillo & ...
                           combined_nodes_3D.rib_index == 2e5 & combined_nodes_3D.h == 'extrados', :);
    rib_0 = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & ...
                           combined_nodes_3D.rib_index == 0 & combined_nodes_3D.h == 'extrados', :);

    larguerillo_wing = [larguerillo_wing;Node_front_spar ];
    larguerillo_wing = order_lines_by_coordinates(larguerillo_wing,1.5);
    larguerillo_wing = [encastre; rib_0; larguerillo_wing];

    larguerillo = [larguerillo_fuselage(1:end-1,:); encastre; larguerillo_wing];

    
    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo_wing, index_larguerillo, "stringer", "extrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo_fuselage, index_larguerillo, "stringer fuselaje", "extrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
end

% Intrados
for index_larguerillo = 1:max_stringer_index

    larguerillo_fuselage = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer fuselaje' & ...
                           combined_nodes_3D.h == 'intrados',:);
    encastre = combined_nodes_3D(combined_nodes_3D.stringer_index==index_larguerillo & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == -1,:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == -2,:);
    larguerillo_wing = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);
    
     % Include 'inserted' nodes for this stringer index
    inserted_nodes_root = combined_nodes_3D(combined_nodes_3D.tag == 'stringer' & combined_nodes_3D.stringer_index == index_larguerillo & ...
                          combined_nodes_3D.rib_index == 3e5 & combined_nodes_3D.h == 'intrados', :);
    inserted_nodes_front = combined_nodes_3D(combined_nodes_3D.tag == 'stringer' & combined_nodes_3D.stringer_index == index_larguerillo & ...
                           combined_nodes_3D.rib_index == 2e5 & combined_nodes_3D.h == 'intrados', :);
    rib_0 = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & ...
                           combined_nodes_3D.rib_index == 0 & combined_nodes_3D.h == 'intrados', :);

    larguerillo_wing = [larguerillo_wing;Node_front_spar ];
    larguerillo_wing = order_lines_by_coordinates(larguerillo_wing,1.5);
    larguerillo_wing = [encastre; rib_0; larguerillo_wing];

    larguerillo = [larguerillo_fuselage(1:end-1,:); encastre; larguerillo_wing];

    
    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo_wing, index_larguerillo, "stringer", "intrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo_fuselage, index_larguerillo, "stringer fuselaje", "intrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];

end

%% Creación de las barras horizontales en las costillas
% Bucle para las costillas en el ala 

% Extrados
for index_rib = 0:max_rib_index
    Node_rear_spar = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'rear spars',:);
    Vector_ribs_stringer = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'stringer',:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'front spars',:);
    Vector_ribs = [Node_rear_spar; Vector_ribs_stringer; Node_front_spar];

    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal_ribs(Vector_ribs, index_rib, "ribs", "extrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
    
end

% Intrados
for index_rib = 0:max_rib_index

    Node_rear_spar = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'rear spars',:);
    Vector_ribs_stringer = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'stringer',:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'front spars',:);
    Vector_ribs = [Node_rear_spar; Vector_ribs_stringer; Node_front_spar];

    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal_ribs(Vector_ribs, index_rib, "ribs", "intrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];

end

% Bucle para las costillas en el fuselaje 

% Extrados
for index_rib = 1:max_ribs_fuselaje-1
    Node_rear_spar = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'rear spars fuselaje',:);
    Vector_ribs_stringer = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'stringer fuselaje',:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'front spars fuselaje',:);
    Vector_ribs = [Node_rear_spar; Vector_ribs_stringer; Node_front_spar];

    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal_ribs(Vector_ribs, index_rib, "ribs fuselaje", "extrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
    
end

% Intrados
for index_rib = 1:max_ribs_fuselaje-1

    Node_rear_spar = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'rear spars fuselaje',:);
    Vector_ribs_stringer = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'stringer fuselaje',:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == index_rib & ...
                                    combined_nodes_3D.tag == 'front spars fuselaje',:);
    Vector_ribs = [Node_rear_spar; Vector_ribs_stringer; Node_front_spar];

    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal_ribs(Vector_ribs, index_rib, "ribs fuselaje", "intrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];

end

%% Creación de las barras verticales en las costillas

% Bucle para las costillas en el ala 
for index_rib = 1:2:max_rib_index

    Vector_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                      combined_nodes_3D.h == 'extrados' & ...
                      combined_nodes_3D.tag == 'stringer' & ...
                      combined_nodes_3D.stringer_index >=  rib_ranges_by_ribs(index_rib, 2) & ...
                      combined_nodes_3D.stringer_index <=  rib_ranges_by_ribs(index_rib, 3) ,:);
    Vector_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & ...
                      combined_nodes_3D.h == 'intrados' & ...
                      combined_nodes_3D.tag == 'stringer' & ...
                      combined_nodes_3D.stringer_index >=  rib_ranges_by_ribs(index_rib, 2) & ...
                      combined_nodes_3D.stringer_index <=  rib_ranges_by_ribs(index_rib, 3) ,:);

    % De arriba para abajo el sentido de la barra
    [larguerillo_i, line_counter] = create_lines_from_stringer_vertical(Vector_extrados, Vector_intrados, index_rib, "barra costilla", "vertical", 1);
    vertical_stringers = [vertical_stringers ; larguerillo_i];

end

% Bucle para las costillas en el fuselaje
for index_rib = 1:2:max_ribs_fuselaje-1


    Vector_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.tag == 'stringer fuselaje',:);
    Vector_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.tag == 'stringer fuselaje',:);


    [larguerillo_i, line_counter] = create_lines_from_stringer_vertical(Vector_extrados, Vector_intrados, index_rib, "barra costilla fuselaje", "vertical", 1);
    vertical_stringers = [vertical_stringers ; larguerillo_i];

end

%% Creación de barras verticales en el larguero posterior en ala

barras_larguero_posterior_ala = table([], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

cordon_wing_extrados = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);
cordon_wing_intrados = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);

line_counter = 1;

for index_rib = 1:min(height(cordon_wing_extrados),height(cordon_wing_intrados))

    % cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
    % cordon_fuselage = [cordon_fuselage(1:end-1,:); cordon_wing(1,:)];

    node_1 = cordon_wing_extrados(index_rib,:);
    node_2 = cordon_wing_intrados(index_rib,:);

    [barras_larguero_posterior_ala, line_counter] = create_new_line_vertical(node_1, node_2, -2, node_1.rib_index, node_2.rib_index, "rear spar", "vertical", line_counter, barras_larguero_posterior_ala);

    % barras_larguero_posterior_ala = [barras_larguero_posterior_ala; barras_larguero_posterior_ala_barritas];

end

%% Creación de barras verticales en el larguero anterior en ala

barras_larguero_anterior_ala = table([], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

cordon_wing_extrados = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'extrados',:);
cordon_wing_extrados = order_lines_by_coordinates(cordon_wing_extrados,1.5);

cordon_wing_intrados = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'intrados',:);
cordon_wing_intrados = order_lines_by_coordinates(cordon_wing_intrados,1.5);

line_counter = 1;

for index_rib = 1:min(height(cordon_wing_extrados),height(cordon_wing_intrados))

    node_1 = cordon_wing_extrados(index_rib,:);
    node_2 = cordon_wing_intrados(index_rib,:);

    [barras_larguero_anterior_ala, line_counter] = create_new_line_vertical(node_1, node_2, -1, node_1.rib_index, node_2.rib_index, "front spar", "vertical", line_counter, barras_larguero_anterior_ala);

end

%% Creación de barras verticales en el larguero posterior en fuselaje

barras_larguero_posterior_fuselaje = table([], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

cordon_fuselaje_extrados = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
cordon_fuselaje_extrados = cordon_fuselaje_extrados(1:end-1,:);

cordon_fuselaje_intrados = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'intrados',:);
cordon_fuselaje_intrados = cordon_fuselaje_intrados(1:end-1,:);

line_counter = 1;

for index_rib = 1:min(height(cordon_fuselaje_extrados),height(cordon_fuselaje_intrados))

    node_1 = cordon_fuselaje_extrados(index_rib,:);
    node_2 = cordon_fuselaje_intrados(index_rib,:);

    [barras_larguero_posterior_fuselaje, line_counter] = create_new_line_vertical(node_1, node_2, -2, node_1.rib_index, node_2.rib_index, "rear spar fuselaje", "vertical", line_counter, barras_larguero_posterior_fuselaje);

end

%% Creación de barras verticales en el larguero anterior en fuselaje

barras_larguero_anterior_fuselaje = table([], [], [], [], [], [], [], [], [], ...
        'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                          'length', 'h'});

cordon_fuselaje_extrados = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
cordon_fuselaje_extrados = cordon_fuselaje_extrados(1:end-1,:);

cordon_fuselaje_intrados = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'intrados',:);
cordon_fuselaje_intrados = cordon_fuselaje_intrados(1:end-1,:);

line_counter = 1;

for index_rib = 1:min(height(cordon_fuselaje_extrados),height(cordon_fuselaje_intrados))

    node_1 = cordon_fuselaje_extrados(index_rib,:);
    node_2 = cordon_fuselaje_intrados(index_rib,:);

    [barras_larguero_anterior_fuselaje, line_counter] = create_new_line_vertical(node_1, node_2, -1, node_1.rib_index, node_2.rib_index, "front spar fuselaje", "vertical", line_counter, barras_larguero_anterior_fuselaje);

end

%% Unir los larguerillos horizontales
% cordon = [cordon_posterior_extrados; cordon_posterior_intrados; cordon_anterior_extrados; cordon_anterior_intrados];
% cordon_fuselaje = [cordon_posterior_extrados_fuselaje; cordon_posterior_intrados_fuselaje; cordon_anterior_extrados_fuselaje; cordon_anterior_intrados_fuselaje];
cordon = [cordon_posterior_extrados_fuselaje; cordon_posterior_extrados; cordon_posterior_intrados_fuselaje; cordon_posterior_intrados; ...
          cordon_anterior_extrados_fuselaje; cordon_anterior_extrados; cordon_anterior_intrados_fuselaje; cordon_anterior_intrados];
horizontal_stringers = [cordon; horizontal_stringers];

lines_spars = [barras_larguero_posterior_ala; barras_larguero_anterior_ala; barras_larguero_posterior_fuselaje; barras_larguero_anterior_fuselaje];
end