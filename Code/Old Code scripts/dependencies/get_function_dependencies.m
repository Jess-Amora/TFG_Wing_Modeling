function [mainFunction, subFunctions] = get_function_dependencies(functionName, functionPath)
% GET_FUNCTION_DEPENDENCIES - Finds the main function and its sub-functions
% 
% INPUTS:
%   functionName - (string) Name of the function (e.g., 'myFunction')
%   functionPath - (string) Full path to the function file (e.g., 'C:\path\to\myFunction.m')
%
% OUTPUTS:
%   mainFunction  - (string) The name of the main function
%   subFunctions  - (cell array) List of sub-functions used by the main function
%
% EXAMPLE USAGE:
%   [mainFunc, subFuncs] = get_function_dependencies('myFunction', 'C:\path\to\myFunction.m');

    % Ensure the file exists
    if ~exist(functionPath, 'file')
        error('❌ Function file not found: %s', functionPath);
    end

    % Get dependencies of the function
    dependencyFiles = matlab.codetools.requiredFilesAndProducts(functionPath);

    % Extract the main function (first file in the list)
    mainFunction = functionName;

    % Get sub-functions (everything except the main function)
    subFunctions = dependencyFiles(2:end); % Skip the first, which is the main file

    % Remove paths and keep only function names
    for i = 1:length(subFunctions)
        [~, subFunctions{i}, ~] = fileparts(subFunctions{i});
    end

    % Display results
    disp('✅ Function Dependency Analysis Complete:');
    disp(['🔹 Main Function: ', mainFunction]);
    
    if isempty(subFunctions)
        disp('🔹 No sub-functions found.');
    else
        disp('🔹 Sub-Functions Used:');
        disp(subFunctions);
    end
end
