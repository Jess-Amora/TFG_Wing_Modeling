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

%% Añadir DatosEstructural
add_datosEstructural(name_structural_parameters, ...
    0.1, ...   % 🟢 porcentaje_peso_ala_MTOW → % of MTOW attributed to wing weight
    0.2, ...   % 🟢 porcentaje_peso_combustible_MTOW → % of MTOW attributed to fuel weight
    2.5, ...   % 🟢 n → Load factor (typically 2.5 for commercial aircraft)
    0.7, ...   % 🟢 distancia_entre_costillas → Rib spacing (meters)
    0.16, ...  % 🟢 distancia_entre_larguerillo → Stringer spacing (meters)
    0.12, ...  % 🟢 Distancia_larguero_anterior_cuerda_porcentaje → % Chord position of front spar
    0.65, ...  % 🟢 Distancia_larguero_posterior_cuerda_porcentaje → % Chord position of rear spar
    0.25, ...  % 🟢 distancia_centro_aerodinamico → Aerodynamic center position (% chord)
    0.4, ...   % 🟢 distancia_eje_de_referencia_estructural_larguero → Structural ref axis (spars)
    0.332, ... % 🟢 distancia_eje_de_referencia_estructural_cuerda → Structural ref axis (chord)
    1000, ...  % 🟢 numero_de_puntos_en_las_lineas → FEM discretization points
    0.9254, ...% 🟢 k_sust → Lift coefficient for structural modeling
    database_computer ... % 🟢 projectRoot → Root directory for saving data
);


% ✅ Ensure datosEstructural is updated before calling addAircraftData
load(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
datosEstructural = TFG_Amora.datosEstructural.(name_structural_parameters);

%% Añadir avion
name_plane ="A350_original"
TFG_Amora = addAircraftData(name_plane, ...
316,000 , ...  % MTOW (kg)
443 , ...   % Wing Area (m²)
0.5568 , ...     % Sweep Angle (radian)
64.75, ...    % Wing Span (m)
5.96, ... % Lf (longitud del fuselaje)
13.47, ... % c1 (longitud del encastre)
2.88, ...% c2 (longitud del punta)
name_structural_parameters, datosEstructural);


%%
name = strcat(name_plane,"_",name_structural_parameters);
% databasePath = fullfile(database_computer,"data")
avion = TFG_Amora.aviones.(name);
datosEstructural = TFG_Amora.datosEstructural;

% plotAla2D(avion,datosEstructural)
%% CARGAS
cargas = schrenk_1(avion);
TFG_Amora.aviones.(name).cargas = cargas;
save(data_path, 'TFG_Amora');
cargas = TFG_Amora.aviones.(name).cargas;

%% ALA
results = generate_wing_v7(avion,cargas);
    TFG_Amora.aviones.(name).ala_v1 = results;
    ala_v1 = results;
    save(data_path, 'TFG_Amora');

    
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