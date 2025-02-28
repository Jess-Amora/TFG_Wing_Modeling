% clear all;
addpath('./5. FEA validation');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

% %% 🔹 Step 2: User Selects Aircraft
% disp('----------------------------------------');
% disp('🛩 Select an Aircraft to Process:');
% avionNames = fieldnames(TFG_Amora.aviones);
% 
% if isempty(avionNames)
%     disp('⚠️ No aircraft available. Please add data first.');
%     return;
% end
% 
% for i = 1:length(avionNames)
%     fprintf('%d) %s\n', i, avionNames{i});
% end
% fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);
% 
% avionChoice = input('Select an option: ', 's');
% avionIndex = str2double(avionChoice);
% 
% if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
%     disp('❌ Invalid selection. Returning to menu.');
%     return;
% end
% 
% if avionIndex == length(avionNames) + 1
%     disp('🔙 Returning to Main Menu...');
%     run('main_menu.m');
%     return;
% end
% 
% name = avionNames{avionIndex}; 
% disp(['✅ Selected Aircraft: ', name]);
% avion = TFG_Amora.aviones.(name);
avion = TFG_Amora.aviones.Airbus_A380_Structural_parameters_A350;

% avion = TFG_Amora.aviones.A350_XWB_Structural_parameters_A350;



% elements = avion.elements;
% combined_nodes = elements.nodes;
% quad_rear_spar_wing = elements.quad.quad_rear_spar_wing;
% quad_surfaces_regular_wing = elements.quad.quad_surfaces_regular_wing;


% plot_rear_spar_surfaces(combined_nodes, quad_rear_spar_wing);




% plot_stringer_regular_surfaces(combined_nodes, quad_surfaces_regular_wing,avion);



plotAla2D_fuerzas(avion)




%% 🔹 Step 3: Plotting Geometry
% plotAla2D_costillas_larguerillos(avion)
% plotAla2Dlarguerillo_fuselaje(avion)
% plotAla2Dcostilla_fuselaje(avion)
% plotAla2D_costillas_larguerillo_fuselaje(avion)
% plotAla2Dcostilla_total(avion)
% plotAla2Dlarguerillo_total(avion)
% plotAla2Dcostilla_larguerillo_total(avion)
% plotAla2D_costillas(avion)
% plotAla2D_mesh_nodos(avion)
% plotAla2D(avion)

disp('🛩 Plotting Results stage 2:');
disp('----------------------------------------');
disp('🛩 Plotting: The geometry of the wing');
% try
    plotAla2D(avion)
% catch ME
%     warning('Error in plotAla2Dlarguerillo: %s', ME.message);
% end
disp('----------------------------------------');
disp('🛩 Plotting: Larguerillo');
% try
    plotAla2Dlarguerillo(avion)
% catch ME
%     warning('Error in plotAla2Dlarguerillo: %s', ME.message);
% end
disp('----------------------------------------');
disp('🛩 Plotting: costillas');
% try
% plotAla2D_mesh_nodos(avion,geom_struct,ribs_struct,mesh_struct)
%     plotAla2D_mesh_nodos(avion,geom_struct)
    % plotAla2D_costillas(avion)
% catch ME
%     warning('Error in plotAla2Dlarguerillo: %s', ME.message);
% end
disp('----------------------------------------');
disp('🛩 Plotting: costillas y larguerillos');
% try
% % plotAla2D_mesh_nodos(avion,geom_struct,ribs_struct,mesh_struct)
% %     plotAla2D_mesh_nodos(avion,geom_struct)
    % plotAla2D_costillas_larguerillos(avion)
% catch ME
%     warning('Error in plotAla2Dlarguerillo: %s', ME.message);
% end
disp('----------------------------------------');
disp('🛩 Plotting: nodos');
% try
% % plotAla2D_mesh_nodos(avion,geom_struct,ribs_struct,mesh_struct)
% %     plotAla2D_mesh_nodos(avion,geom_struct)
    % plotAla2D_mesh_nodos(avion)
% catch ME
%     warning('Error in plotAla2Dlarguerillo: %s', ME.message);
% end