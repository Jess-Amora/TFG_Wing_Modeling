function nodos = interleave_coordinates(u, v)
    % Interleave two sets of coordinates (u and v) and check ascending order.
    % Each u_i alternates with v_i in the resulting nodos array.
    % 
    % Inputs:
    %   u: 2xN matrix (coordinates)
    %   v: 2xM matrix (coordinates)
    %
    % Output:
    %   nodos: 2x(N+M) matrix with interleaved coordinates
    
    % Ensure inputs are 2xN
    if size(u, 1) ~= 2 || size(v, 1) ~= 2
        error('Both u and v must be 2xN matrices.');
    end
    
    % Sizes
    N_u = size(u, 2); % Number of columns in u
    N_v = size(v, 2); % Number of columns in v
    
    % Initialize output
    nodos = zeros(2, N_u + N_v);
    
    % Determine minimum size for interleaving
    min_size = min(N_u, N_v);
    
    % Interleave u and v
    nodos(:, 1:2:(2*min_size)) = u(:, 1:min_size);
    nodos(:, 2:2:(2*min_size)) = v(:, 1:min_size);
    
    % Append remaining elements if sizes differ
    if N_u > N_v
        nodos(:, 2*min_size+1:end) = u(:, min_size+1:end);
    elseif N_v > N_u
        nodos(:, 2*min_size+1:end) = v(:, min_size+1:end);
    end
    

    
    % % Check if nodos is in ascending order
    % ascending_x = all(diff(nodos(1, :)) >= 0);
    % ascending_y = all(diff(nodos(2, :)) >= 0);
    
    % if ascending_x && ascending_y
    %     disp('Nodos are in ascending order.');
    % else
    %     disp('Nodos are NOT in ascending order.');
    % end
end
