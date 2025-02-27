function add_structural_parts()
    % Adds structural components (Cordon, Larguerillo, Cajón, and NACA Wing)
    % and stores them in TFG_Amora.parts

    clear;
    load('TFG_Amora.mat', 'TFG_Amora');

    disp('----------------------------------------');
    disp('🏗️ Structural Parts Creation');
    disp('1) Add Cordon');
    disp('2) Add Larguerillo');
    disp('3) Add Cajón (Requires Cordon & Larguerillo)');
    disp('4) 🔙 Return');

    partChoice = input('Select an option: ', 's');
    partIndex = str2double(partChoice);

    if isnan(partIndex) || partIndex < 1 || partIndex > 4
        disp('❌ Invalid selection. Returning to menu.');
        return;
    end

    if partIndex == 4
        disp('🔙 Returning...');
        return;
    end

    % ✅ Add Cordon
    if partIndex == 1
        cordon_name = input('Enter name for the new Cordon: ', 's');
        material_name = input('Enter material name for the Cordon: ', 's');
        hcl = input('Enter Cordon height (m): ');
        tcl = input('Enter Cordon thickness (m): ');
        
        % ✅ Compute area
        cordon_dims.hcl = hcl;
        cordon_dims.tcl = tcl;
        A_cordon = cordon(cordon_dims);

        % ✅ Store in database
        TFG_Amora.parts.cordon.(cordon_name) = struct( ...
            'material', material_name, ...
            'hcl', hcl, ...
            'tcl', tcl, ...
            'A_cordon', A_cordon ...
        );

        disp(['✅ Cordon "', cordon_name, '" saved.']);
        fprintf('Cordon Area: %.6f m²\n', A_cordon);
    
    % ✅ Add Larguerillo
    elseif partIndex == 2
        larguerillo_name = input('Enter name for the new Larguerillo: ', 's');
        material_name = input('Enter material name for the Larguerillo: ', 's');
        type = input('Enter Larguerillo type (Z/T): ', 's');
        
        if ~ismember(type, {'Z', 'T'})
            disp('❌ Invalid type. Please enter "Z" or "T".');
            return;
        end

        wf = input('Enter Flange width (m): ');
        tf = input('Enter Flange thickness (m): ');
        hw = input('Enter Web height (m): ');
        tw = input('Enter Web thickness (m): ');

        wh = 0;
        th = 0;
        if strcmp(type, 'Z')
            wh = input('Enter Heel width (m): ');
            th = input('Enter Heel thickness (m): ');
        end

        % ✅ Compute area
        larguerillo_dims = struct('type', type, 'wf', wf, 'tf', tf, 'hw', hw, 'tw', tw, 'wh', wh, 'th', th);
        A_larguerillo = larguerillo(larguerillo_dims);

        % ✅ Store in database
        TFG_Amora.parts.larguerillo.(larguerillo_name) = struct( ...
            'material', material_name, ...
            'type', type, ...
            'wf', wf, ...
            'tf', tf, ...
            'hw', hw, ...
            'tw', tw, ...
            'wh', wh, ...
            'th', th, ...
            'A_larguerillo', A_larguerillo ...
        );

        disp(['✅ Larguerillo "', larguerillo_name, '" saved.']);
        fprintf('Larguerillo Area (%s): %.6f m²\n', type, A_larguerillo);
    
    % ✅ Add Cajón (Requires Cordon & Larguerillo)
    elseif partIndex == 3
        cajon_name = input('Enter name for the new Cajón: ', 's');

        % ✅ Select Cordon
        cordonNames = fieldnames(TFG_Amora.parts.cordon);
        if isempty(cordonNames)
            disp('❌ No Cordons available. Add a Cordon first.');
            return;
        end

        disp('Available Cordons:');
        for i = 1:length(cordonNames)
            fprintf('%d) %s\n', i, cordonNames{i});
        end
        cordonIndex = input('Select a Cordon: ');
        if isnan(cordonIndex) || cordonIndex < 1 || cordonIndex > length(cordonNames)
            disp('❌ Invalid selection.');
            return;
        end
        selected_cordon = cordonNames{cordonIndex};

        % ✅ Select Larguerillo
        larguerilloNames = fieldnames(TFG_Amora.parts.larguerillo);
        if isempty(larguerilloNames)
            disp('❌ No Larguerillos available. Add a Larguerillo first.');
            return;
        end

        disp('Available Larguerillos:');
        for i = 1:length(larguerilloNames)
            fprintf('%d) %s\n', i, larguerilloNames{i});
        end
        larguerilloIndex = input('Select a Larguerillo: ');
        if isnan(larguerilloIndex) || larguerilloIndex < 1 || larguerilloIndex > length(larguerilloNames)
            disp('❌ Invalid selection.');
            return;
        end
        selected_larguerillo = larguerilloNames{larguerilloIndex};

        % ✅ Ask for Cajón Dimensions
        H = input('Enter Box height H (m): ');
        C = input('Enter Box width C (m): ');
        tss = input('Enter Upper skin thickness tss (m): ');
        tsi = input('Enter Lower skin thickness tsi (m): ');
        tl = input('Enter Spar thickness tl (m): ');
        pitch = input('Enter Stringer pitch (m): ');

        % ✅ Retrieve Areas of Cordon & Larguerillo
        A_cordon = TFG_Amora.parts.cordon.(selected_cordon).A_cordon;
        A_larguerillo = TFG_Amora.parts.larguerillo.(selected_larguerillo).A_larguerillo;

        % ✅ Store in database
        TFG_Amora.parts.cajon.(cajon_name) = struct( ...
            'cordon', selected_cordon, ...
            'larguerillo', selected_larguerillo, ...
            'H', H, ...
            'C', C, ...
            'tss', tss, ...
            'tsi', tsi, ...
            'tl', tl, ...
            'pitch', pitch, ...
            'A_cordon', A_cordon, ...
            'A_larguerillo', A_larguerillo ...
        );

        disp(['✅ Cajón "', cajon_name, '" saved.']);
    end

    % ✅ Save database
    save(fullfile('TFG_Amora.mat'), 'TFG_Amora');
    disp('✅ Structural part creation saved.');
end
