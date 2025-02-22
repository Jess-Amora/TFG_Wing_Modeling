function [cortes, ids_locales] = cortes_de_dos_funciones_lineales_v2(coordenadas_f1, m1, coordenadas_f2, m2)
    % Esta función calcula las intersecciones de dos funciones lineales
    % y devuelve coordenadas con IDs locales de larguerillo y costilla.
    % Salidas:
    % - cortes: Matriz de intersecciones (NxMx2).
    % - ids_locales: Matriz de IDs locales (NxMx2) -> [ID_Larguerillo, ID_Costilla]

    % Inicializar salida
    cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 2);
    ids_locales = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 2); % [ID Larguerillo, ID Costilla]

    % Calcular las constantes
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

    % Iterar a través de las combinaciones de puntos
    for i = 1:size(coordenadas_f1, 1)
        for j = 1:size(coordenadas_f2, 1)
            if isinf(m1) % Línea 1 vertical
                cortes(i, j, 1) = coordenadas_f1(i, 1);
                cortes(i, j, 2) = m2 * cortes(i, j, 1) + constante_f2(j);
            elseif isinf(m2) % Línea 2 vertical
                cortes(i, j, 1) = coordenadas_f2(j, 1);
                cortes(i, j, 2) = m1 * cortes(i, j, 1) + constante_f1(i);
            else % Caso general
                if abs(m1 - m2) > eps
                    cortes(i, j, 1) = -(constante_f1(i) - constante_f2(j)) / (m1 - m2);
                    cortes(i, j, 2) = constante_f1(i) + m1 * cortes(i, j, 1);
                else
                    disp('Problema de precisión numérica: líneas casi paralelas.');
                end
            end

            % Asignar IDs Locales
            ids_locales(i, j, 1) = i; % Índice de Larguerillo (f1)
            ids_locales(i, j, 2) = j; % Índice de Costilla (f2)
        end
    end
end
