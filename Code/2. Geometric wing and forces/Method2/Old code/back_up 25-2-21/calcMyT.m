function [My, T] = calcMyT(V_front, V_rear, R_anterior, R_posterior, y_shear)
% calcMyT  Compute bending and torsional moments in the wing box.
%
%   [My, T] = calcMyT(V_front, V_rear, R_anterior, R_posterior, y_shear)
%
%   Inputs:
%     V_front    - Vertical force vector at front spar/rib intersections.
%     V_rear     - Vertical force vector at rear spar/rib intersections.
%     R_anterior - [N x 2] matrix of coordinates [x, y] for the front spar.
%     R_posterior- [N x 2] matrix of coordinates [x, y] for the rear spar.
%     y_shear    - Estimated shear center offset from the midpoint (scalar).
%
%   Outputs:
%     My - Bending moment about the y-axis along the span (computed with spanwise summation).
%     T  - Torsional moment about the x-axis at each rib section.

% Ensure column vectors
V_front = V_front(:);
V_rear  = V_rear(:);

% Number of rib sections
N = length(V_front);

% Compute the reference point for moment calculations (shear center correction)
r_ref = (R_anterior + R_posterior) / 2;  % Midpoint of the spars
r_ref(:,2) = r_ref(:,2) + y_shear;        % Apply shear center offset

% Compute lever arms relative to the reference point
r_ant = R_anterior - r_ref;    % [dx, dy] for front spar
r_post = R_posterior - r_ref;  % [dx, dy] for rear spar

% Compute moment contributions using cross-product formulation:
% M = [dy * F ; -dx * F]
M_ant = [r_ant(:,2) .* V_front, -r_ant(:,1) .* V_front];
M_post = [r_post(:,2) .* V_rear, -r_post(:,1) .* V_rear];

% Compute local torsional and bending moments
M_local = M_ant + M_post;
T_local = M_local(:,1);    % Local torsion at each rib
My_local = M_local(:,2);   % Local bending moment contribution

% Compute spanwise bending moment distribution (My(x))
My = zeros(N,1);
for i = 1:N
    for j = i:N  % Sum all forces acting aft of x_i
        My(i) = My(i) + (V_front(j) * (R_anterior(j,1) - R_anterior(i,1))) + ...
                        (V_rear(j) * (R_posterior(j,1) - R_posterior(i,1)));
    end
end

% Define outputs
T = T_local;
end
