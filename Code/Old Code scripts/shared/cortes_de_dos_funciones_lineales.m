function cortes = cortes_de_dos_funciones_lineales(coordenadas_f1, m1, coordenadas_f2, m2)
% Versión con precisión
    % Esta función calcula las intersecciones de dos funciones lineales
    % Definidas por sus coordenadas y pendientes.
    %
    % Inputs:
    %   coordenadas_f1: Nx2 matrix of [x, y] points for line 1
    %   m1: Slope of line 1
    %   coordenadas_f2: Mx2 matrix of [x, y] points for line 2
    %   m2: Slope of line 2
    %
    % Output:
    %   cortes: Intersection points as NxMx2 matrix

    % Initialize output
    cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 2);
    tolerance = 1e-8; % Adjustable tolerance for numerical comparisons

    % Compute constants for non-vertical lines
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

    % Check for parallel or coincident lines
    if abs(m1 - m2) < tolerance
        if all(abs(constante_f1 - constante_f2) < tolerance)
            disp('The lines are coincident: infinite intersections.');
        else
            disp('The lines are parallel: no intersections.');
        end
        return;
    end

    % Iterate through all combinations of points
    for i = 1:size(coordenadas_f1, 1)
        for j = 1:size(coordenadas_f2, 1)
            if isinf(m1) % Line 1 is vertical
                cortes(i, j, 1) = coordenadas_f1(i, 1); % x-coordinate
                cortes(i, j, 2) = m2 * cortes(i, j, 1) + constante_f2(j); % y from Line 2
            elseif isinf(m2) % Line 2 is vertical
                cortes(i, j, 1) = coordenadas_f2(j, 1); % x-coordinate
                cortes(i, j, 2) = m1 * cortes(i, j, 1) + constante_f1(i); % y from Line 1
            elseif abs(m1) < tolerance % Line 1 is nearly horizontal
                cortes(i, j, 1) = (coordenadas_f1(i, 2) - constante_f2(j)) / m2;
                cortes(i, j, 2) = coordenadas_f1(i, 2);
            elseif abs(m2) < tolerance % Line 2 is nearly horizontal
                cortes(i, j, 1) = (coordenadas_f2(j, 2) - constante_f1(i)) / m1;
                cortes(i, j, 2) = coordenadas_f2(j, 2);
            else % General case
                % Improve numerical stability by rearranging terms
                delta_constante = constante_f1(i) - constante_f2(j);
                delta_slope = m1 - m2;
                
                if abs(delta_slope) > tolerance
                    cortes(i, j, 1) = -delta_constante / delta_slope;
                    cortes(i, j, 2) = constante_f1(i) + m1 * cortes(i, j, 1);
                else
                    disp('Numerical precision issue: lines appear nearly parallel.');
                end
            end
        end
    end
end


% function cortes = cortes_de_dos_funciones_lineales(coordenadas_f1, m1, coordenadas_f2, m2)
%     % Esta función calcula las intersecciones de dos funciones lineales
%     % Definidas por sus coordenadas y pendientes.
% 
%     % Initialize output
%     cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 2);
% 
%     % Compute constants for non-vertical and horizontal lines
%     if ~isinf(m1)
%         if m1 == 0 % Line 1 is horizontal
%             constante_f1 = coordenadas_f1(:, 2); % y0 is constant
%         else
%             constante_f1 = coordenadas_f1(:, 2) - m1 * coordenadas_f1(:, 1);
%         end
%     end
% 
%     if ~isinf(m2)
%         if m2 == 0 % Line 2 is horizontal
%             constante_f2 = coordenadas_f2(:, 2); % y0 is constant
%         else
%             constante_f2 = coordenadas_f2(:, 2) - m2 * coordenadas_f2(:, 1);
%         end
%     end
% 
%     % Check for parallel or coincident lines
%     if m1 == m2 && ~isinf(m1) && ~isinf(m2)
%         if all(constante_f1 == constante_f2)
%             disp('The lines are coincident: infinite intersections.');
%         else
%             disp('The lines are parallel: no intersections.');
%         end
%         return;
%     end
% 
%     % Iterate through all combinations of points
%     for i = 1:size(coordenadas_f1, 1)
%         for j = 1:size(coordenadas_f2, 1)
%             if isinf(m1) % Line 1 is vertical
%                 cortes(i, j, 1) = coordenadas_f1(i, 1); % x-coordinate
%                 cortes(i, j, 2) = constante_f2(j); % y from Line 2 (horizontal or sloped)
%             elseif isinf(m2) % Line 2 is vertical
%                 cortes(i, j, 1) = coordenadas_f2(j, 1); % x-coordinate
%                 cortes(i, j, 2) = constante_f1(i); % y from Line 1 (horizontal or sloped)
%             elseif m1 == 0 % Line 1 is horizontal
%                 cortes(i, j, 1) = (coordenadas_f1(i, 2) - constante_f2(j)) / m2;
%                 cortes(i, j, 2) = coordenadas_f1(i, 2); % y is constant
%             elseif m2 == 0 % Line 2 is horizontal
%                 cortes(i, j, 1) = (coordenadas_f2(j, 2) - constante_f1(i)) / m1;
%                 cortes(i, j, 2) = coordenadas_f2(j, 2); % y is constant
%             else % General case
%                 if abs(m1 - m2) > eps % Avoid division by zero for near-equal slopes
%                     cortes(i, j, 1) = -(constante_f1(i) - constante_f2(j)) / (m1 - m2);
%                     cortes(i, j, 2) = constante_f1(i) + m1 * cortes(i, j, 1);
%                 else
%                     disp('Numerical precision issue: lines appear parallel.');
%                 end
%             end
%         end
%     end
% end

