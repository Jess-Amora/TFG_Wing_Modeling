function area = calculate_quad_area_3D(coords)
    % Calculate the area of a quadrilateral in 3D space
    % Input:
    %   coords - A 4x3 matrix where each row is [x, y, z] for one vertex
    % Output:
    %   area - The total area of the quadrilateral

    % Split the quadrilateral into two triangles
    p1 = coords(1, :);
    p2 = coords(2, :);
    p3 = coords(3, :);
    p4 = coords(4, :);

    % First triangle: p1, p2, p3
    v1 = p2 - p1;
    v2 = p3 - p1;
    area1 = 0.5 * norm(cross(v1, v2));

    % Second triangle: p1, p3, p4
    v3 = p4 - p1;
    area2 = 0.5 * norm(cross(v2, v3));

    % Total area
    area = area1 + area2;
end
