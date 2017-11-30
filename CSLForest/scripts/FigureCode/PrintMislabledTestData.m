% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [] = PrintMislabledTestData (Labels, PredLabels, TestRefImgs, windows, SIFTBorder, xmlFileName)
    correctMat = (PredLabels == Labels);
    numCorrect = numel(correctMat(correctMat==1));
    numIncorrect = numel(correctMat(correctMat==0));
    h1 = figure;
    set(gcf, 'Visible', 'off');
    h2 = figure;
    set(gcf, 'Visible', 'off');
    corrPrintedCount = 0;
    incorrPrintedCount = 0;
    for i = 1:numel(correctMat)
        img = TestRefImgs{i};
        img = img(SIFTBorder+1:size(img, 1)-SIFTBorder,SIFTBorder+1:size(img, 2)-SIFTBorder);
        if correctMat(i) == 1
            figure(h1);
            set(gcf, 'Visible', 'off');
            subplot_tight(floor(sqrt(numCorrect)), ceil(numCorrect/sqrt(numCorrect)), corrPrintedCount+1, [0.0,0.0]);
            corrPrintedCount = corrPrintedCount + 1;
        else
            figure(h2);
            set(gcf, 'Visible', 'off');
            subplot_tight(floor(sqrt(numIncorrect)), ceil(numIncorrect/sqrt(numIncorrect)), incorrPrintedCount+1, [0.0,0.0]);
            incorrPrintedCount = incorrPrintedCount + 1;
        end
        subimage(img);
        axis off;
        if numel(windows) > 0
            color = 'b';
            x = windows(i,1);
            y = windows(i,2);
            xb = windows(i,3);
            yb = windows(i,4);
            width = xb-x;
            height = yb-y;
            rectangle('Position',[x y width height], 'EdgeColor', color);
        end
        imgSize = size(img);
        text(imgSize(2)/4, imgSize(1)/4, num2str(Labels(i)), 'color', 'b', 'FontSize', 10, 'HorizontalAlignment', 'center');
    end
    set(h1, 'PaperPosition', [0, 0, 16, 16]);
    saveas(h1, strrep(xmlFileName, '.xml', '_correct_imgs.tif'));
    set(h2, 'PaperPosition', [0, 0, 16, 16]);
    saveas(h2, strrep(xmlFileName, '.xml', '_incorrect_imgs.tif'));
    
    %% Again with clean (unlabeled) images
    h3 = figure;
    set(gcf, 'Visible', 'off');
    h4 = figure;
    set(gcf, 'Visible', 'off');
    corrPrintedCount = 0;
    incorrPrintedCount = 0;
    for i = 1:numel(correctMat)
        img = TestRefImgs{i};
        img = img(SIFTBorder+1:size(img, 1)-SIFTBorder,SIFTBorder+1:size(img, 2)-SIFTBorder);
        if correctMat(i) == 1
            figure(h3);
            set(gcf, 'Visible', 'off');
            subplot_tight(floor(sqrt(numCorrect)), ceil(numCorrect/sqrt(numCorrect)), corrPrintedCount+1, [0.0,0.0]);
            corrPrintedCount = corrPrintedCount + 1;
        else
            figure(h4);
            set(gcf, 'Visible', 'off');
            subplot_tight(floor(sqrt(numIncorrect)), ceil(numIncorrect/sqrt(numIncorrect)), incorrPrintedCount+1, [0.0,0.0]);
            incorrPrintedCount = incorrPrintedCount + 1;
        end
        subimage(img);
        axis off;
        if numel(windows) > 0
            color = 'b';
            x = windows(i,1);
            y = windows(i,2);
            xb = windows(i,3);
            yb = windows(i,4);
            width = xb-x;
            height = yb-y;
            rectangle('Position',[x y width height], 'EdgeColor', color);
        end
    end
    set(h3, 'PaperPosition', [0, 0, 16, 16]);
    saveas(h1, strrep(xmlFileName, '.xml', '_correct_imgs_clean.tif'));
    set(h4, 'PaperPosition', [0, 0, 16, 16]);
    saveas(h2, strrep(xmlFileName, '.xml', '_incorrect_imgs_clean.tif'));
end