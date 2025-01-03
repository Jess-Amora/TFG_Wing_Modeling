function backup()
    % backup_data.m
    % Description: Creates a backup of the master data file.
    
    % Define source and destination paths
    sourceFile = '../Data/TFG_amora.mat';
    backupFolder = '../Data/Backups/';
    timestamp = datestr(now, 'YYYYmmDD_HHMMSS');
    backupFile = fullfile(backupFolder, ['TFG_amora_backup_', timestamp, '.mat']);
    
    % Create backup folder if it doesn't exist
    if ~exist(backupFolder, 'dir')
        mkdir(backupFolder);
    end
    
    % Copy file to backup location
    copyfile(sourceFile, backupFile);
    
    disp(['Backup created: ', backupFile]);
end
