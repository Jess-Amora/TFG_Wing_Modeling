function cortes = cortes_de_dos_funciones_lineales_v3(coordenadas_f1, m1, coordenadas_f2, m2, indices_f1, indices_f2)
% Versión extendida para incluir índices opcionales de larguerillos y costillas.
%
% Inputs:
%   coordenadas_f1: Nx2 matriz de [x, y] para línea 1 (larguerillos)
%   m1: Pendiente de la línea 1
%   coordenadas_f2: Mx2 matriz de [x, y] para línea 2 (costillas)
%   m2: Pendiente de la línea 2
%   indices_f1 (opcional): Vector de índices para larguerillos (N elementos)
%   indices_f2 (opcional): Vector de índices para costillas (M elementos)
%
% Output:
%   cortes: NxMx4 matriz con:
%       (x, y, índice_larguerillo, índice_costilla)

    % Inicializar salida
    cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 4);
    tolerance = 1e-8; % Tolerancia numérica

    % Si no se proporcionan los índices, crearlos automáticamente
    if nargin < 5 || isempty(indices_f1)
        indices_f1 = (1:size(coordenadas_f1, 1))'; % Crear un vector columna
    end
    if nargin < 6 || isempty(indices_f2)
        indices_f2 = (1:size(coordenadas_f2, 1))'; % Crear un vector columna
    end

    % Calcular constantes de las rectas
    if ~isinf(m1)
        constante_f1 = coordenadas_f1(:, 2) - m1 * coordenadas_f1(:, 1);
    else
        constante_f1 = coordenadas_f1(:, 2);
    end

    if ~isinf(m2)
        constante_f2 = coordenadas_f2(:, 2) - m2 * coordenadas_f2(:, 1);
    else
        constante_f2 = coordenadas_f2(:, 2);
    end

    % Verificar si las líneas son paralelas
    if abs(m1 - m2) < tolerance
        if all(abs(constante_f1 - constante_f2) < tolerance)
            disp('Las líneas son coincidentes: intersecciones infinitas.');
        else
            disp('Las líneas son paralelas: no hay intersecciones.');
        end
        return;
    end

    % Iterar sobre todas las combinaciones de puntos
    for i = 1:size(coordenadas_f1, 1)
        for j = 1:size(coordenadas_f2, 1)
            if isinf(m1) % Línea 1 vertical
                cortes(i, j, 1) = coordenadas_f1(i, 1); % Coordenada x
                cortes(i, j, 2) = m2 * cortes(i, j, 1) + constante_f2(j); % Coordenada y
            elseif isinf(m2) % Línea 2 vertical
                cortes(i, j, 1) = coordenadas_f2(j, 1); % Coordenada x
                cortes(i, j, 2) = m1 * cortes(i, j, 1) + constante_f1(i); % Coordenada y
            elseif abs(m1) < tolerance % Línea 1 casi horizontal
                cortes(i, j, 1) = (coordenadas_f1(i, 2) - constante_f2(j)) / m2;
                cortes(i, j, 2) = coordenadas_f1(i, 2);
            elseif abs(m2) < tolerance % Línea 2 casi horizontal
                cortes(i, j, 1) = (coordenadas_f2(j, 2) - constante_f1(i)) / m1;
                cortes(i, j, 2) = coordenadas_f2(j, 2);
            else % Caso general
                delta_constante = constante_f1(i) - constante_f2(j);
                delta_slope = m1 - m2;
                if abs(delta_slope) > tolerance
                    cortes(i, j, 1) = -delta_constante / delta_slope;
                    cortes(i, j, 2) = constante_f1(i) + m1 * cortes(i, j, 1);
                else
                    disp('Problema de precisión numérica: las líneas parecen casi paralelas.');
                end
            end
            
            % Añadir información de índices
            cortes(i, j, 3) = indices_f1(i); % Índice del larguerillo
            cortes(i, j, 4) = indices_f2(j); % Índice de la costilla
        end
    end
end
