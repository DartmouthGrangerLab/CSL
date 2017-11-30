% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [solns] = MatchImgPair (job, AllData)
    Img1 = AllData.DMap{AllData.ImgPairs(job,1)};
    Img2 = AllData.DMap{AllData.ImgPairs(job,2)};
    [Win1,Win2] = ml_findBoxes(Img1, Img2, [], AllData.C, AllData.TOL_FAC, 0, 0, 10, AllData.Win_Prior_Mean, AllData.Win_Prior_Variance./5000, 0); 
    solns.Wins = vertcat(Win1, Win2);
end
