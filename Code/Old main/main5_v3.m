clear all;
addpath('./5. FEA validation');

%% 🔹 Step 1: Load Database
database_computer = 'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root';
data_path = fullfile(database_computer, "Data");
load(fullfile(data_path, 'TFG_Amora.mat'), 'TFG_Amora');

%% 🔹 Step 2: User Selects Aircraft
disp('----------------------------------------');
disp('🛩 Select an Aircraft to Process:');
avionNames = fieldnames(TFG_Amora.aviones);

if isempty(avionNames)
    disp('⚠️ No aircraft available. Please add data first.');
    return;
end

for i = 1:length(avionNames)
    fprintf('%d) %s\n', i, avionNames{i});
end
fprintf('%d) 🔙 Return to Main Menu\n', length(avionNames) + 1);

avionIndex = input('Select an option: ', 's');
avionIndex = str2double(avionIndex);

if isnan(avionIndex) || avionIndex < 1 || avionIndex > (length(avionNames) + 1)
    disp('❌ Invalid selection. Returning to menu.');
    return;
end

if avionIndex == length(avionNames) + 1
    disp('🔙 Returning to Main Menu...');
    run('main_menu.m');
    return;
end

name = avionNames{avionIndex}; 
disp(['✅ Selected Aircraft: ', name]);
avion = TFG_Amora.aviones.(name);

%% 🔹 Step 3: Plotting Geometry
plotFunctions = { ...
    'plotAla2D', ...
    'plotAla2Dlarguerillo', ...
    'plotAla2D_costillas', ...
    'plotAla2D_costillas_larguerillos', ...
    'plotAla2D_mesh_nodos', ...
    'plotAla2Dlarguerillo_fuselaje', ...
    'plotAla2Dcostilla_fuselaje', ...
    'plotAla2D_costillas_larguerillo_fuselaje', ...
    'plotAla2Dcostilla_total', ...
    'plotAla2Dlarguerillo_total', ...
    'plotAla2Dcostilla_larguerillo_total' ...
};

disp('🛩 Starting Plotting Process');
disp('----------------------------------------');

for i = 1:length(plotFunctions)
    funcName = plotFunctions{i};
    disp(['🛩 Plotting: ', strrep(funcName, '_', ' ')]);
    try
        feval(funcName, avion);
    catch ME
        warning('⚠️ Error in %s: %s', funcName, ME.message);
    end
    disp('----------------------------------------');
end

%% 🔹 Step 4: Plotting Forces (Example Placeholder)
disp('🛩 Plotting: Forces');
plotFunctions = { ...
    'plotAla2D_weight_wing_n_ult', ...
    'plotAla2D_weight_wing_n_lim', ...
    'plotAla2D_weight_wing_n1', ...
    'plotAla2D_fuerzas_L_sust', ...
    'plotAla2D_fuerzas_l', ...
    'plotAla2D_V_n_lim', ...
    'plotAla2D_V_n_ult', ...
    'plotAla2D_V_n1'...
};
disp('🛩 Starting Plotting Process');
disp('----------------------------------------');

for i = 1:length(plotFunctions)
    funcName = plotFunctions{i};
    disp(['🛩 Plotting: ', strrep(funcName, '_', ' ')]);
    try
        feval(funcName, avion);
    catch ME
        warning('⚠️ Error in %s: %s', funcName, ME.message);
    end
    disp('----------------------------------------');
end
