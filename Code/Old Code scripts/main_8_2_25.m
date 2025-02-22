clear all
% close all
    
addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

%% Añadir Information
name_structural_parameters = "Structural_parameters_a350_1";
name_plane = "Boeing_737";
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';

%% Añadir DatosEstructural
add_datosEstructural(name_structural_parameters, .1, .2, ...
                               2.5, .7, .16, ...
                               .12, .65, ...
                               .25, .4, ...
                               .332, 1000, .9254, database_computer)

% ✅ Ensure datosEstructural is updated before calling addAircraftData
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
datosEstructural = TFG_Amora.datosEstructural.(name_structural_parameters);

%% Añadir avion
TFG_Amora = addAircraftData(name_plane, ...
79000, ...  % MTOW (kg)
125, ...   % Wing Area (m²)
25*pi/180, ...     % Sweep Angle (radian)
35.8, ...    % Wing Span (m)
3.76, ... % Lf (longitud del fuselaje)
6.60, ... % c1 (longitud del encastre)
1.49, ...% c2 (longitud del punta)
name_structural_parameters, datosEstructural);


%%
% databasePath = fullfile(database_computer,"data")
avion = TFG_Amora.aviones.(name);
datosEstructural = TFG_Amora.datosEstructural;

plotAla2D(avion,datosEstructural)
%% CARGAS
cargas = schrenk_1(avion,datosEstructural);
TFG_Amora.aviones.(name).cargas = cargas;
save(databasePath, 'TFG_Amora');
cargas = TFG_Amora.aviones.(name).cargas;

%% ALA
results = generate_wing_v5(avion,datosEstructural,cargas,databasePath_result);
    TFG_Amora.aviones.(name).ala_v1 = results;
    ala_v1 = results;
    save(databasePath, 'TFG_Amora');

    
% Fuselaje
results = construir_fuselaje_v5(avion,datosEstructural, ala_v1,true);
    TFG_Amora.aviones.(name).fuselaje5 = results;
    fuselaje_v1 = results;
    save(databasePath, 'TFG_Amora');

%% Estructura
generar_structure_v1(avion,datosEstructural,cargas,ala_v1,fuselaje_v1,databasePath_result);



% TFG_Amora = addAircraftData('Boeing_737_800', ...
% 79000, ...  % MTOW (kg)
% 35.8, ...   % Wing Span (m)
% 125, ...    % Wing Area (m²)
% 25, ...     % Sweep Angle (degrees)
% 0.3);       % Taper RatioWarning: Database does not exist. Creating a ne