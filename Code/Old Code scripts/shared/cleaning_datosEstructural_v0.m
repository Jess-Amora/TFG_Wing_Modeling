% Get all field names in datosEstructural
structuralFields = fieldnames(TFG_Amora.datosEstructural);

% Loop through each field and check if it's a structure
for i = 1:length(structuralFields)
    fieldName = structuralFields{i};

    % If the field is NOT a structure, remove it
    if ~isstruct(TFG_Amora.datosEstructural.(fieldName))
        TFG_Amora.datosEstructural = rmfield(TFG_Amora.datosEstructural, fieldName);
    end
end

% Save the cleaned database
save(databasePath, 'TFG_Amora');
disp('✅ Cleaned structural parameters database.');
