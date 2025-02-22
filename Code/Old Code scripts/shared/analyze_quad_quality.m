function analyze_quad_quality(quads_processed)
% ANALYZE_QUAD_QUALITY: Checks the aspect ratio and angles of QUAD4 elements.
%
% Inputs:
%   quads_processed - Table containing processed QUAD4 elements.
%                     Must include the column 'aspect_ratio'.
%
% Outputs:
%   Prints warnings for elements with high aspect ratio or bad angles.

    fprintf('🔍 Checking QUAD4 Element Quality...\n');

    % Set Nastran limits
    max_aspect_ratio = 5;   % Max recommended aspect ratio
    min_angle_limit  = 30;  % Min interior angle for QUAD4
    max_angle_limit  = 150; % Max interior angle for QUAD4

    % 🔎 Find Bad Aspect Ratio Elements
    bad_aspect_quads = quads_processed(quads_processed.aspect_ratio > max_aspect_ratio, :);
    
    % 🔎 Find Bad Angle Elements
    bad_angle_quads = quads_processed((quads_processed.min_angle < min_angle_limit) | ...
                                      (quads_processed.max_angle > max_angle_limit), :);

    % 🔹 Display Results
    if ~isempty(bad_aspect_quads)
        fprintf('⚠️ %d QUAD4 elements have high aspect ratio (> %.1f)\n', height(bad_aspect_quads), max_aspect_ratio);
        disp(bad_aspect_quads(:, {'local_id', 'aspect_ratio'}));
    else
        fprintf('✅ All QUAD4 elements have acceptable aspect ratio.\n');
    end

    if ~isempty(bad_angle_quads)
        fprintf('⚠️ %d QUAD4 elements have bad angles (min < %d° or max > %d°)\n', ...
                height(bad_angle_quads), min_angle_limit, max_angle_limit);
        disp(bad_angle_quads(:, {'local_id', 'min_angle', 'max_angle'}));
    else
        fprintf('✅ All QUAD4 elements have acceptable angles.\n');
    end

    fprintf('🔎 QUAD4 Element Quality Check Complete.\n');
end
