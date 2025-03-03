function tileAllSavedPlots_forces(avion)
    % tileAllSavedPlots: Loads all saved plots and displays them in a tiled layout
    
    % Define the list of plot filenames
    plotFiles = { ...
        'plotAla2D_weight_wing_n_ult', ...
        'plotAla2D_weight_wing_n_lim', ...
        'plotAla2D_weight_wing_n1', ...
        'plotAla2D_fuerzas_L_sust', ...
        'plotAla2D_fuerzas_l', ...
        'plotAla2D_V_n_lim', ...
        'plotAla2D_V_n_ult', ...
        'plotAla2D_V_n1'...
    };
    
    % Define the folder where the figures are saved
    figFolder = avion.folder.figures;

    % Create a new figure for tiling
    figure('Name', 'Tiled Plots', 'NumberTitle', 'off');
    t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');

    for i = 1:length(plotFiles)
        plotFile = fullfile(figFolder, plotFiles{i});
        if isfile(plotFile)
            % Load the saved figure
            fig = openfig(plotFile, 'invisible');
            ax = gca(fig);
            
            % Create a new axis in the tiled layout
            nexttile(t);
            copyobj(ax.Children, gca);
            
            % Close the individual figure
            close(fig);
            
            % Add a title to the tiled plot
            [~, name, ~] = fileparts(plotFile);
            title(strrep(name, '_', ' '));
        else
            warning('⚠️ Plot file not found: %s', plotFile);
        end
    end

    % Add a title to the entire layout
    title(t, 'Tiled Visualization of All Wing Plots');
end
