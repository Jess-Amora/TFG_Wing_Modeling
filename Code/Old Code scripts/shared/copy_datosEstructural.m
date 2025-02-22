function copy_datosEstructural(sourceName, newName)
    % Load existing data
    if isfile('datosEstructural.mat')
        load('datosEstructural.mat', 'TFG_Amora');  % Load previous structure
    else
        error('❌ No existing datosEstructural file found. Create one first.');
    end

    % Check if source entry exists
    if ~isfield(TFG_Amora.datosEstructural, sourceName)
        error('❌ The entry "%s" does not exist in datosEstructural.', sourceName);
    end

    % Check if newName already exists
    if isfield(TFG_Amora.datosEstructural, newName)
        warning('⚠️ The entry "%s" already exists in datosEstructural. No changes were made.', newName);
        return; % Exit the function to prevent overwriting
    end

    % Copy data to new name
    TFG_Amora.datosEstructural.(newName) = TFG_Amora.datosEstructural.(sourceName);

    % Save updated structure
    save('datosEstructural.mat', 'TFG_Amora');
    
    fprintf('✅ datosEstructural "%s" copied successfully to "%s".\n', sourceName, newName);
end