% function cortes = cortes_de_dos_funciones_lineales(coordenadas_f1, m1, coordenadas_f2, m2)
%     % Esta función calcula las intersecciones de dos funciones lineales
%     % Definidas por sus coordenadas y pendientes.
% 
%     % Initialize output
%     cortes = zeros(size(coordenadas_f1, 1), size(coordenadas_f2, 1), 2);
% 
%     % Compute constants for non-vertical lines
%     if ~isinf(m1)
%         constante_f1 = coordenadas_f1(:, 2) - m1 * coordenadas_f1(:, 1);
%     elseif m1 == inf
%         constante_f1 = coordenadas_f1(:,2);
%     end
% 
%     if ~isinf(m2)
%         constante_f2 = coordenadas_f2(:, 2) - m2 * coordenadas_f2(:, 1);
%     elseif m2 == inf
%         constante_f2 = coordenadas_f2(:,2);
%     end
% 
%     % Check for parallel or coincident lines
%     if m1 == m2 && ~isinf(m1) && ~isinf(m2)
%         if all(constante_f1 == constante_f2)
%             disp('The lines are coincident: infinite intersections.');
%         else
%             disp('The lines are parallel: no intersections.');
%         end
%         return;
%     end
% 
%     % Iterate through all combinations of points
%     for i = 1:size(coordenadas_f1, 1)
%         for j = 1:size(coordenadas_f2, 1)
%             if isinf(m1) % Line 1 is vertical
%                 cortes(i, j, 1) = coordenadas_f1(i, 1); % x-coordinate
%                 cortes(i, j, 2) = m2 * cortes(i, j, 1) + constante_f2(j); % y from Line 2
%             elseif isinf(m2) % Line 2 is vertical
%                 cortes(i, j, 1) = coordenadas_f2(j, 1); % x-coordinate
%                 cortes(i, j, 2) = m1 * cortes(i, j, 1) + constante_f1(i); % y from Line 1
%             elseif m1 == 0 % Line 1 is horizontal
%                 cortes(i, j, 1) = (coordenadas_f1(i, 2) - constante_f2(j)) / m2;
%                 cortes(i, j, 2) = coordenadas_f1(i, 2); % y is constant
%             elseif m2 == 0 % Line 2 is horizontal
%                 cortes(i, j, 1) = (coordenadas_f2(j, 2) - constante_f1(i)) / m1;
%                 cortes(i, j, 2) = coordenadas_f2(j, 2); % y is constant
%             else % General case
%                 if abs(m1 - m2) > eps % Avoid division by zero for near-equal slopes
%                     cortes(i, j, 1) = -(constante_f1(i) - constante_f2(j)) / (m1 - m2);
%                     cortes(i, j, 2) = constante_f1(i) + m1 * cortes(i, j, 1);
%                 else
%                     disp('Numerical precision issue: lines appear parallel.');
%                 end
%             end
%         end
%     end
% end
% 
% 
% % function cortes = cortes_de_dos_funciones_lineales(coordenadas_f1,m1,coordenadas_f2,m2)
% %     % Esta función calculan las intersecciónes de dos funciones líneales en
% %     % función de sus coordenadas y sus pendientes de forma:
% %     % La dimensión de cortes es (MxNx2) que es una función de las 
% %     % coordenadas_f1 (M x 2), coordenadas_f1 (N x 2), m1 y m2
% % 
% %     cortes = zeros (size(coordenadas_f1,1),size(coordenadas_f2,1),2);
% %     constante_f1 = coordenadas_f1(:,2) - m1 * coordenadas_f1(:,1);
% %     constante_f2 = coordenadas_f2(:,2) - m2 * coordenadas_f2(:,1);
% % 
% % 
% % 
% %     if m1 == m2
% %         if all(constante_f1 == constante_f2)
% %             disp('The lines are coincident: infinite intersections.');
% %         else
% %             disp('The lines are parallel: no intersections.');
% %         end
% %         return;
% %     end
% % 
% %     for i = 1:size(coordenadas_f1,1)
% %         for j = 1:size(coordenadas_f2,1)    
% % 
% %             if isinf(m1)
% %                 cortes(i,j,1) = coordenadas_f1(i,1);
% %                 cortes(i,j,2) = constante_f2(j) + m2 * cortes(i,j,1);
% %             elseif isinf(m2)
% %                 cortes(i,j,1) = coordenadas_f2(j,1);
% %                 cortes(i,j,2) = constante_f1(i) + m1 * cortes(i,j,1);
% %             elseif m1 == 0
% %                 cortes(i,j,1) = (coordenadas_f1(i,2) - constante_f2(j))/m2;
% %                 cortes(i,j,2) = coordenadas_f1(i,2);
% %             elseif m2 == 0
% %                 cortes(i,j,1) = (coordenadas_f2(j,2) - constante_f1(i))/m1;
% %                 cortes(i,j,2) = coordenadas_f2(j,2);
% %             elseif m1 ~= 0
% %                 cortes(i,j,1) = -(constante_f1(i) - constante_f2(j)) / (m1-m2);
% %                 cortes(i,j,2) = constante_f1(i) + m1 * cortes(i,j,1);
% % 
% %             end
% %         end
% %     end
% % end
% % 
% % 
% % % function cortes = cortes_de_dos_funciones_lineales(coordenadas_f1,m1,coordenadas_f2,m2)
% % %     % Esta función calculan las intersecciónes de dos funciones líneales en
% % %     % función de sus coordenadas y sus pendientes de forma:
% % %     % La dimensión de cortes es (MxNx2) que es una función de las 
% % %     % coordenadas_f1 (M x 2), coordenadas_f1 (N x 2), m1 y m2
% % % 
% % %     cortes = zeros (size(coordenadas_f1,1),size(coordenadas_f2,1),2);
% % %     constante_f1 = coordenadas_f1(:,2) - m1 * coordenadas_f1(:,1);
% % %     constante_f2 = coordenadas_f2(:,2) - m2 * coordenadas_f2(:,1);
% % % 
% % % 
% % % 
% % %     if m1 == m2
% % %         if all(constante_f1 == constante_f2)
% % %             disp('The lines are coincident: infinite intersections.');
% % %         else
% % %             disp('The lines are parallel: no intersections.');
% % %         end
% % %         return;
% % %     end
% % % 
% % %     for i = 1:size(coordenadas_f1,1)
% % %         for j = 1:size(coordenadas_f2,1)    
% % % 
% % %             if m1 == 0
% % %                 cortes(i,j,1) = coordenadas_f1(i,1);
% % %                 cortes(i,j,2) = constante_f2(j) + m2 * cortes(i,j,1);
% % %             elseif m2 == 0
% % %                 cortes(i,j,1) = coordenadas_f2(j,1);
% % %                 cortes(i,j,2) = constante_f1(i) + m1 * cortes(i,j,1);
% % % 
% % %             elseif m1 ~= 0
% % %                 cortes(i,j,1) = -(constante_f1(i) - constante_f2(j)) / (m1-m2);
% % %                 cortes(i,j,2) = constante_f1(i) + m1 * cortes(i,j,1);
% % % 
% % %             end
% % %         end
% % %     end
% % % end
% % % 