function add_datosEstructural(name, porcentaje_peso_ala_MTOW, porcentaje_peso_combustible_MTOW, ...
                               n, distancia_entre_costillas, distancia_entre_larguerillo, ...
                               Distancia_larguero_anterior_cuerda_porcentaje, Distancia_larguero_posterior_cuerda_porcentaje, ...
                               distancia_centro_aerodinamico, distancia_eje_de_referencia_estructural_larguero, ...
                               distancia_eje_de_referencia_estructural_cuerda, numero_de_puntos_en_las_lineas, k_sust, ...
                               projectRoot)
    % ===========================================================
    % 📌 Function: add_datosEstructural
    % ===========================================================
    % This function defines the initial structural dataset (`datosEstructural`)
    % which contains parameters for the wing's geometric and structural properties.
    % The dataset is stored in `TFG_Amora.mat` and used throughout the workflow.
    %
    % ✅ **Workflow Step**: This is part of the **"Input Phase"**:
    %    (1) Define structure + aircraft + materials
    %    (2) Generate wing structure
    %    (3) Run pre-dimensioning & analysis
    %    (4) Generate final FEM structure (Patran/Nastran)
    %    (5) Validate results
    %    (6) Perform resistance analysis
    %
    % 🛠 **Why This Matters?**
    % - This ensures **consistent structural definitions** before proceeding to 
    %   wing generation and FEM modeling.
    % - Some values are **direct inputs**, while others are **computed later**.
    % ===========================================================

    % Define the path to the database file
    databasePath = fullfile(projectRoot, 'Data', 'TFG_Amora.mat');

    % ✅ Step 1: Load Existing Database or Create a New One
    if isfile(databasePath)
        load(databasePath, 'TFG_Amora');
    else
        warning('⚠️ Database does not exist. Creating a new one.');
        TFG_Amora = struct();
        TFG_Amora.datosEstructural = struct(); % Initialize datosEstructural
    end

    % ✅ Step 2: Check If the Structural Dataset Already Exists
    if isfield(TFG_Amora.datosEstructural, name)
        warning('⚠️ The entry "%s" already exists in datosEstructural.', name);
        userChoice = input('Do you want to overwrite it? (y/n): ', 's');
        if lower(userChoice) ~= 'y'
            disp('Operation canceled. Data was NOT modified.');
            return;
        end
    end

    % ✅ Step 3: Create the New Structural Entry
    % ✨ Separating Fixed Inputs (User-Defined) from Design Variables (Computed Later)
    TFG_Amora.datosEstructural.(name) = struct(...
        % ✨ **User-Defined Structural Parameters**
        'porcentaje_peso_ala_MTOW', porcentaje_peso_ala_MTOW, ... % Wing weight as % of MTOW
        'porcentaje_peso_combustible_MTOW', porcentaje_peso_combustible_MTOW, ... % Fuel weight % of MTOW
        'n', n, ... % Load factor (typically 2.5 for commercial aircraft)
        'distancia_entre_costillas', distancia_entre_costillas, ... % Rib spacing (m)
        'distancia_entre_larguerillo', distancia_entre_larguerillo, ... % Stringer spacing (m)
        'distancia_larguero_anterior_cuerda_porcentaje', Distancia_larguero_anterior_cuerda_porcentaje, ... % % Chord position of front spar
        'distancia_larguero_posterior_cuerda_porcentaje', Distancia_larguero_posterior_cuerda_porcentaje, ... % % Chord position of rear spar
        'distancia_centro_aerodinamico', distancia_centro_aerodinamico, ... % Aerodynamic center position (% chord)
        'distancia_eje_de_referencia_estructural_larguero', distancia_eje_de_referencia_estructural_larguero, ... % Structural reference axis for spars
        'distancia_eje_de_referencia_estructural_cuerda', distancia_eje_de_referencia_estructural_cuerda, ... % Structural reference axis for chord
        'numero_de_puntos_en_las_lineas', numero_de_puntos_en_las_lineas, ... % Discretization points for FEM
        'k_sust_a350_1000', k_sust, ... % Lift coefficient for load distribution
        
        % ✨ **Computed Design Variables (Calculated Later)**
        'pitch', NaN, ... % Stringer spacing (computed in generate_wing)
        'n_stringers', NaN, ... % Number of stringers (computed in pre-dimensioning)
        'tss', NaN, ... % Upper skin thickness (computed in pre-dimensioning)
        'tsi', NaN, ... % Lower skin thickness (computed in pre-dimensioning)

        % ✨ **Project Path**
        'projectRoot', projectRoot ...
    );

    % ✅ Step 4: Save the Updated Structure
    save(databasePath, 'TFG_Amora');
    
    fprintf('✅ datosEstructural "%s" saved successfully to TFG_Amora.mat\n', name);
