

function plotShearDistribution(shear_stresses)
    figure;
    hold on;
    bar(1, shear_stresses.tau_ss, 'r'); % Revestimiento superior
    bar(2, shear_stresses.tau_si, 'b'); % Revestimiento inferior
    bar(3, shear_stresses.tau_l, 'g');  % Larguero
    xlabel('Component');
    ylabel('Shear Stress (Pa)');
    xticks([1 2 3]);
    xticklabels({'Tau_{ss}', 'Tau_{si}', 'Tau_{l}'});
    title('Distribución de Esfuerzos Cortantes');
    legend({'Revestimiento Superior', 'Revestimiento Inferior', 'Larguero'});
    hold off;
end
