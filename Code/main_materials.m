databasePath='C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root'; % Change to actual path
outputFile = '..\Data\rod_model.bdf'; % Output BDF filename
material_name = 'Aluminum_7075_T6'; % Name of material (must exist in database)
area = 0.036; % Cross-sectional area (m²)

write_rod_to_bdf(databasePath, outputFile, material_name, area);

