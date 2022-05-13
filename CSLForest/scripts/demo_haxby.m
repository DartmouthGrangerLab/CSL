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
function [] = demo_haxby()
    DefConstants_Haxby;
    global DATASET_NAME
    global ResourcePath
    
    if exist(fullfile(ResourcePath, 'H.mat'), 'file') == 0 || exist(fullfile(ResourcePath, 'Labels.mat'), 'file') == 0
        error('you will need to download / request this dataset separately, then place H.mat and Labels.mat in your resources folder');
    end
    load(fullfile(ResourcePath, 'H.mat'));
    load(fullfile(ResourcePath, 'Labels.mat'));
    L1Bags = H;

    % save file of inputs to QuickRun
    description = strcat('haxby_', DATASET_NAME);
    save(fullfile(ResourcePath, 'Saved_Data.mat'), 'L1Bags', 'Labels', 'description', '-v7.3');
    
    %% ************** BEGIN CSLFOREST **************
    QuickRun(fullfile(ResourcePath, 'Saved_Data.mat'));
end
