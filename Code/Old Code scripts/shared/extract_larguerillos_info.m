function [num_larguerillos, larguerillo_lengths, larguerillo_data] = extract_larguerillos_info(results, plot_flag)
% EXTRACT_LARGUERILLOS_INFO Extracts and analyzes the larguerillos data from the wing mesh.
%
%   Inputs:
%       results    - Structure containing the mesh information (results.mesh.larguerillos)
%       plot_flag  - (Optional) If true, plots the larguerillos.
%
%   Outputs:
%       num_larguerillos      - Total number of stringers (larguerillos)
%       larguerillo_lengths   - Array of lengths of each larguerillo
%       larguerillo_data      - Extracted coordinate data (Nx2xM matrix)
%
%   Example:
%       [N, lengths, data] = extract_larguerillos_info(results, true);

    % Validate input
    if ~isfield(results, 'mesh') || ~isfield(results.mesh, 'larguerillos')
        error('The input "results" structure does not contain mesh.larguerillos.');
    end
    
    % Extract larguerillos from results.mesh
    larguerillo_data = results.mesh.larguerillos;  % Nx2xM (N=number of stringers, 2=x,y, M=number of points)
    
    % Get the total number of larguerillos
    num_larguerillos = size(larguerillo_data, 1);
    
    % Preallocate array for lengths
    larguerillo_lengths = zeros(num_larguerillos, 1);
    
    % Compute the length of each larguerillo
    for i = 1:num_larguerillos
        x_points = squeeze(larguerillo_data(i, 1, :));  % Extract X-coordinates
        y_points = squeeze(larguerillo_data(i, 2, :));  % Extract Y-coordinates
        % Compute total length using the Euclidean norm
        larguerillo_lengths(i) = sum(sqrt(diff(x_points).^2 + diff(y_points).^2));
    end
    
    % Display summary
    fprintf('Total number of larguerillos: %d\n', num_larguerillos);
    fprintf('Average length of larguerillos: %.3f units\n', mean(larguerillo_lengths));
    
    % Plot if requested
    if nargin > 1 && plot_flag
        figure;
        hold on; grid on;
        xlabel('X Coordinate'); ylabel('Y Coordinate');
        title('Visualization of Larguerillos');
        
        % Loop through each larguerillo and plot
        for i = 1:num_larguerillos
            x_points = squeeze(larguerillo_data(i, 1, :));
            y_points = squeeze(larguerillo_data(i, 2, :));
            plot(x_points, y_points, '-o', 'LineWidth', 1.2);
        end
        legend(arrayfun(@(i) sprintf('Larguerillo %d', i), 1:num_larguerillos, 'UniformOutput', false));
        hold off;
    end

end
