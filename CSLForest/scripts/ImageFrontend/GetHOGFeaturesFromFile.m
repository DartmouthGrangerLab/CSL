% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% Author: Brett Tofel, brain engineering laboratory, Dartmouth 
% DESCRIPTION: Extracts HOG features from image
function [Feats,Locs,Filter] = GetHOGFeaturesFromFile (Img)
    cellSize = 1;
    Iorig = imread(char(Img));

    [HOG,Filter] = Dense_hog(Iorig,4,0.0);

    %% create Locs artificially. JointStills needs a nx2 matrix of locations,
    %  HOG just has MxMxR matrix of Feats
    iLen = size(HOG,1);
    jLen = size(HOG,2);
    nLen = size(HOG,3);
    
    Locs = zeros(iLen*jLen, 2);
    Feats = zeros(iLen*jLen, nLen);
    idx = 0;
    
    for i = 1:iLen
        for j = 1:jLen
            idx = idx +1;
            Locs(idx, :) = [i*cellSize, j*cellSize];
            Feats(idx,:) = HOG(i,j,:);
        end
    end
    save(strcat(Img,'_HOG.mat'),'HOG','Locs', 'Feats');
end


