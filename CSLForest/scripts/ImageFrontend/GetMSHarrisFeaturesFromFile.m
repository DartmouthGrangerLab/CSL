% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% Author: Brett Tofel, brain engineering laboratory, Dartmouth 
% DESCRIPTION: Extracts features from image
function [Feats,Locs] = GetMSHarrisFeaturesFromFile(Img)
    I = imread(char(Img));
    
    % Convert the to required format
    r = size(I, 3);
    if r == 3
       I = single(rgb2gray(I));
    else
       I = single(I);
    end
    
    [frames,descrs] = vl_covdet(I, 'verbose', 'OctaveResolution', 3, 'method', 'MultiscaleHarris');
    
    Xs = frames(2,1:end)';
    Ys = frames(1,1:end)';
    Locs = [Ys Xs];
    
    imshow(I, [], 'InitialMagnification', 400);
    hold on
    vl_plotframe(frames);
    hold off
    pause;
    Feats = descrs;
    Feats = double(Feats');
end
