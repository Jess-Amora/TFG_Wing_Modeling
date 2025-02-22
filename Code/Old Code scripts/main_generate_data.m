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

name = 'A350_original_Structural_parameters_A350';
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
