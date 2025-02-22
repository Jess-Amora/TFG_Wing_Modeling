function [H] = construirH_caja(avion,datosEstructural,dimension)
    % Lw = avion.geometria.Lw;
    Lf = avion.geometria.Lf;
    numero_costillas = dimension.numero_costillas;
    numero_costillas_triangulo = dimension.numero_costillas_triangulo;
    costillas = dimension.costillas;
    % Parameters
    Lw = 30; % Wing total span in meters
    H_root = 1.0; % Height at the root in meters
    H_middle = 0.7; % Height at the middle in meters
    H_tip = 0.3; % Height at the tip in meters
    H_constant = H_middle - H_tip; % Es para hallar la segunda equation H_constant/(Lw/2) = pendiente segunda H2
    
    
    % % Known points for spline
    % x_coords = [0, Lw/2, Lw]; % Root, middle, and tip positions
    % H_values = [H_root, H_middle, H_tip]; % Corresponding heights
    
    % Rib positions (example: 10 ribs along the wing span)
    num_ribs = numero_costillas;
    
    % x_local_ala = linspace(0, Lw, num_ribs); % Rib coordinates along the wing
    x_costillas = costillas(numero_costillas_triangulo+1:end,1,1) - Lf;
    Lw_costillas = x_costillas(end);
    
    H1 = H_root + (H_middle - H_root)/(Lw_costillas/2)*x_costillas(1:end/2);
    H2 = H_middle + H_constant - (H_constant)*x_costillas((end/2)+1:end)/(Lw_costillas/2);
    H = [[H_root]*ones(numero_costillas_triangulo,1);H1;H2];
end