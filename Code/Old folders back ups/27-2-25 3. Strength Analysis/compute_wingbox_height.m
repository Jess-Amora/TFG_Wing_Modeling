function h_values = compute_wingbox_height(airfoil, chord_distribution)
    % Computes the height (h) of the wing box along the spanwise direction
    % using the given chord distribution and NACA 6-series airfoil struct.
    %
    % Inputs:
    %   - airfoil: Struct containing NACA 6-series airfoil data
    %   - chord_distribution: Vector of chord lengths along the span
    %
    % Output:
    %   - h_values: Computed wing box heights along the spanwise direction
    
    num_sections = length(chord_distribution); % Number of sections along the wing
    h_values = zeros(1, num_sections); % Initialize h values
    
    for i = 1:num_sections
        c = chord_distribution(i); % Chord at this section
        
        % Scale the maximum thickness based on the local chord
        h_max = airfoil.h_max * (c / airfoil.c);
        
        % Approximate effective wing box height (70% of max thickness)
        h_values(i) = 0.7 * h_max;
    end
    
    disp('✅ Wing box height computed successfully along the span.');
end
