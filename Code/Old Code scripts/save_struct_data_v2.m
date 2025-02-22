%% Cálculo estructural del cajón de torsión TFG 23-24
clear
close all

loadedData = load('TFG_Amora.mat');
TFG_Amora = loadedData.TFG_Amora;

%% Datos globales
% Nomenclatura
% k_sust - es el valor cálculado previámente que la sustentación se haga
%         igual con nW. El cálculo se realiza mediante un método iterativo.


% Flag para guardar los datos de todas las informaciones
guardardatos = false;
if guardardatos
    guardarDatosAvion = true;
    guardarDatosEstructural = true;
    guardarDatosCoordenadas = true;
    guardarDatosSchrenk = true;
else
    guardarDatosAvion = false;
    guardarDatosEstructural = false;
    guardarDatosCoordenadas = false;
    guardarDatosSchrenk = false;
end

% Peso
porcentaje_peso_ala_MTOW = 0.1;
porcentaje_peso_combustible_MTOW = 0.2;

%factor de carga
n = 2.5; %MTOW > 5e4

% Costilla
% Es el valor de distancia entre costillas y larguerillos
distancia_entre_costillas = 0.7; % (m) metros
distancia_entre_larguerillo = 0.160; % (m) metros

% Espaciado larguero
% Distancia de los largueros
Distancia_larguero_anterior_cuerda_porcentaje =  0.12; % La distancia del larguero anterior
Distancia_larguero_posterior_cuerda_porcentaje =  0.65; % La distancia del larguero anterior

% Distancias en la sección cuerda
distancia_centro_aerodinamico = 0.25; % Porcentaje de la distancia del centro aerodinámico en la cuerda desde el borde de ataque
distancia_eje_de_referencia_estructural_larguero = 0.4; % Porcentaje de la distancia de eje de referencia entre los largueros
distancia_eje_de_referencia_estructural_cuerda = ((Distancia_larguero_posterior_cuerda_porcentaje-Distancia_larguero_anterior_cuerda_porcentaje)...
    *distancia_eje_de_referencia_estructural_larguero) + Distancia_larguero_anterior_cuerda_porcentaje; % Porcentaje de la distancia del eje de referencia estructural en la cuerda desde el borde de ataque

% Velocidades
velocidad_sonido_11km=295.2; %m/s
velocidad_crucero_11km = 0.85 * velocidad_sonido_11km;
velocidad_dive = 1.25 * velocidad_crucero_11km; % Design dive speed

% q = .5 * densidad * velocidad al cuadrado
q_11km = .5*0.365*velocidad_dive^2 ;

% Plot
% El número de puntos que están en las gráficas
numero_de_puntos_en_las_lineas = 1e3;

