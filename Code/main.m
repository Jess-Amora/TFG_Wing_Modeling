%% Cálculo estructural del cajón de torsión TFG 23-24
clear all
% close all
    
addpath('./shared');
addpath('./wing_builder');
addpath('./fuselage_builder');

loadedData = load('../Data/TFG_amora.mat');
TFG_Amora = loadedData.TFG_Amora;

% Flag construir ala
FlagConstruirCargas = false;
FlagConstruirAla = false;
FlagConstruirFuselaje = false;
FlagConstruirFuselaje2 = false;
FlagConstruirFuselaje3 = false;
FlagConstruirFuselaje4 = false;
FlagConstruirAla2 = false;
FlagConstruirAla3 = false;
FlagConstruirAla4 = false;
FlagConstruirAla5 = false;
FlagConstruirAla6 = false;
FlagConstruirAla7 = false;
FlagConstruirAla8 = false;
FlagConstruirAla9 = false;
FlagConstruirAla10 = false;
FlagConstruirAla11 = true;
output_command8 = false;
mesh_generar6 = false;

%
avion = TFG_Amora.aviones.a350_1000;
datosEstructural = TFG_Amora.datosEstructural;
cargas = TFG_Amora.aviones.a350_1000.cargas;
% ala = avion.ala;
% ala2 = avion.ala2;
% ala3 = avion.ala3;  
% ala4 = avion.ala4;
% ala5 = avion.ala5;
% ala6 = avion.ala6;
% ala7 = avion.ala7;
ala8 = avion.ala8;
ala9 = avion.ala9;
ala10 = avion.ala10;
ala11 = avion.ala11;
% fuselaje = avion.fuselaje;
% fuselaje2 = avion.fuselaje2;
% fuselaje3 = avion.fuselaje3;
numero_de_puntos = datosEstructural.numero_de_puntos_en_las_lineas;
x_local_ala = avion.coordenadas.x_local_ala;

if FlagConstruirCargas
    cargas = schrenk_1(avion,datosEstructural);
    TFG_Amora.aviones.a350_1000.cargas = cargas;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    cargas = TFG_Amora.aviones.a350_1000.cargas;
end


