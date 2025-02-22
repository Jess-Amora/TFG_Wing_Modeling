function [allFunctions] = get_function_dependencies_recursive(functionPath, checkedFunctions)
% GET_FUNCTION_DEPENDENCIES_RECURSIVE - Recursively finds all dependencies of a function
%
% INPUTS:
%   functionPath     - (string) Full path to the function (e.g., 'C:\path\to\myFunction.m')
%   checkedFunctions - (cell array, optional) List of already checked functions to avoid loops
%
% OUTPUT:
%   allFunctions - (cell array) List of all functions used (main + sub-functions)
%
% EXAMPLE USAGE:
%   dependencies = get_function_dependencies_recursive('C:\path\to\myFunction.m');

    % Ensure the file exists
    if ~exist(functionPath, 'file')
        error('❌ Function file not found: %s', functionPath);
    end

    % Get dependencies of the function
    dependencyFiles = matlab.codetools.requiredFilesAndProducts(functionPath);

    % Extract function names (remove paths)
    currentFunctions = cell(size(dependencyFiles));
    for i = 1:length(dependencyFiles)
        [~, currentFunctions{i}, ~] = fileparts(dependencyFiles{i});
    end

    % If this is the first call, initialize checked functions
    if nargin < 2
        checkedFunctions = {};
    end

    % Merge found functions with checked ones (avoid duplicates)
    allFunctions = unique([checkedFunctions, currentFunctions]);

    % Recursively check each sub-function
    for i = 2:length(currentFunctions) % Skip first because it's the main function
        subFunctionName = currentFunctions{i};

        % Check if this function has already been processed
        if ismember(subFunctionName, checkedFunctions)
            continue; % Skip to avoid infinite loops
        end

        % Find the actual file path of this function
        subFunctionPath = which(subFunctionName);
        
        % If the sub-function is found (not built-in), recurse
        if ~isempty(subFunctionPath)
            subDependencies = get_function_dependencies_recursive(subFunctionPath, allFunctions);
            allFunctions = unique([allFunctions, subDependencies]);
        end
    end

    % Display results
    if nargin < 2  % Only display when the first function is called
        disp('✅ Recursive Function Dependency Analysis Complete:');
        disp(['🔹 Main Function: ', currentFunctions{1}]);
        
        if length(allFunctions) == 1
            disp('🔹 No sub-functions found.');
        else
            disp('🔹 All Functions Used (including nested calls):');
            disp(allFunctions(2:end)); % Skip main function in display
        end
    end
end