% Valores de k_sust hallada de la iteración
% k_sust = 1.202927; % Esta k es para x_local_ala en eliptica y en el c(y)
% k_sust = 1.0408; % Esta k es para x_local_ala en eliptica y x_chord en el c(y)
k_sust = 0.9254; % Esta k es para x_chord en eliptica y en el c(y), además usamos Lw en vez de b/2 en la ecuacu¡ión elíptica
% k_sust = 42.54; % Esta k es x_chord en c(y), l_elip y en l=spline(x_chord,schrenk,...

% % Cargando Imágenes
% img1 = imread('img1.png');

TFG_Amora = struct();

%% Datos A350-900 
% Pesos
MTOW_a350_900 = 280e3; % Peso MTOW
peso_ala_a350_900 = MTOW_a350_900*porcentaje_peso_ala_MTOW; % Peso ala
peso_combustible_a350_900 = MTOW_a350_900*porcentaje_peso_combustible_MTOW; %Peso combustible

% Superficie del ala
superficie_a350_900 = 443 ; % m2



%% Datos A350-1000
% Pesos
MTOW_a350_1000 = 319e3; % Peso MTOW
peso_ala_a350_1000 = MTOW_a350_1000*porcentaje_peso_ala_MTOW; % Peso ala
peso_combustible_a350_1000 = MTOW_a350_1000*porcentaje_peso_combustible_MTOW; %Peso combustible

% longitud
longitud_encastre_a350_1000 = 13.47; % La longitud horizontal de la union ala-fuselaje
longitud_punta_ala_a350_1000 = 5.27/2; % La longitud de la sección en la punta del ala
b_a350_1000 = 64.75; % b
anchura_fuselaje_a350_1000 = 5.96; % La anchura del fuselaje
b_semiala_a350_1000 = b_a350_1000/2 - anchura_fuselaje_a350_1000/2; % La longitud del ala

% Flecha 
flecha_grados_a350_1000 = 31.9; % Flecha en grados
flecha_radianes_a350_1000 = flecha_grados_a350_1000*pi/180; % Flecha en radianes

% Superfice del ala
superficie_a350_1000 = 460; %m2

%A300
cociente_espesor_cuerda=.105; %



%% Datos para el código
% Nomenclatura
% b - envergadura (m)
% c1 - longitud del encastre
% c2 - longitud de la sección de la punta
% Lf - anchura del fuselaje
% Lw - anchura del semiala
% x - Coordenada que sigue la dirección de la cuerda desde el borde de 
%     ataque (parte frontal) hasta el borde de salida (parte posterior) del ala en cada sección.
% superficie - La superficie del ala
% anchura_fuselaje - anchura del fuselaje
% lambda - Relación de estrechamiento
% x_global_punta_ala - desde  
% flecha_borde_de_ataque - es la flecha del borde de ataque.


longitud_encastre = longitud_encastre_a350_1000;
longitud_punta_ala = longitud_punta_ala_a350_1000;
anchura_fuselaje = anchura_fuselaje_a350_1000;
b = b_a350_1000;
b_semiala = b_semiala_a350_1000;
flecha_radianes = flecha_radianes_a350_1000;
superficie = superficie_a350_1000;
MTOW = MTOW_a350_1000;

% Valores para nomenclatura
c1 = longitud_encastre;
c2 = longitud_punta_ala;
Lf = anchura_fuselaje/2;
Lw = b_semiala;
lambda = c2 / c1;
y_global_punta_ala_borde_ataque = c1 * distancia_centro_aerodinamico + sin(flecha_radianes) * Lw -c2 * distancia_centro_aerodinamico;
% cociente_longitud_fuselaje = round( Lf*2 /b *1000);
% cociente_cuerda_lim = round( c1 /y_global_punta_ala_borde_ataque );


if guardarDatosEstructural
    % Datos estructurales
    TFG_Amora.datosEstructural.porcentaje_peso_ala_MTOW = porcentaje_peso_ala_MTOW;
    TFG_Amora.datosEstructural.porcentaje_peso_combustible_MTOW = porcentaje_peso_combustible_MTOW;
    TFG_Amora.datosEstructural.n = n;
    TFG_Amora.datosEstructural.distancia_entre_costillas = distancia_entre_costillas; % Es el valor de distancia entre costillas
    TFG_Amora.datosEstructural.distancia_entre_larguerillo = distancia_entre_larguerillo; % Es el valor de distancia entre costillas 
    TFG_Amora.datosEstructural.distancia_larguero_anterior_cuerda_porcentaje = Distancia_larguero_anterior_cuerda_porcentaje; % La distancia del larguero anterior
    TFG_Amora.datosEstructural.distancia_larguero_posterior_cuerda_porcentaje = Distancia_larguero_posterior_cuerda_porcentaje; % La distancia del larguero anterior
    TFG_Amora.datosEstructural.distancia_centro_aerodinamico = distancia_centro_aerodinamico; % Porcentaje de la distancia del centro aerodinámico en la cuerda desde el borde de ataque
    TFG_Amora.datosEstructural.distancia_eje_de_referencia_estructural_larguero = distancia_eje_de_referencia_estructural_larguero; % Porcentaje de la distancia de eje de referencia entre los largueros
    TFG_Amora.datosEstructural.distancia_eje_de_referencia_estructural_cuerda = distancia_eje_de_referencia_estructural_cuerda; % Porcentaje de la distancia del eje de referencia estructural en la cuerda desde el borde de ataque
    TFG_Amora.datosEstructural.numero_de_puntos_en_las_lineas = numero_de_puntos_en_las_lineas; % El número de puntos que están en las gráficas
    TFG_Amora.datosEstructural.k_sust_a350_1000 = k_sust; % Es el constante de la función de sustentación distribuida de cuerda (l(x) = k * c(y), donde k = k_sust)
    TFG_Amora.datosEstructural.numero_de_puntos_en_las_lineas = numero_de_puntos_en_las_lineas;
end


save('TFG_Amora.mat', 'TFG_Amora');