end







% function add_datosEstructural(name, porcentaje_peso_ala_MTOW, porcentaje_peso_combustible_MTOW, ...
%                                n, distancia_entre_costillas, distancia_entre_larguerillo, ...
%                                Distancia_larguero_anterior_cuerda_porcentaje, Distancia_larguero_posterior_cuerda_porcentaje, ...
%                                distancia_centro_aerodinamico, distancia_eje_de_referencia_estructural_larguero, ...
%                                distancia_eje_de_referencia_estructural_cuerda, numero_de_puntos_en_las_lineas, k_sust, ...
%                                projectRoot)
%     % ===========================================================
%     % 📌 Function: add_datosEstructural
%     % ===========================================================
%     % Adds a new structural dataset (datosEstructural) to the TFG_Amora database.
%     % 
%     % Inputs:
%     % - name: Unique identifier for the structural dataset.
%     % - porcentaje_peso_ala_MTOW: Ratio of wing weight to Maximum Take-Off Weight (MTOW).
%     % - porcentaje_peso_combustible_MTOW: Ratio of fuel weight to MTOW.
%     % - n: Load factor (typically 2.5 for commercial aircraft).
%     % - distancia_entre_costillas: Distance between wing ribs (meters).
%     % - distancia_entre_larguerillo: Distance between stringers (meters).
%     % - Distancia_larguero_anterior_cuerda_porcentaje: Position of the front spar as a percentage of chord length.
%     % - Distancia_larguero_posterior_cuerda_porcentaje: Position of the rear spar as a percentage of chord length.
%     % - distancia_centro_aerodinamico: Aerodynamic center position as a percentage of chord length.
%     % - distancia_eje_de_referencia_estructural_larguero: Reference axis position relative to the spars.
%     % - distancia_eje_de_referencia_estructural_cuerda: Reference axis position relative to the chord.
%     % - numero_de_puntos_en_las_lineas: Number of discretization points for structural analysis.
%     % - k_sust: Lift coefficient used in structural modeling.
%     % - projectRoot: Path to the project root directory.
%     %
%     % The function checks if the `datosEstructural` entry already exists.
%     % If it does, it prompts the user for overwrite confirmation.
%     % The updated structure is saved immediately.
%     % ===========================================================
% 
%     % Define the path to the database file
%     databasePath = fullfile(projectRoot, 'Data', 'TFG_Amora.mat');
% 
%     % Load existing database or create a new one
%     if isfile(databasePath)
%         load(databasePath, 'TFG_Amora');
%     else
%         warning('⚠️ Database does not exist. Creating a new one.');
%         TFG_Amora = struct();
%         TFG_Amora.datosEstructural = struct(); % Initialize datosEstructural
%     end
% 
%     % Check if the name already exists
%     if isfield(TFG_Amora.datosEstructural, name)
%         warning('⚠️ The entry "%s" already exists in datosEstructural.', name);
%         userChoice = input('Do you want to overwrite it? (y/n): ', 's');
%         if lower(userChoice) ~= 'y'
%             disp('Operation canceled. Data was NOT modified.');
%             return;
%         end
%     end
% 
%     % Create the new datosEstructural entry
%     TFG_Amora.datosEstructural.(name) = struct(...
%         'porcentaje_peso_ala_MTOW', porcentaje_peso_ala_MTOW, ...
%         'porcentaje_peso_combustible_MTOW', porcentaje_peso_combustible_MTOW, ...
%         'n', n, ...
%         'distancia_entre_costillas', distancia_entre_costillas, ...
%         'distancia_entre_larguerillo', distancia_entre_larguerillo, ...
%         'distancia_larguero_anterior_cuerda_porcentaje', Distancia_larguero_anterior_cuerda_porcentaje, ...
%         'distancia_larguero_posterior_cuerda_porcentaje', Distancia_larguero_posterior_cuerda_porcentaje, ...
%         'distancia_centro_aerodinamico', distancia_centro_aerodinamico, ...
%         'distancia_eje_de_referencia_estructural_larguero', distancia_eje_de_referencia_estructural_larguero, ...
%         'distancia_eje_de_referencia_estructural_cuerda', distancia_eje_de_referencia_estructural_cuerda, ...
%         'numero_de_puntos_en_las_lineas', numero_de_puntos_en_las_lineas, ...
%         'k_sust_a350_1000', k_sust, ...
%         'projectRoot', projectRoot ...
%     );
% 
%     % Save the updated structure immediately
%     save(databasePath, 'TFG_Amora');
% 
%     fprintf('✅ datosEstructural "%s" saved successfully to TFG_Amora.mat\n', name);
% end
% 
% %% ================================================
% % 📌 **Detailed Explanation of `add_datosEstructural`**
% % ================================================
% %
% % **Purpose:**
% % This function adds a new structural dataset (`datosEstructural`) to the 
% % TFG_Amora database. This dataset contains key structural parameters 
% % needed for the wing and aircraft modeling processes.
% %
% % **Input Parameters:**
% % - `porcentaje_peso_ala_MTOW`: Determines how much of the aircraft's 
% %   weight is due to the wing. This is useful for estimating structural 
% %   loads and constraints.
% % - `porcentaje_peso_combustible_MTOW`: Represents the proportion of 
% %   aircraft weight allocated to fuel. This affects wing load calculations.
% % - `n`: Load factor, which is the ratio of the lift force to the aircraft's 
% %   weight. A typical value for commercial aircraft is 2.5.
% % - `distancia_entre_costillas`: The spacing between ribs, which affects 
% %   the stiffness and mass of the wing.
% % - `distancia_entre_larguerillo`: Defines the spacing between stringers, 
% %   which influences local buckling and stress distribution.
% % - `distancia_larguero_anterior_cuerda_porcentaje`: Position of the 
% %   forward spar as a fraction of the chord length.
% % - `distancia_larguero_posterior_cuerda_porcentaje`: Position of the 
% %   rear spar as a fraction of the chord length.
% % - `distancia_centro_aerodinamico`: Aerodynamic center location, which 
% %   is important for stability and control analysis.
% % - `distancia_eje_de_referencia_estructural_larguero`: Defines the reference 
% %   axis location relative to the spars, used for moment calculations.
% % - `distancia_eje_de_referencia_estructural_cuerda`: Defines the reference 
% %   axis location relative to the chord, used in aerodynamic calculations.
% % - `numero_de_puntos_en_las_lineas`: Determines the level of discretization 
% %   in numerical simulations. A higher value improves accuracy but increases 
% %   computation time.
% % - `k_sust`: Lift coefficient used in distributed lift modeling. This is 
% %   needed for determining how aerodynamic loads are applied to the structure.
% % - `projectRoot`: Defines the project’s base directory to maintain file 
% %   structure consistency.
% %
% % **Workflow:**
% % 1️⃣ **Load the database (`TFG_Amora.mat`)**  
% % - If the file exists, it is loaded to check for existing structural data.  
% % - If not, a new struct is created.  
% %
% % 2️⃣ **Check if the structural data entry (`name`) already exists**  
% % - If the name already exists, the user is asked if they want to overwrite it.  
% % - If the user declines, the function exits without making changes.  
% %
% % 3️⃣ **Create or update the structural dataset (`datosEstructural`)**  
% % - A new entry is created with all input parameters.  
% % - The `projectRoot` is stored to ensure consistency across different scripts.  
% %
% % 4️⃣ **Save the updated structure into `TFG_Amora.mat`**  
% %
% % **Modification Notes:**
% % - If additional parameters are required for future analyses, extend 
% %   `datosEstructural` with new fields.
% % - If `projectRoot` changes, ensure that all scripts referencing it 
% %   are updated accordingly.
% %
% % ================================================





