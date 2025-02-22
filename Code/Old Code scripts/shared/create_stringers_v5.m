function [horizontal_stringers,vertical_stringers] = create_stringers_v5(combined_nodes_3D)

%% 📝 Initialization 

horizontal_stringers = table([], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                      'length', 'h'});
vertical_stringers = table([], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                      'length', 'h'});

warnings = {};
line_counter = 1;

[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, rib_ranges_by_ribs, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v4(combined_nodes_3D);
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

%% Creación de larguerillos/barras

% Extrados
for index_larguerillo = 1:max_stringer_index

    larguerillo_fuselage = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer fuselaje' & ...
                           combined_nodes_3D.h == 'extrados',:);
    encastre = combined_nodes_3D(combined_nodes_3D.stringer_index==index_larguerillo & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -1,:);
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -2,:);
    larguerillo_wing = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);
    larguerillo_wing = [larguerillo_wing;Node_front_spar];
    
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
    Node_front_spar = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -2,:);
    larguerillo_wing = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);
    larguerillo_wing = [larguerillo_wing;Node_front_spar];
    
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

%% Unir los larguerillos horizontales
% cordon = [cordon_posterior_extrados; cordon_posterior_intrados; cordon_anterior_extrados; cordon_anterior_intrados];
% cordon_fuselaje = [cordon_posterior_extrados_fuselaje; cordon_posterior_intrados_fuselaje; cordon_anterior_extrados_fuselaje; cordon_anterior_intrados_fuselaje];
cordon = [cordon_posterior_extrados_fuselaje; cordon_posterior_extrados; cordon_posterior_intrados_fuselaje; cordon_posterior_intrados; ...
          cordon_anterior_extrados_fuselaje; cordon_anterior_extrados; cordon_anterior_intrados_fuselaje; cordon_anterior_intrados];
horizontal_stringers = [cordon; horizontal_stringers];

end