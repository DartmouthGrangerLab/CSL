% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [Windows] = GetInitialWindows (DMap, WinMode)
    if WinMode == 1
        error('not currently supported');
    elseif WinMode == 2
        error('not currently supported');
%         N_Seeds = floor(3.0*K);
%         Windows = GetInitialWindowsWithPairMatching(DMap, VOCAB_SIZE, N_Seeds, Win_Prior_Mean, Win_Prior_Variance, rstream, JSSettings);
    elseif WinMode == 3
        for i = 1:numel(DMap)
            Windows(i,:) = [1 1 size(DMap{i}, 2) size(DMap{i}, 1)];
        end
    elseif WinMode == 4
        error('not currently supported');
%         load objBxs;
%         Windows = floor(objBxs);
    elseif WinMode == 5
        load MsrcObjBxs;
        Windows = floor(MsrcObjBxs);
    elseif WinMode == 6
        error('not currently supported');
%         [Windows,TrueContours] = GetGroundTruthWindows_Calt(N_CATS);
    elseif WinMode == 7
        error('not currently supported');
%         load PascalObjBxs;
%         Windows = floor(PascalObjBxs);
    elseif WinMode == 8
        Windows = zeros(numel(DMap),4);
        for i = 1:numel(DMap)
            Windows(i, 1) = 1;
            Windows(i, 2) = 1;
            Windows(i, 3) = size(DMap{i},2);
            Windows(i, 4) = size(DMap{i},1);
        end
    elseif WinMode == 9
        %random windows containing the center point
        Windows = zeros(numel(DMap),4);
        for i = 1:numel(DMap)
            Windows(i, 1) = randi(floor(size(DMap{i}, 2)/2));
            Windows(i, 2) = randi(floor(size(DMap{i}, 1)/2));
            Windows(i, 3) = floor(size(DMap{i}, 2)/2) + ceil(randi(size(DMap{i}, 2)/2));
            Windows(i, 4) = floor(size(DMap{i}, 1)/2) + ceil(randi(size(DMap{i}, 1)/2));
        end
    elseif WinMode == 10
        error('not currently supported');
        %random windows of at least size 5x5, another way
%         Windows = zeros(numel(DMap),4);
%         for i = 1:numel(DMap)
%             Windows(i, 1) = randi(size(DMap{i}, 2));
%             Windows(i, 2) = randi(size(DMap{i}, 1));
%             Windows(i, 3) = Windows(i, 1) + ceil(randi(size(DMap{i}, 2)-Windows(i, 1)));
%             Windows(i, 4) = Windows(i, 2) + ceil(randi(size(DMap{i}, 1)-Windows(i, 2)));
%         end
    elseif WinMode == 11
        %random windows - all sizes are equally probable (center pixels more probable to be included)
        Windows = zeros(numel(DMap),4);
        for i = 1:numel(DMap)
            %source of idea: https://stackoverflow.com/questions/13706806/generating-a-discrete-random-subwindow-from-a-given-window
            %x = width of window
            %r = randi(x(x+1)/2);
            imgWidth = size(DMap{i}, 2);
            imgHeight = size(DMap{i}, 1);
            width = randi(imgWidth);
            height = randi(imgHeight);
            xcenter = randi(imgWidth - width + 1) + floor(width/2);
            ycenter = randi(imgHeight - height + 1) + floor(height/2);
            Windows(i, 1) = xcenter-floor(width/2);
            Windows(i, 2) = ycenter-floor(height/2);
            Windows(i, 3) = xcenter+ceil(width/2)-1;
            Windows(i, 4) = ycenter+ceil(height/2)-1;
        end
    end
end