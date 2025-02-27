function add_structural_parts(partIndex, database_computer, avion)
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
    if ~isfield(TFG_Amora.parts, 'cordon')
        TFG_Amora.parts.cordon = struct(); % ✅ Create empty struct if missing
    end
    if ~isfield(TFG_Amora.parts, 'larguerillo')
        TFG_Amora.parts.larguerillo = struct();
    end
    if ~isfield(TFG_Amora.parts, 'cajon')
        TFG_Amora.parts.cajon = struct();
    end

    switch partIndex
        case 1  % ✅ Create Cordon
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
            disp('📦 Creating Cajón...');
            
            % ✅ Ensure Cordón and Larguerillo exist
            if isempty(fieldnames(TFG_Amora.parts.cordon))
                disp('❌ No Cordón available. Please create one first.');
                return;
            end
            if isempty(fieldnames(TFG_Amora.parts.larguerillo))
                disp('❌ No Larguerillo available. Please create one first.');
                return;
            end
            
            % ✅ User selects Cordón
            disp('Available Cordones:');
            cordonNames = fieldnames(TFG_Amora.parts.cordon);
            for i = 1:length(cordonNames)
                fprintf('%d) %s\n', i, cordonNames{i});
            end
            cordonIndex = input('Select a Cordón: ');
            if isnan(cordonIndex) || cordonIndex < 1 || cordonIndex > length(cordonNames)
                disp('❌ Invalid selection.');
                return;
            end
            selected_cordon = cordonNames{cordonIndex};

            % ✅ User selects Larguerillo
            disp('Available Larguerillos:');
            larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
            for i = 1:length(larguerilloNames)
                fprintf('%d) %s\n', i, larguerilloNames{i});
            end
            larguerilloIndex = input('Select a Larguerillo: ');
            if isnan(larguerilloIndex) || larguerilloIndex < 1 || larguerilloIndex > length(larguerilloNames)
                disp('❌ Invalid selection.');
                return;
            end
            selected_larguerillo = larguerilloNames{larguerilloIndex};

            % ✅ User enters Cajón dimensions
            cajon_name = input('Enter name for the new Cajón: ', 's');

            rib_props = generate_rib_properties(...
            avion.ala.mesh.nodos_anterior', ...
            avion.ala.mesh.nodos_posterior', ...
            avion.perfil.airfoil.m, ...
            avion.perfil.airfoil.p, ...
            avion.perfil.airfoil.t, ...
            avion.perfil.airfoil.num_points, ...
            false);

            % % For simplicity, compute the average values of H and C over all ribs:
            % H_value = mean(rib_props.H);  % Box height in mm (since nodal coordinates are in mm)
            % C_value = mean(rib_props.C);  % Box width in mm
            % H = input('Enter Box height H (mm): ');
            % C = input('Enter Box width C (mm): ');
            tss = input('Enter Upper skin thickness tss (mm): ');
            tsi = input('Enter Lower skin thickness tsi (mm): ');
            tl = input('Enter Spar thickness tl (mm): ');

            % ✅ Retrieve Cordón & Larguerillo Areas
            A_cordon = TFG_Amora.parts.cordon.(selected_cordon).A_cordon;
            A_larguerillo = TFG_Amora.parts.larguerillo.(selected_larguerillo).A_larguerillo;

            % ✅ Store in database
            TFG_Amora.parts.cajon.(cajon_name) = struct( ...
                'cordon', selected_cordon, ...
                'larguerillo', selected_larguerillo, ...
                'tss', tss*1e-3, ...
                'tsi', tsi*1e-3, ...
                'tl', tl*1e-3, ...
                'A_cordon', A_cordon, ...
                'A_larguerillo', A_larguerillo ...
            );
            % 
            % TFG_Amora.parts.cajon.(cajon_name) = struct( ...
            %     'cordon', selected_cordon, ...
            %     'larguerillo', selected_larguerillo, ...
            %     'rib_props', rib_props, ....
            %     'tss', tss*1e-3, ...
            %     'tsi', tsi*1e-3, ...
            %     'tl', tl*1e-3, ...
            %     'A_cordon', A_cordon, ...
            %     'A_larguerillo', A_larguerillo ...
            % );
             TFG_Amora.parts.cajon.(cajon_name).rib_props = rib_props;

            disp(['✅ Cajón "', cajon_name, '" saved.']);
        % case 4  % ✅ Naca
        %         % ✅ User chooses to create a NACA 6-Series airfoil
        %         disp('📌 Creating a NACA 6-Series Airfoil...');
        % 
        %         % Explain the parameters
        %         disp('- m: Maximum camber (fraction of chord, e.g., 0.02 for 2%)');
        %         disp('- p: Position of maximum camber (fraction of chord, e.g., 0.4 for 40%)');
        %         disp('- t: Maximum thickness (fraction of chord, e.g., 0.12 for 12%)');
        %         disp('- c: Chord length (m)');
        % 
        %         % Ask for user input (or use default values)
        %         m = input('Enter maximum camber (default 0.02): ');
        %         if isempty(m), m = 0.02; end
        % 
        %         p = input('Enter position of maximum camber (default 0.4): ');
        %         if isempty(p), p = 0.4; end
        % 
        %         t = input('Enter maximum thickness (default 0.12): ');
        %         if isempty(t), t = 0.12; end
        % 
        %         c = input('Enter chord length (default 1.0 m): ');
        %         if isempty(c), c = 1.0; end
        % 
        %         num_points = 100; % Fixed number of points for smooth airfoil curve
        %         show_graph = true; % Display the airfoil plot
        % 
        %         % 🔹 Generate airfoil struct
        %         airfoil = naca6series(m, p, t, c, num_points, show_graph);
        % 
        %         % ✅ Retrieve wing geometry data
        %         wing_geom = avion.ala.geometria;
        % 
        %         % ✅ Extract x-coordinates (spanwise locations)
        %         x_span = avion.coordenadas.x_local_ala; % Spanwise positions
        % 
        %         % ✅ Compute chord distribution using front and rear spar lines
        %         y_front = wing_geom.linea_larguero_anterior; % y-coordinates of front spar
        %         y_rear = wing_geom.linea_larguero_posterior; % y-coordinates of rear spar
        % 
        %         % ✅ Chord length at each spanwise position
        %         chord_distribution = abs(y_rear - y_front); % Compute chord length as difference
        % 
        % 
        %         % 🔹 Compute wing box height along the span
        %         h_values = compute_wingbox_height(airfoil, chord_distribution);
        % 
        %         % 🔹 Store in aircraft struct
        %         TFG_Amora.aviones.(name).perfil.h_values = h_values;
        %         TFG_Amora.aviones.(name).perfil.airfoil = airfoil; % Save full airfoil struct
        %         save(fullfile(database_computer, 'Data', 'TFG_Amora.mat'), 'TFG_Amora');
        % 
        %         disp('✅ Wing box height stored successfully.');
        % 
        otherwise
            disp('❌ Invalid option.');
            return;
    end

    % ✅ Save database **after all modifications**
    try
        save(data_path, 'TFG_Amora');
        assignin('base', 'TFG_Amora', TFG_Amora); % ✅ Ensure changes are reflected globally
        disp('✅ Structural part creation saved successfully.');
    catch ME
        disp('❌ Error saving TFG_Amora.mat:');
        disp(ME.message);
    end
end
