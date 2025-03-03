function tileAllSavedPlots_geometry(avion)
    % tileAllSavedPlots: Loads all saved plots and displays them in a tiled layout
    
    % Define the list of plot filenames
    plotFiles = { ...
        'Plot_geometria.fig', ...
        'Plot_larguerillos.fig', ...
        'Plot_costillas.fig', ...
        'Plot_costillas_larguerillos.fig', ...
        'Plot_nodos.fig', ...
        'Plot_larguerillo_fuselaje.fig', ...
        'Plot_costilla_fuselaje.fig', ...
        'Plot_costillas_larguerillo_fuselaje.fig', ...
        'Plot_costilla_total.fig', ...
        'Plot_larguerillo_total.fig', ...
        'Plot_costilla_larguerillo_total.fig' ...
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
