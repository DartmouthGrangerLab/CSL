% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% DESCRIPTION: Extracts features from image
function [Feats,Locs] = GetSiftFeaturesFromFile(Img)
    I = imread(char(Img));
    
    % Convert the to required format
    r = size(I, 3);
    if (r == 3)
       I = single(rgb2gray(I));
    else
       I = single(I);
    end

    % bbt Added explicit binSize and step different from the dsift defaults
    % to reduce number of SIFT features found.
    binSize = 8; % (low sift # was at 8) % Richard - caltech version has 8
    step = 1; % (low sift # was at 6) % Richard - caltech version has 6
    
%     Is = vl_imsmooth(I, sqrt((binSize/magnif)^2 - .25));
%     [Locs,Feats] = vl_dsift(I), 'Norm', 'Verbose', 'Fast', 'size', binSize, 'step', step);
    %[Locs,Feats] = vl_dsift(I, 'Verbose', 'size', binSize, 'step', step);
    [Locs,Feats] = vl_dsift(I, 'size', binSize, 'step', step); % made NOT verbose by Eli (both ways work, switch back if you'd like) %Richard - caltech has just [Locs,Feats] = vl_dsift(I); % run with no params, this is defaults

    Locs = Locs(1:2,:); % Richard - caltech version doesn't have this line
    Locs = Locs';
    Feats = double(Feats');
    save(strcat(Img,'_sift.mat'),'Locs', 'Feats', '-v7.3'); % Richard added -v7.3
end


