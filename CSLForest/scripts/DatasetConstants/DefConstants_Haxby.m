% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract

% DESCRIPTION: File defines parameter values for the algorithm

global N_CATS; N_CATS = 8; %number of ground truth classes
global DATASET_NAME; 
DATASET_NAME = 'subj1';
%DATASET_NAME = 'subj2';
%DATASET_NAME = 'subj3';
%DATASET_NAME = 'subj4';
%DATASET_NAME = 'subj5';
%DATASET_NAME = 'subj6';

%Paths for various folders
global ROOT_DIRECTORY; ROOT_DIRECTORY = 'CSLForest';
global ResourcePath; ResourcePath = fullfile(ROOT_DIRECTORY, '/Haxby/', DATASET_NAME); %Directory where preprocessed dataset is saved.
global OutputPath; OutputPath = fullfile(ROOT_DIRECTORY, '/outputHaxby/'); %Where results are saved

global CatFile; CatFile = 'Categories'; %Name of file in ResourcePath that contains the list of ground truth classes.
global VocabCatFile; VocabCatFile = 'VocabCategories'; %Name of file in ResourcePath that contains a list of folders to use for vocab building

