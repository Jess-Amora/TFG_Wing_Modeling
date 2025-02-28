function rib_properties = generate_rib_properties(nodos_anterior, nodos_posterior, airfoil, show_graph)
% GENERATE_RIB_PROPERTIES Computes the chord length (C) and thickness (H) for each rib slice.
%
%   rib_properties = generate_rib_properties(nodos_anterior, nodos_posterior, m, p, t, num_points, show_graph)
%
%   Inputs:
%       nodos_anterior  - Nx2 array containing the (x,y) coordinates of the anterior spar
%                         intersections (typically the leading-edge points of the ribs).
%       nodos_posterior - Nx2 array containing the (x,y) coordinates of the posterior spar
%                         intersections (typically the trailing-edge points of the ribs).
%       m, p, t, num_points, show_graph
%                       - Parameters for computing the NACA 6-series unit-chord airfoil.
%
%   Output:
%       rib_properties  - Table with columns:
%                         'rib_id' : Identifier for each rib (from 1 to N)
%                         'C'      : Local chord length for the rib (in the same units as input)
%                         'H'      : Local airfoil thickness computed as h_max * C, where h_max
%                                    is the maximum thickness of a unit-chord airfoil.
%
%   Description:
%       For each rib, the local chord (C) is computed as the Euclidean distance between
%       the corresponding anterior and posterior nodal coordinates. A unit-chord NACA 6-series
%       airfoil is generated (using your existing naca6series function) to obtain the maximum
%       relative thickness (h_max). The local thickness for each rib is then:
%
%           H = h_max * C
%
%   Example:
%       % Define example nodal arrays (each row: [x, y])
%       nodos_anterior = [1.0, 0.1; 2.0, 0.12; 3.0, 0.15];
%       nodos_posterior = [1.0, 0.4; 2.0, 0.42; 3.0, 0.45];
%
%       % NACA parameters:
%       m = 0.02; p = 0.4; t = 0.12; num_points = 100; show_graph = false;
%
%       % Compute rib properties
%       rib_props = generate_rib_properties(nodos_anterior, nodos_posterior, m, p, t, num_points, show_graph);
%       disp(rib_props);
%
%   This information (C and H for each rib) can then be used in your subsequent strength
%   analysis routines and exported to Patran as needed.

    
    m = airfoil.m;
    p = airfoil.p;
    t = airfoil.t;
    num_points = airfoil.num_points;
    
    % Ensure the nodal arrays have the same number of rows
    if size(nodos_anterior,1) ~= size(nodos_posterior,1)
        error('nodos_anterior and nodos_posterior must have the same number of rows.');
    end

    N = size(nodos_anterior, 1);
    C = zeros(N, 1);
    H = zeros(N, 1);

    % Compute a unit-chord NACA 6-series airfoil to obtain the maximum relative thickness
    airfoil_unit = naca6series(m, p, t, 1, num_points, show_graph);
    h_max = airfoil_unit.h_max; % Maximum thickness for a unit chord

    % Loop over each rib to compute its properties
    for i = 1:N
        % Extract coordinates for the current rib
        anterior_point = nodos_anterior(i, :);  % [x, y] from the anterior spar
        posterior_point = nodos_posterior(i, :);  % [x, y] from the posterior spar

        % Compute the chord length as the Euclidean distance in the x-y plane
        chord_length = norm(posterior_point - anterior_point);
        C(i) = chord_length;

        % Compute the rib thickness H by scaling h_max with the local chord
        H(i) = h_max * chord_length;
    end

    % Create an output table with a rib identifier, chord length, and thickness
    rib_properties = table((1:N)', C, H, 'VariableNames', {'rib_id','C','H'});
end
