% Define points
points = [0, 0, 0; 
    1, 0, 1; 
    1, 1, 0; 
    0, 1, 1]; % [x, y, z]

% Define relationships (elements)
% Each row defines an element using the indices of the points
elements = [1, 2; % Element 1 connects Point 1 to Point 2
            2, 3; % Element 2 connects Point 2 to Point 3
            3, 1 % Element 3 connects Point 3 to Point 4
            ]; % Element 4 connects Point 4 to Point 1

% Save points to a .csv file
points_table = array2table(points, 'VariableNames', {'x', 'y', 'z'});
writetable(points_table, './output/points.csv');

% Save elements to a .csv file
elements_table = array2table(elements, 'VariableNames', {'Point1', 'Point2'});
writetable(elements_table, './output/lines.csv');

disp('Geometry and relationships exported to CSV files.');
