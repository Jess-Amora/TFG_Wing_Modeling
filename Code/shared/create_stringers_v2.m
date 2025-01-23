function [horizontal_stringers,vertical_stringers] = create_stringers_v2(combined_nodes_3D)

%% 📝 Initialization 

horizontal_stringers = table([], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                      'length', 'h'});
vertical_stringers = table([], [], [], [], [], [], [], [], [], ...
    'VariableNames', {'local_id', 'node_1', 'node_2', 'stringer_index', 'rib_1', 'rib_2', 'tag', ...
                      'length', 'h'});

warnings = {};
line_counter = 1;

[num_stringers_last_rib, max_rib_index, max_stringer_index, rib_ranges, special_rib_indices, max_ribs_fuselaje] = analyze_stringer_rib_data_v3(combined_nodes_3D);
start_rib = rib_ranges(1,2);

% %% Creación de cordón en el larguero posterior en extrados
% 
% cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='rear spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
% cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);
% cordon_posterior = [cordon_fuselage(1:end-1,:); cordon_wing];
% 
% 
% [cordon_posterior_extrados, line_counter] = create_lines_from_stringer_horizontal(cordon_posterior, -2, "rear spar", "extrados", 1);
% 
% %% Creación de cordón en el larguero anterior en extrados
% 
% cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'extrados',:);
% cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'extrados',:);
% cordon_anterior = [cordon_fuselage(1:end-1,:); combined_nodes_3D(combined_nodes_3D.tag=='OnlyNode' & combined_nodes_3D.h == 'extrados',:); cordon_wing];
% 
% [cordon_anterior_extrados, line_counter] = create_lines_from_stringer_horizontal(cordon_anterior, -1, "front spar", "extrados", 1);
% 
% %% Creación de cordón en el larguero posterior en intrados
% 
% 
% cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='rear spars' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(1,2),:);
% cordon_posterior = [cordon_fuselage(1:end-1,:); cordon_wing];
% 
% [cordon_posterior_intrados, line_counter] = create_lines_from_stringer_horizontal(cordon_posterior, -2, "rear spar", "intrados", 1);
% 
% %% Creación de cordón en el larguero anterior en intrados
% 
% cordon_fuselage = combined_nodes_3D(combined_nodes_3D.tag=='front spars fuselaje' & combined_nodes_3D.h == 'intrados',:);
% cordon_wing = combined_nodes_3D(combined_nodes_3D.tag=='front spars' & combined_nodes_3D.h == 'intrados',:);
% cordon_anterior = [cordon_fuselage(1:end-1,:); combined_nodes_3D(combined_nodes_3D.tag=='OnlyNode' & combined_nodes_3D.h == 'intrados',:); cordon_wing];
% 
% [cordon_anterior_intrados, line_counter] = create_lines_from_stringer_horizontal(cordon_anterior, -1, "front spar", "intrados", 1);
% 

%% Creación de larguerillos/barras

% Extrados
for index_larguerillo = 1:max_stringer_index

    larguerillo_fuselage = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer fuselaje' & ...
                           combined_nodes_3D.h == 'extrados',:);
    encastre = combined_nodes_3D(combined_nodes_3D.stringer_index==index_larguerillo & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index == -1,:);
    larguerillo_wing = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);

    larguerillo = [larguerillo_fuselage(1:end-1,:); encastre; larguerillo_wing];


    [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo_wing, index_larguerillo, "stringer wing", "extrados", 1);
    horizontal_stringers = [horizontal_stringers ; larguerillo_i];
end

% % Intrados
% for index_larguerillo = 1:max_stringer_index
% 
%     larguerillo_fuselage = combined_nodes_3D(combined_nodes_3D.stringer_index == index_larguerillo & combined_nodes_3D.tag=='stringer fuselaje' & ...
%                            combined_nodes_3D.h == 'intrados',:);
%     encastre = combined_nodes_3D(combined_nodes_3D.stringer_index==index_larguerillo & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index == -1,:);
%     larguerillo_wing = combined_nodes_3D(combined_nodes_3D.tag=='stringer' & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.rib_index >= rib_ranges(index_larguerillo,2),:);
% 
%     larguerillo = [larguerillo_fuselage(1:end-1,:); encastre; larguerillo_wing];
% 
% 
%     [larguerillo_i, line_counter] = create_lines_from_stringer_horizontal(larguerillo, index_larguerillo, "stringer", "intrados", 1);
%     horizontal_stringers = [horizontal_stringers ; larguerillo_i];
% end

% %% Creación de las barras en las costillas
% 
% % Bucle para las costillas en el ala 
% for index_rib = 1:2:max_rib_index
% 
% 
%     Vector_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.tag == 'stringer',:);
%     Vector_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.tag == 'stringer',:);
% 
% 
%     [larguerillo_i, line_counter] = create_lines_from_stringer_vertical(Vector_extrados, Vector_intrados, index_rib, "barra costilla", "vertical", 1);
%     vertical_stringers = [vertical_stringers ; larguerillo_i];
% 
% end
% 
% % Bucle para las costillas en el fuselaje
% for index_rib = 1:2:max_ribs_fuselaje-1
% 
% 
%     Vector_extrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'extrados' & combined_nodes_3D.tag == 'stringer fuselaje',:);
%     Vector_intrados = combined_nodes_3D(combined_nodes_3D.rib_index == index_rib & combined_nodes_3D.h == 'intrados' & combined_nodes_3D.tag == 'stringer fuselaje',:);
% 
% 
%     [larguerillo_i, line_counter] = create_lines_from_stringer_vertical(Vector_extrados, Vector_intrados, index_rib, "barra costilla fuselaje", "vertical", 1);
%     vertical_stringers = [vertical_stringers ; larguerillo_i];
% 
% end

%% Unir los larguerillos horizontales
% horizontal_stringers = [cordon_posterior_extrados; cordon_anterior_extrados; cordon_posterior_intrados; cordon_anterior_intrados; horizontal_stringers];

end