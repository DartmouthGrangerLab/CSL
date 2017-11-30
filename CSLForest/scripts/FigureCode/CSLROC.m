% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [] = CSLROC (errBars, TestLabels, svm_ROC, svm_TPRate, svm_FPRate, csl_TPRate, csl_FPRate, xmlFileName)
    hold off;
    rocFig = figure();
    if ~errBars
        [X,Y,~,~] = perfcurve(TestLabels, svm_ROC, 1, 'XVals', 0:0.02:1);
        plot(X(:,1), Y(:,1), 'r', 'LineWidth', 1.0);
    else
        [X,Y,~,~] = perfcurve(TestLabels, svm_ROC, 1, 'XVals', 0:0.05:1);
        errorbar(X,Y(:,1),Y(:,2)-Y(:,1),Y(:,3)-Y(:,1),'r', 'LineWidth', 1.0);
    end
    xlim([0 1]);
    ylim([0 1]);
    hold on;
    scatter(squeeze(svm_FPRate(:,1)/100), squeeze(svm_TPRate(:,1)/100), 80, 'r', 'o', 'LineWidth', 1.0);
    myLegend{1,1} = 'Branching Factor = 2';
    myLegend{1,2} = 'x, green';
    scatter(squeeze(csl_FPRate(:,2,1)/100), squeeze(csl_TPRate(:,2,1)/100), 80, [0,0.8,0], 'x', 'LineWidth', 1.0);
    myLegend{2,1} = 'Branching Factor = 6';
    myLegend{2,2} = '*, blue';
    scatter(squeeze(csl_FPRate(:,6,1)/100), squeeze(csl_TPRate(:,6,1)/100), 80, 'b', '*', 'LineWidth', 1.0);

    save(strrep(strcat('myLegend_', xmlFileName), '.xml', '.mat'), 'myLegend');
    xlabel('FP Rate', 'FontSize', 16);
    ylabel('TP Rate, vertical avg', 'FontSize', 16);
    title('ROC');
    set(gca, 'FontSize', 16);
    plot([0 1], [0 1], 'LineWidth', 1.0);
    set(rocFig, 'PaperPosition', [0, 0, 10, 9]);
    saveas(rocFig, strrep(xmlFileName, '.xml', '_ROC.tif'));
end