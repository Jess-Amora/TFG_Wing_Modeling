
addpath('./shared');
% % folderPath = 'C:\Users\jessa\OneDrive\generate_structure.m';
% folderPath = "C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root\Code\4. Generate FEA Structure\Method1";
% filename = 'generate_structure';
% folderPath = "C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root\Code\4. Generate FEA Structure\Method1\generate_structure.m";

% [mainFunc, subFuncs] = get_function_dependencies(filename,folderPath);
% dependencies = get_function_dependencies_recursive(folderPath);

% depAnalyzer = matlab.codetools.analysis.FunctionDependencies(folderPath);
% dependencies = depAnalyzer.getDependencies();
% disp(dependencies);

folderPath = "C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root\Code\4. Generate FEA Structure\Method1\generate_structure.m";
% functionDependencies = matlab.codetools.requiredFilesAndProducts(folderPath);
% disp(functionDependencies);

dependencies = get_recursive_dependencies(folderPath);
