% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract

% DESCRIPTION: Main entry point. Execute this script directly.
%	assumes you'll execute this script from one level above the CSLForest directory
clearvars

DefConstants_Higgs;
global ResourcePath

filename = fullfile(ResourcePath, 'HIGGS.csv');
if exist(filename, 'file') == 0
    error('you will need to download / request this dataset separately, then place HIGGS.csv in your resources folder');
end
Labels = csvread(filename, 0, 0, [0, 0, 500000, 0]);
Labels = Labels + 1;
L1Bags = csvread(filename, 0, 1, [0, 1, 500000, 20]);

% save file of inputs to QuickRun
description = 'Higgs';
save(fullfile(ResourcePath, 'Saved_Data.mat'), 'L1Bags', 'Labels', 'description', '-v7.3');

%% ************** BEGIN CSLFOREST **************
QuickRun(fullfile(ResourcePath, 'Saved_Data.mat'));
