function allFunctions = get_recursive_dependencies(functionPath, checkedFiles)
% GET_RECURSIVE_DEPENDENCIES - Recursively finds all functions used in a MATLAB function.
%
% INPUTS:
%   functionPath - Full path to the main function (e.g., 'C:\path\to\myFunction.m')
%   checkedFiles - (optional) Cell array of already checked files to prevent loops.
%
% OUTPUT:
%   allFunctions - Cell array of all user-defined functions used.
%
% USAGE:
%   dependencies = get_recursive_dependencies('C:\path\to\myFunction.m');

    if nargin < 2
        checkedFiles = {};
    end

    % Ensure function file exists
    if ~exist(functionPath, 'file')
        error('❌ Function file not found: %s', functionPath);
    end

    % Get dependencies
    dependencies = matlab.codetools.requiredFilesAndProducts(functionPath);

    % Extract unique functions
    newFunctions = setdiff(dependencies, checkedFiles);
    allFunctions = unique([checkedFiles, newFunctions]);

    % Recursively check sub-functions
    for i = 2:length(newFunctions) % Skip the first file (main function)
        subFuncPath = newFunctions{i};
        subDependencies = get_recursive_dependencies(subFuncPath, allFunctions);
        allFunctions = unique([allFunctions, subDependencies]);
    end

    % Display results (only for top-level call)
    if nargin < 2
        disp('✅ Recursive Function Dependency Analysis Complete:');
        disp('🔹 All Functions Used (including nested calls):');
        disp(allFunctions);
    end
end
