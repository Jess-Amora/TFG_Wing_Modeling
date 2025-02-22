clear all
% close all
    
addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

%% Añadir Information
name_structural_parameters = "Structural_parameters_a350_1";
name_plane = "Boeing_737";
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer,"Data");
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

% name = 'A350_original_Structural_parameters_A350';
% name = 'Boeing_737_Commercial_Airliners';
name = 'Airbus_A380_Structural_parameters_A350';
avion = TFG_Amora.aviones.(name);
% name = 'A350_original_Structural_parameters_A350';

% plotAla2D(avion,datosEstructural)
%% CARGAS
cargas = schrenk_1(avion);
TFG_Amora.aviones.(name).cargas = cargas;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
cargas = TFG_Amora.aviones.(name).cargas;

% %% ALA
% results = generate_wing_v9(avion,cargas);
%     TFG_Amora.aviones.(name).ala = results;
%     ala = results;
%     save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

[results] = construirAla_v15(avion,avion.datosEstructural,cargas);
TFG_Amora.aviones.(name).ala = results;
save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');

results = construir_fuselaje_v5(avion,avion.datosEstructural, results);
    TFG_Amora.aviones.(name).fuselaje = results;
    fuselaje = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');

    calculate_lift_distribution(ala,avion,cargas)
    % cargas = schrenk_1(avion,datosEstructural);
    % TFG_Amora.aviones.a350_1000.cargas = cargas;
    % save('../Data/TFG_amora.mat', 'TFG_Amora');
    % cargas = TFG_Amora.aviones.a350_1000.cargas;
% 
%     datos=avion.datosEstructural;
% %     mesh_asdasdetest= ala.mesh_struct;
%     % plotAla2Dlarguerillo(avion,datos,ala)
% plottitle = strcat('plotAla2D_mesh_solo_nodos_v6__ala14_TFG_Amora.aviones.a350_1000_datos_estructual');
% plotfilename = strcat('../Results/Figures/plotAla2D_mesh_solo_nodos_v6_ala14_TFG_Amora_aviones_a350_1000_datos_estructual');
% plotAla2D_mesh_solo_nodos_v6(avion,datos,ala,plottitle,'' ,'',plotfilename);
% 



% % Fuselaje
% results = construir_fuselaje_v5(avion,datosEstructural, ala_v1,true);
%     TFG_Amora.aviones.(name).fuselaje5 = results;
%     fuselaje_v1 = results;
%     save(databasePath, 'TFG_Amora');
% 
% %% Estructura
% generar_structure_v1(avion,datosEstructural,cargas,ala_v1,fuselaje_v1,databasePath_result);
% 
% 

% TFG_Amora = addAircraftData('Boeing_737_800', ...
% 79000, ...  % MTOW (kg)
% 35.8, ...   % Wing Span (m)
% 125, ...    % Wing Area (m²)
% 25, ...     % Sweep Angle (degrees)
% 0.3);       % Taper RatioWarning: Database does not exist. Creating a ne