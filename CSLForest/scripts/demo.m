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
clearvars -except inFrontend inVOCAB inVocabPerCat inUseSavedData inRstream; % can be passed in with call to demo "inK=4;demo;"

DefConstants_Caltech4;
%DefConstants_Caltech39;
global N_CATS
global DATASET_NAME
global OutputPath
global SIFTBorder
global N_VOCAB_PER_CAT
global filesPerCat
global ROOT_DIRECTORY

load(fullfile('CSLForest', 'resources', 'rstream.mat'), 'rstream'); %must be at the top

%% ******************************************
% user settings for image frontend
frontend = 'sift'; % pick a front end to use ('rawimages','sift','concentricsubtraction','msharris','hog')
VOCAB_SIZE = 40; % set to 0 to disable restricted vocabulary (ONLY available with some frontends; see BuildVocab_*.m)
T = 0; % number of LDA topics - set to 0 to disable LDA topics - was 50
useSavedData = 0; % only set to 1 if you've already run with these params before (past call to PrepareData()) AND not using concentriccircles
N_VOCAB_PER_CAT = 30; % number of images used for vocab - Richard - changed to 39 bcos caltech 4 has 39 okapi
%% ******************************************

% command line overrides
if exist('inFrontend','var')
    frontend = inFrontend;
end
if exist('inVOCAB','var')
    VOCAB_SIZE = inVOCAB;
end
if exist('inVocabPerCat','var')
    N_VOCAB_PER_CAT = inVocabPerCat;
end
if exist('inUseSavedData','var')
    useSavedData = inUseSavedData;
end
if exist('inRstream','var')
    rstream = inRstream;
end

%% initialization
warning off backtrace; % removes stacktraces from warnings
% a unique string for the folder for all results from this run
uniqueString = strcat('frontend-',frontend,'_VOCABSIZE-',num2str(VOCAB_SIZE),'_T-',num2str(T), '_VOCABPERCAT-', num2str(N_VOCAB_PER_CAT),'_filesPerCat',num2str(filesPerCat, '-%d'));

% directory to save all information for this run 
runPath = strcat(OutputPath, uniqueString);
if ~exist(runPath, 'dir')
    mkdir(OutputPath, uniqueString);
end
% complete path from the top of the root folder to the folder containing all results from this run
OutputPath = strcat(OutputPath, uniqueString, '/');

currPool = gcp('nocreate');
if isempty(currPool)
    poolsize = parcluster; % get pool size from default profile
    parpool(poolsize);
end

% save all command window input and output
diaryFn = strcat(OutputPath, 'diary_', datestr(now, 'mmm_dd_yyyy_HH_MM_SS_FFF'), '.txt');
diary(diaryFn);

path(strcat(ROOT_DIRECTORY, '/vlfeat-0.9.17'), path); %move vl-feat to TOP of path
vl_setup; %prepare vl_sift for use

fprintf(strcat('Running model on %s dataset using the %s frontend.\n'), DATASET_NAME, frontend);

[ImgLinks,Labels] = LoadImages(N_CATS, filesPerCat, rstream, []);
if ~useSavedData
    % this has to be run if you want to extract features and represent all images in the dataset as quantized integral images
    [VOCAB_SIZE,vocab] = DatasetPreprocessor(VOCAB_SIZE, N_CATS, ImgLinks, frontend, [], rstream); 
    if T > 0
        fprintf('Learning LDA Topics\n');   
        LearnLDATopics(VOCAB_SIZE, N_CATS, T, frontend); % saves pwz
        fprintf('Done learning LDA topics\n'); 
    end
end

%% DMap is LdaDMap with any T!=0, so all represented as topics.
fprintf('loading Sift DMap for images\n');
DMap = PrepareData(VOCAB_SIZE, N_CATS, T, frontend);

%% sift border fix
if strcmp (frontend,'sift')
    fprintf('Fixing sift borders\n');
    % trim border bogosity from dense sift generated DMaps
    for i = 1:numel(DMap)
        height = size(DMap{i}, 1);
        width = size(DMap{i}, 2);
        DMap{i} = DMap{i}(SIFTBorder+1:height-SIFTBorder,SIFTBorder+1:width-SIFTBorder);
    end
end

% save file of inputs to QuickRun
outputFn = SaveDMapForCSLForest(DMap, Labels, ImgLinks, frontend, uniqueString, VOCAB_SIZE, N_VOCAB_PER_CAT, filesPerCat, useSavedData, rstream);

%% ************** BEGIN CSLFOREST **************
QuickRun(strcat(OutputPath, outputFn));

%% cleanup
diary off
clearvars inFrontend inK inVOCAB inVocabPerCat inFilesPerCat inUseSavedData inRstream
delete(gcp('nocreate')); 
