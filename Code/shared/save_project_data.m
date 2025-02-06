function save_project_data(filename, varargin)
% SAVE_PROJECT_DATA: Saves selected project data into a structured .mat file.
%
% Inputs:
%   filename  - Name of the output .mat file (including path).
%   varargin  - Name-Value pairs where:
%               Name  = Variable name (string).
%               Value = Corresponding variable data.
%
% Example Usage:
%   save_project_data('..\Results\Data\project_data.mat', ...
%                     'lines', lines, 'quads', quads, 'tri', tri, 'BC', BC);
%
% Output:
%   Saves the structured data in a .mat file, creating the directory if needed.

    % ✅ Ensure filename is provided
    if nargin < 1 || isempty(filename)
        error('❌ ERROR: You must specify a filename.');
    end

    % ✅ Ensure the directory exists
    output_dir = fileparts(filename);
    if ~isempty(output_dir) && ~exist(output_dir, 'dir')
        mkdir(output_dir);
        fprintf('📁 Created directory: %s\n', output_dir);
    end

    % ✅ Initialize struct
    project_data = struct();

    % ✅ Process Name-Value Pairs
    if mod(length(varargin), 2) ~= 0
        error('❌ ERROR: Inputs must be provided as Name-Value pairs.');
    end

    for i = 1:2:length(varargin)
        var_name = varargin{i};   % Variable name (string)
        var_value = varargin{i+1}; % Variable data

        % ✅ Ensure var_name is a valid string
        if ~ischar(var_name) && ~isstring(var_name)
            error('❌ ERROR: Variable names must be strings.');
        end

        % ✅ Add to struct
        project_data.(char(var_name)) = var_value;
    end

    % ✅ Save the structure
    save(filename, '-struct', 'project_data');

    fprintf('✅ Project data saved successfully to %s\n', filename);
end
