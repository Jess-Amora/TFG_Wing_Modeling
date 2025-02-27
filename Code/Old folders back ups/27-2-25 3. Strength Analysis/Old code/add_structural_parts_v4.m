function add_structural_parts(partIndex, database_computer)
    % Adds structural components (Cajón, Larguerillo, Cordon, and NACA Wing)
    % and stores them in TFG_Amora.parts

    % ✅ Load database
    data_path = fullfile(database_computer, 'Data', 'TFG_Amora.mat');
    if exist(data_path, 'file')
        load(data_path, 'TFG_Amora');
    else
        disp('❌ Database file not found. Ensure TFG_Amora.mat exists.');
        return;
    end

    % ✅ Ensure `parts` structure exists
    if ~isfield(TFG_Amora, 'parts')
        disp('⚠️ No structural parts database found. Creating new database...');
        TFG_Amora.parts = struct();
    end

    switch partIndex
        case 1  % ✅ Create Cordon
            % ✅ Ensure `cordon` structure exists
            if ~isfield(TFG_Amora.parts, 'cordon')
                TFG_Amora.parts.cordon = struct();
            end

            % ✅ Retrieve available materials
            materialNames = fieldnames(TFG_Amora.materials);
            if isempty(materialNames)
                disp('❌ No materials available. Please add materials first.');
                return;
            end

            % ✅ Display available materials
            disp('Available Materials:');
            for i = 1:length(materialNames)
                fprintf('%d) %s\n', i, materialNames{i});
            end

            % ✅ User selects a material
            materialIndex = input('Select a material: ');
            if isnan(materialIndex) || materialIndex < 1 || materialIndex > length(materialNames)
                disp('❌ Invalid selection.');
                return;
            end
            material_name = materialNames{materialIndex};

            % ✅ Ask for Cordon dimensions
            cordon_name = input('Enter name for the new Cordon: ', 's');
            hcl = input('Enter Cordon height (mm): ');
            tcl = input('Enter Cordon thickness (mm): ');

            % ✅ Compute area
            cordon_dims.hcl = hcl * 1e-3;
            cordon_dims.tcl = tcl * 1e-3;
            A_cordon = cordon(cordon_dims);

            % ✅ Store in database
            TFG_Amora.parts.cordon.(cordon_name) = struct( ...
                'material', material_name, ...
                'hcl', cordon_dims.hcl, ...
                'tcl', cordon_dims.tcl, ...
                'A_cordon', A_cordon ...
            );

            disp(['✅ Cordon "', cordon_name, '" saved.']);
            fprintf('Cordon Area: %.6f m²\n', A_cordon);

        case 2  % ✅ Create Larguerillo
            % ✅ Ensure `larguerillo` structure exists
            if ~isfield(TFG_Amora.parts, 'larguerillo')
                TFG_Amora.parts.larguerillo = struct();
            end

            % ✅ Retrieve available materials
            materialNames = fieldnames(TFG_Amora.materials);
            if isempty(materialNames)
                disp('❌ No materials available. Please add materials first.');
                return;
            end

            % ✅ Display available materials
            disp('Available Materials:');
            for i = 1:length(materialNames)
                fprintf('%d) %s\n', i, materialNames{i});
            end

            % ✅ User selects a material
            materialIndex = input('Select a material: ');
            if isnan(materialIndex) || materialIndex < 1 || materialIndex > length(materialNames)
                disp('❌ Invalid selection.');
                return;
            end
            material_name = materialNames{materialIndex};

            % ✅ Ask for Larguerillo dimensions
            larguerillo_name = input('Enter name for the new Larguerillo: ', 's');
            type = input('Enter Larguerillo type (Z/T): ', 's');
            if ~ismember(type, {'Z', 'T'})
                disp('❌ Invalid type. Please enter "Z" or "T".');
                return;
            end

            wf = input('Enter Flange width (mm): ');
            tf = input('Enter Flange thickness (mm): ');
            hw = input('Enter Web height (mm): ');
            tw = input('Enter Web thickness (mm): ');

            wh = 0;
            th = 0;
            if strcmp(type, 'Z')
                wh = input('Enter Heel width (mm): ');
                th = input('Enter Heel thickness (mm): ');
            end

            % ✅ Compute area
            larguerillo_dims = struct('type', type, 'wf', wf * 1e-3, 'tf', tf * 1e-3, ...
                                      'hw', hw * 1e-3, 'tw', tw * 1e-3, 'wh', wh * 1e-3, 'th', th * 1e-3);
            A_larguerillo = larguerillo(larguerillo_dims);

            % ✅ Store in database
            TFG_Amora.parts.larguerillo.(larguerillo_name) = struct( ...
                'material', material_name, ...
                'type', type, ...
                'wf', larguerillo_dims.wf, ...
                'tf', larguerillo_dims.tf, ...
                'hw', larguerillo_dims.hw, ...
                'tw', larguerillo_dims.tw, ...
                'wh', larguerillo_dims.wh, ...
                'th', larguerillo_dims.th, ...
                'A_larguerillo', A_larguerillo ...
            );

            disp(['✅ Larguerillo "', larguerillo_name, '" saved.']);
            fprintf('Larguerillo Area (%s): %.6f m²\n', type, A_larguerillo);

        case 3  % ✅ Create Cajón
            % ✅ Ensure `cajon` structure exists
            if ~isfield(TFG_Amora.parts, 'cajon')
                TFG_Amora.parts.cajon = struct();
            end

            % ✅ Select Cordon
            cordonNames = fieldnames(TFG_Amora.parts.cordon);
            if isempty(cordonNames)
                disp('❌ No Cordons available. Add a Cordon first.');
                return;
            end

            % ✅ Select Larguerillo
            larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
            if isempty(larguerilloNames)
                disp('❌ No Larguerillos available. Add a Larguerillo first.');
                return;
            end

            % ✅ Ask for Cajón dimensions
            cajon_name = input('Enter name for the new Cajón: ', 's');
            H = input('Enter Box height H (mm): ');
            C = input('Enter Box width C (mm): ');
            tss = input('Enter Upper skin thickness tss (mm): ');
            tsi = input('Enter Lower skin thickness tsi (mm): ');
            tl = input('Enter Spar thickness tl (mm): ');

            % ✅ Store in database
            TFG_Amora.parts.cajon.(cajon_name) = struct( ...
                'H', H * 1e-3, ...
                'C', C * 1e-3, ...
                'tss', tss * 1e-3, ...
                'tsi', tsi * 1e-3, ...
                'tl', tl * 1e-3 ...
            );

            disp(['✅ Cajón "', cajon_name, '" saved.']);

        otherwise
            disp('❌ Invalid option.');
            return;
    end

    % ✅ Save database **after all modifications**
    save(data_path, 'TFG_Amora');
    disp('✅ Structural part creation saved.');
end
