function [cargas] = schrenk_2(avion)
    % Improved Schrenk's approximation for lift distribution.
    %
    % This function calculates the lift load distribution along the half‐wing
    % using two contributions:
    %   1. An elliptical (ideal) lift distribution based on spanwise coordinate.
    %   2. A chord‐based distribution scaled by a structural factor.
    % The final Schrenk load is the average of these two.
    %
    % Inputs:
    %   avion - structure with fields:
    %       datosEstructural: structure with structural data including:
    %           - k_sust_a350_1000 (scaling factor)
    %           - distancia_centro_aerodinamico
    %           - numero_de_puntos_en_las_lineas
    %       geometria: structure with geometry data including:
    %           - Lf (fuselage length contribution)
    %           - b (total wingspan)
    %           - c1 (root chord)
    %           - c2 (tip chord)
    %           - flecha_radian (sweep angle in radians)
    %       superficie: wing area
    %
    % Outputs:
    %   cargas - structure with fields:
    %       l_eliptica: normalized elliptical load distribution along y
    %       l_cuerda  : chord-based load distribution
    %       schrenk  : averaged load distribution (Schrenk's approximation)
    %       y         : spanwise coordinate vector (half-wing)
    %       c         : chord distribution along the half-wing

    % --- Extract parameters ---
    datosEstructural      = avion.datosEstructural;
    flecha_radian         = avion.geometria.flecha_radian;
    distancia_centro_aero = datosEstructural.distancia_centro_aerodinamico;
    np                    = datosEstructural.numero_de_puntos_en_las_lineas;
    
    % Geometry parameters
    Lf         = avion.geometria.Lf;
    b          = avion.geometria.b;
    c1         = avion.geometria.c1;
    c2         = avion.geometria.c2;
    superficie = avion.superficie;
    
    % --- Define half-wing span ---
    % Assuming the wing root begins after the fuselage (Lf)
    Lw = b/2 - Lf;
    
    % --- Spanwise coordinate ---
    % Use y from 0 (wing root) to Lw (wing tip of half-wing)
    y = linspace(0, Lw, np);
    
    % --- Chord distribution ---
    % Linear taper assumed from c1 at root to c2 at tip
    c = c1 - (c1 - c2) * (y / Lw);
    
    % --- Elliptical load distribution ---
    % A normalized elliptical distribution (maximum at root, zero at tip)
    l_eliptica = sqrt(1 - (y / Lw).^2);
    
    % --- Chord-based load distribution ---
    % Multiply the chord distribution by the structural scaling factor.
    k_sust = datosEstructural.k_sust_a350_1000;
    l_cuerda = k_sust * c;
    
    % --- Schrenk's approximation ---
    % The load is taken as the average of the elliptical and chord-based distributions.
    schrenk = (l_eliptica + l_cuerda) / 2;
    
    % --- Package results ---
    cargas = struct();
    cargas.l_eliptica = l_eliptica;
    cargas.l_cuerda   = l_cuerda;
    cargas.schrenk    = schrenk;
    cargas.y          = y;
    cargas.c          = c;
end