if FlagConstruirAla
    results = construirAla(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala = TFG_Amora.aviones.a350_1000.ala;
end

if FlagConstruirAla2
    results = construirAla_v2(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala2 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala2 = TFG_Amora.aviones.a350_1000.ala2;
end

if FlagConstruirAla3
    results = construirAla_v3(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala3 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala3 = TFG_Amora.aviones.a350_1000.ala3;
end

if FlagConstruirAla4
    results = construirAla_v4(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala4 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala4 = TFG_Amora.aviones.a350_1000.ala4;
end

if FlagConstruirAla5
    results = construirAla_v5(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala5 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala5 = TFG_Amora.aviones.a350_1000.ala5;
end

if FlagConstruirAla6
    results = construirAla_v6(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala6 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala6 = TFG_Amora.aviones.a350_1000.ala6;
end

if FlagConstruirAla7
    results = construirAla_v7(avion,datosEstructural,cargas);
    TFG_Amora.aviones.a350_1000.ala7 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala7 = TFG_Amora.aviones.a350_1000.ala7;
end

if FlagConstruirAla8
    results = construirAla_v8(avion,datosEstructural,cargas,output_command8);
    TFG_Amora.aviones.a350_1000.ala8 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala8 = TFG_Amora.aviones.a350_1000.ala8;
end

if FlagConstruirAla9
    results = construirAla_v9(avion,datosEstructural,cargas,output_command8);
    TFG_Amora.aviones.a350_1000.ala9 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    ala9 = TFG_Amora.aviones.a350_1000.ala9;
end

if FlagConstruirAla10
    results = construirAla_v10(avion,datosEstructural,cargas,output_command8);
    TFG_Amora.aviones.a350_1000.ala10 = results;
    ala10 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    
end

if FlagConstruirAla11
    results = construirAla_v11(avion,datosEstructural,cargas,output_command8);
    TFG_Amora.aviones.a350_1000.ala11 = results;
    ala11 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    
end
% FlagConstruirAlatestpatran = true;
% if FlagConstruirAlatestpatran
%     results = construirAla_v8(avion,datosEstructuraltest,cargas,false);
%     TFG_Amora.aviones.a350_1000.alapatrantest = results;
%     save('../Data/TFG_amora.mat', 'TFG_Amora');
%     alapatrantest = TFG_Amora.aviones.a350_1000.alapatrantest;
% end


if FlagConstruirFuselaje
    results = construirFuselaje(avion,datosEstructural);
    TFG_Amora.aviones.a350_1000.fuselaje = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    fuselaje = TFG_Amora.aviones.a350_1000.fuselaje;
end

if FlagConstruirFuselaje2
    results = construir_fuselaje_v2(avion,datosEstructural);
    TFG_Amora.aviones.a350_1000.fuselaje2 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    fuselaje2 = TFG_Amora.aviones.a350_1000.fuselaje2;
end

if FlagConstruirFuselaje3
    results = construir_fuselaje_v3(avion,datosEstructural, ala8,true);
    TFG_Amora.aviones.a350_1000.fuselaje3 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
    fuselaje3 = TFG_Amora.aviones.a350_1000.fuselaje3;
end

if FlagConstruirFuselaje4
    results = construir_fuselaje_v4(avion,datosEstructural, ala9,true);
    TFG_Amora.aviones.a350_1000.fuselaje4 = results;
    fuselaje4 = results;
    save('../Data/TFG_amora.mat', 'TFG_Amora');
end

% % Flag graficas
% showAla = true;




% PLOTS-----------------------------------------------------------------------
% schrenk(avion,datosEstructural)
% plotschrenk(avion,datosEstructural)
% plotAla2D(avion,datosEstructural)

% construirAla_showAla(avion,datosEstructural,cargas,true)
% plotAla2D(avion,datosEstructural)
% ala_test = construirAla_debug2(avion,datosEstructural,cargas);
% plotAla3DL(avion,datosEstructural,ala)

%Larguerillo
% plotAla2Dlarguerillo(avion,datosEstructural,ala3)
% plotAla2Dlarguerillo_fuselaje(avion,datosEstructural,ala,fuselaje)
% plotAla2Dlarguerillo_total(avion,datosEstructural,ala,fuselaje)

%costilla
% plotAla2Dcostilla(avion,datosEstructural,ala)
% plotAla2Dcostilla_fuselaje(avion,datosEstructural,ala)
% plotAla2Dcostilla_total(avion,datosEstructural,ala,fuselaje)

%mesh
% plotAla2D_mesh(avion,datosEstructural,ala3)
% plotAla2D_mesh_solo_nodos(avion,datosEstructural,ala4)
% plotAla2D_mesh_fuselaje(avion,datosEstructural,fuselaje3,ala8)
% plotAla2D_mesh_solo_nodos_v1(avion,datosEstructural,ala4)
% plotAla2D_mesh_solo_nodos_v2(avion,datosEstructural,ala5)
% plotAla2D_mesh_solo_nodos_v3(avion,datosEstructural,ala6)
% plotAla2D_mesh_solo_nodos_v4(avion,datosEstructural,ala6)
% plotAla2D_mesh_solo_nodos_v3(avion,datosEstructural,ala7)
% plotAla2D_mesh_solo_nodos_v4(avion,datosEstructural,ala7)
% plotAla2D_mesh_solo_nodos_v4(avion,datosEstructural,ala8)
% plotAla2D_mesh_solo_nodos_v4(avion,datosEstructural,ala9)
% plottitle = strcat('plotAla2D_mesh_solo_nodos_v5','ala9', '_TFG_Amora.aviones.a350_1000');
% plotfilename = strcat('../Results/Figures/plotAla2D_mesh_solo_nodos_v5','ala9', '_TFG_Amora_aviones_a350_1000');
% plotAla2D_mesh_solo_nodos_v5(avion,datosEstructural,ala9,plottitle,'' ,'',plotfilename);

% plotnumber = 6;
% plottitle = strcat('plotAla2D_mesh_solo_nodos_v',string(plotnumber),' ala9', '_TFG_Amora.aviones.a350_1000');
% plotfilename = strcat('../Results/Figures/plotAla2D_mesh_solo_nodos_v6','ala9', '_TFG_Amora_aviones_a350_1000');
% plotAla2D_mesh_solo_nodos_v6(avion,datosEstructural,ala9,plottitle,'' ,'',plotfilename);


% plottitle = strcat('plotAla2D_mesh_solo_nodos_v6_ala10', '_TFG_Amora.aviones.a350_1000');
% plotfilename = strcat('../Results/Figures/plotAla2D_mesh_solo_nodos_v6','ala10', '_TFG_Amora_aviones_a350_1000');
% plotAla2D_mesh_solo_nodos_v6(avion,datosEstructural,ala10,plottitle,'' ,'',plotfilename);

plottitle = strcat('plotAla2D_mesh_solo_nodos_v6__ala11', '_TFG_Amora.aviones.a350_1000');
plotfilename = strcat('../Results/Figures/plotAla2D_mesh_solo_nodos_v6_ala11_TFG_Amora_aviones_a350_1000');
plotAla2D_mesh_solo_nodos_v6(avion,datosEstructural,ala11,plottitle,'' ,'',plotfilename);

% Mesh barras
% [nodos elementos] = generar_barras(avion,datosEstructural,ala4,fuselaje2);
% [nodos elementos] = generar_barras_v2(avion,datosEstructural,ala4,fuselaje2);
% [nodos elementos] = generar_barras_v3(avion,datosEstructural,ala4,fuselaje2);
% [nodos elementos] = generar_barras_v4(avion,datosEstructural,ala4,fuselaje2);
% [nodos elementos] = generar_barras_v5(avion,datosEstructural,ala4,fuselaje2);


% 3D
% 
% % z-function (constant for simplicity)
% z_function = @(x, y) 0;  % Flat plane
% z_upper = 1;  % Upper surface offset
% z_lower = -1; % Lower surface offset
% 
% % File paths for CSV export
% nodeFile = 'mesh\nodes_3D.csv';
% elementFile = 'mesh\elements_3D.csv';

% Create 3D map
% create3DMap(nodos, elementos, z_function, z_upper, z_lower, nodeFile, elementFile);
% create3DMap_v2(nodos, elementos, z_upper, z_lower, nodeFile, elementFile);
% create3DMap_v3(nodos, elementos, z_upper, z_lower, nodeFile, elementFile);

%%
%mom torsion
% plotAlaMom(avion,datosEstructural,ala)
% plotAlaTorsion(avion,datosEstructural,ala)

% figure
%  plot(linspace(0,Lw/2),1 + linspace(0,Lw/2)* (.7-1)/(Lw/2))
%  hold on
% plot(linspace(Lw/2,Lw),1.1 + linspace(Lw/2,Lw)* (-.4)/(Lw/2))

% %% Generate wing motherfuckers!!!!!
% output_path = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main';
% generarAlaEstructura_v1(avion,datosEstructural,ala,fuselaje,output_path,true)
% Fuselaje

% fuselaje = construir_caja_de_torsion_fuselaje(avion,datosEstructural, showplot)




%% H
% % Lw = avion.geometria.Lw;
% Lf = avion.geometria.Lf;
% numero_costillas = ala.numero_costillas;
% numero_costillas_triangulo = ala.numero_costillas_triangulo;
% costillas = ala.costillas;
% % Parameters
% Lw = 30; % Wing total span in meters
% H_root = 1.0; % Height at the root in meters
% H_middle = 0.7; % Height at the middle in meters
% H_tip = 0.3; % Height at the tip in meters
% H_constant = H_middle - H_tip; % Es para hallar la segunda equation H_constant/(Lw/2) = pendiente segunda H2
% 
% 
% % % Known points for spline
% % x_coords = [0, Lw/2, Lw]; % Root, middle, and tip positions
% % H_values = [H_root, H_middle, H_tip]; % Corresponding heights
% 
% % Rib positions (example: 10 ribs along the wing span)
% num_ribs = numero_costillas;
% 
% % x_local_ala = linspace(0, Lw, num_ribs); % Rib coordinates along the wing
% x_costillas = costillas(numero_costillas_triangulo+1:end,1,1) - Lf;
% Lw_costillas = x_costillas(end);
% 
% H1 = H_root + (H_middle - H_root)/(Lw_costillas/2)*x_costillas(1:end/2)
% H2 = H_middle + H_constant - (H_constant)*x_costillas((end/2)+1:end)/(Lw_costillas/2)
% H = [[H_root]*ones(numero_costillas_triangulo,1);H1;H2];
% 
% % 
% 
% % Parameters for NACA 64A-415
% m = 0.02; % Maximum camber (2% of chord)
% p = 0.4;  % Position of maximum camber (40% of chord)
% t = 0.15; % Maximum thickness (15% of chord)
% c = 1.0;  % Chord length (1 meter)
% num_points = 200; % Number of points for smooth resolution
% show_graph = true; % Display the graph
% 
% % Generate the airfoil
% [x, y_u, y_l] = naca6series(m, p, t, c, num_points, show_graph);
% 
% % Optional: Save coordinates for further use
% airfoil_coords = [x', y_u', y_l'];
% disp('Airfoil coordinates generated.');

% naca_64A_415 = struct('m',0.02,'p',0.4,'t',0.15)

%% Construir caja de torsión en el fuselaje
% caja_fuselaje = construir_caja_de_torsion_fuselaje(avion,datosEstructural)

% H = construirH_caja(avion,datosEstructural,ala);
% %% Cajon
% 
% % H = 1;
% C = 6;
% tss = 6;
% tsi = 6;
% tl = 6;
% % DimensionsCajon = [H C [tss tsi tl]*1e-3];
% 
% % Larguerillo en T
% wf = 90;
% tf = 6;
% hw = 60;
% tw = 6;
% dimensionsT = [wf tf hw tw 0 0]*1e-3;
% 
% % Cordon
% hcl = 360;
% tcl = 36;
% dimensionsC = [hcl tcl]*1e-3;
% 
% % Pandeos
% % pandeoLocalsuperior = true caso conservativo
% pandeoLocalsuperior = true; % función cajón y función reparto_esfuerzos
% pandeoLocalinferior = false; % función reparto_esfuerzos
% 
% % Larguerillo T Argumentos [dimensions: vector with dimensions [h, t, w1, w2] (height, thickness, flange widths)]
% [A_L,~,~] = larguerillo('T',dimensionsT,showPlot);
% [A_C,~,~] = cordon(dimensionsC, showPlot);
% Cajon Argumentos [ Dimensions: [H, C, tss, tsi, tl, A_larguerillo,
% A_cordon] ,pandeoLocal ( boolean)]
% [I , hcg] = cajon([DimensionsCajon  A_L A_C 10],pandeoLocalsuperior);
% esfuerzos(1e5 , 1e5, 1e5, I,hcg, DimensionsCajon(1:2));
% 
% % Nomenclatura Etapa 3 guia
% % 
% % Revestimiento superior
% % Als - area del larguerillo superior Als= (tws*hws+wfs*tfs+whs*ths)
% % Acls - area del cordón superior del larguero Acls=2*hcls*tcls
% % Ass - area del skin superior Ass = tss*c
% % Ars - area del revestimiento superior total Ars = Ass + n* Als + 2*Acls
% % 
% % Revestimiento inferior
% % Ali - area del larguerillo superior Ali= (twi*hwi+wfi*tfi+whi*thi)
% % Acli - area del cordón inferior del larguero Acli=2*hcli*tcli
% % Asi - area del skin inferior Asi = tsi*c
% % Ari - area del revestimiento inferior total Ari = Asi + n* Ali + 2*Acli
% 
% %% Esfuerzos cortantes
% 
% % Inputs
% geometry = struct('H', 1.5, 'hcg', 0.75, 'tss', 0.005, 'tsi', 0.004, ...
%                   'tl', 0.008, 'A_Ls', 0.002, 'A_Li', 0.0015, ...
%                   'pitch', 0.2, 'I', 0.003, 'S', 1.2);
% F = 50000; % Fuerza cortante (N)
% T = 1000;  % Momento torsor (Nm)
% 
% % Cálculo de esfuerzos cortantes
% shear_stresses = calcularEsfuerzosCortantes(F, T, geometry, []);
% 
% % Visualizar
%  if showPlot
%     plotShearDistribution(shear_stresses);
%  end
% 


