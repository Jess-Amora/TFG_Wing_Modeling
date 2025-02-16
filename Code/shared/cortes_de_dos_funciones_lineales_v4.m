function cortes = cortes_de_dos_funciones_lineales_v4(coordenadas_f1, m1, coordenadas_f2, m2, indices_f1, indices_f2)
% cortes_de_dos_funciones_lineales_v3 calculates intersections between two sets of lines.
% 
% Inputs:
%   coordenadas_f1: Nx2 matrix [x, y] for line 1 (e.g., stringers)
%   m1: slope of line 1
%   coordenadas_f2: Mx2 matrix [x, y] for line 2 (e.g., rib-to-rib midpoints)
%   m2: slope of line 2
%   indices_f1 (optional): vector of indices for line 1 (N elements)
%   indices_f2 (optional): vector of indices for line 2 (M elements)
%
% Output:
%   cortes: NxMx4 matrix, where for each combination:
%         (x, y, index_line1, index_line2)
%
% If indices_f1 or indices_f2 are not provided, they are automatically created.
    
    cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 4);
    tolerance = 1e-8;
    
    % Create index vectors if not provided
    if nargin < 5 || isempty(indices_f1)
        indices_f1 = (1:size(coordenadas_f1, 1))';
    end
    if nargin < 6 || isempty(indices_f2)
        if size(coordenadas_f2, 1) == 1
            indices_f2 = 1;
        else
            indices_f2 = (1:size(coordenadas_f2, 1))';
        end
    end
    
    % Calculate constants for the lines
    if ~isinf(m1)
        constante_f1 = coordenadas_f1(:,2) - m1 * coordenadas_f1(:,1);
    else
        constante_f1 = coordenadas_f1(:,2);
    end
    if ~isinf(m2)
        constante_f2 = coordenadas_f2(:,2) - m2 * coordenadas_f2(:,1);
    else
        constante_f2 = coordenadas_f2(:,2);
    end
    
    % Check if the lines are parallel
    if abs(m1 - m2) < tolerance
        if all(abs(constante_f1 - constante_f2) < tolerance)
            disp('Las líneas son coincidentes: intersecciones infinitas.');
        else
            disp('Las líneas son paralelas: no hay intersecciones.');
        end
        return;
    end
    
    % Compute intersections for each combination
    for i = 1:size(coordenadas_f1,1)
        for j = 1:size(coordenadas_f2,1)
            if isinf(m1)  % Vertical line 1
                cortes(i,j,1) = coordenadas_f1(i,1);
                cortes(i,j,2) = m2 * cortes(i,j,1) + constante_f2(j);
            elseif isinf(m2)  % Vertical line 2
                cortes(i,j,1) = coordenadas_f2(j,1);
                cortes(i,j,2) = m1 * cortes(i,j,1) + constante_f1(i);
            elseif abs(m1) < tolerance  % Line 1 almost horizontal
                cortes(i,j,1) = (coordenadas_f1(i,2) - constante_f2(j)) / m2;
                cortes(i,j,2) = coordenadas_f1(i,2);
            elseif abs(m2) < tolerance  % Line 2 almost horizontal
                cortes(i,j,1) = (coordenadas_f2(j,2) - constante_f1(i)) / m1;
                cortes(i,j,2) = coordenadas_f2(j,2);
            else
                delta_constante = constante_f1(i) - constante_f2(j);
                delta_slope = m1 - m2;
                if abs(delta_slope) > tolerance
                    cortes(i,j,1) = -delta_constante / delta_slope;
                    cortes(i,j,2) = constante_f1(i) + m1 * cortes(i,j,1);
                else
                    disp('Problema de precisión numérica: las líneas parecen casi paralelas.');
                end
            end
            cortes(i,j,3) = indices_f1(i); % Store index for line 1
            cortes(i,j,4) = indices_f2(j); % Store index for line 2
        end
    end
end
