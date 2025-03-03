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

disp('🛩 Starting Plotting Process');
disp('----------------------------------------');
%% 🔹 Step 3: Plotting Geometry
disp('🛩 Starting Plotting geometry');
tileAllSavedPlots_geometry(avion)

%% 🔹 Step 4: Plotting Forces (Example Placeholder)
disp('🛩 Starting Plotting forces');
tileAllSavedPlots_forces(avion)