% File: demo.m
% Authored by: Ashok Chandrashekar, Brain Engineering Laboratory, Dartmouth
% Code maintained by: Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo (Brain Engineering Laboratory, Dartmouth)
% Description: Main entry point. Execute this script directly.

clearvars -except inFrontend inK inVOCAB inVocabPerCat inFilesPerCat inUseSavedData inRstream; %can be passed in with call to demo "inK=4;demo;"

DefConstants_Caltech4;
%DefConstants_Caltech39;

global N_CATS;
global DATASET_NAME;
global FG_WIN_OPT_MODE; % 1 is for continous rectangle, 2 for free form segments
global OutputPath;
global ImageSampleX;
global ImageSampleY;
global SIFTBorder;
global ImgPath;
global DATA_FILENAME;
global N_EM_STARTS;
global N_VOCAB_PER_CAT;
global filesPerCat;
global ROOT_DIRECTORY;

load rstream; %must be at the top

%% ******************************************
%user settings
foregroundLocalization = 'joint-superpixel'; %'joint-superpixel' or 'joint-subwindow'

% Pick a Front End to use ('rawimages','sift','concentricsubtraction','msharris','hog')
frontend = 'sift';

hardware = 'pc';
VOCAB_SIZE = 40; %set to 0 to disable restricted vocabulary (ONLY available with some frontends; see BuildVocab_*.m)
K = size(filesPerCat, 2); %number of clusters to produce - was 40, then 10  %Richard - set to 4 for caltech 4
T = 0; %number of LDA topics - set to 0 to disable LDA topics - was 50
useSavedData = 0; %only set to 1 if you've already run with these params before (past call to PrepareData()) AND not using concentriccircles
N_EM_STARTS = 1;
N_VOCAB_PER_CAT = 4;     %30; % Number of images used for vocab - was 4 changing for looting project    - Richard - changed to 39 bcos caltech 4 has 39 okapi
%% ******************************************

% command line overrides
if exist('inFrontend','var')
    frontend = inFrontend;
end
if exist('inVOCAB','var')
    VOCAB_SIZE = inVOCAB;
end
if exist('inK','var')
    K = inK;
end
if exist('inVocabPerCat','var')
    N_VOCAB_PER_CAT = inVocabPerCat;
end
if exist('inFilesPerCat','var')
    filesPerCat = inFilesPerCat;
end
if exist('inUseSavedData','var')
    useSavedData = inUseSavedData;
end
if exist('inRstream','var')
    rstream = inRstream;
end

%% initialization
warning off backtrace; %removes stacktraces from warnings
% a unique string for the folder for all results from this run
uniqueString = strcat('frontend-',frontend,'_VOCABSIZE-',num2str(VOCAB_SIZE),'_K-',num2str(K),'_T-',num2str(T), '_NEMSTARTS-',num2str(N_EM_STARTS), '_VOCABPERCAT-', num2str(N_VOCAB_PER_CAT),'_filesPerCat',num2str(filesPerCat, '-%d'));

%directory to save all information for this run 
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

fprintf(strcat('Running model on %s dataset using the %s frontend with %s method of foreground localization.\n'), DATASET_NAME, frontend, foregroundLocalization);
if strcmp(foregroundLocalization,'joint-subwindow')
    FG_WIN_OPT_MODE = 1;
end %if this section takes FOREVER, delete the entire contents of your \lootingImageSet\Images folder

[ImgLinks, Labels] = LoadImages(N_CATS, filesPerCat, rstream, []);
if ~useSavedData
    %This has to be run if you want to extract features and represent all images in the dataset as quantized integral images. 
    [VOCAB_SIZE, vocab] = DatasetPreprocessor(VOCAB_SIZE, N_CATS, ImgLinks, frontend, [], rstream); 
    if T > 0
        fprintf('Learning LDA Topics\n');   
        LearnLDATopics(VOCAB_SIZE, N_CATS, T, frontend); %saves pwz
        fprintf('Done learning LDA topics\n'); 
    end
end

%% DMap is LdaDMap with any T!=0, so all represented as topics.
%SegMap, SegHistMap, SegNbrMap only populated if foregroundLocalization == 'joint-superpixel'
if (strcmp(foregroundLocalization, 'joint-superpixel') == 1)
    fprintf('Generating LDA topics and segments for images\n');
else
    fprintf('loading Sift DMap for images\n');
end
DMap = PrepareData(ImgLinks, VOCAB_SIZE, N_CATS, T, frontend, useSavedData);

%if running foregroundLocalization == 'joint-superpixel'
%[DMap, SegMap, SegHistMap, SegNbrMap] = PrepareData(ImgLinks, VOCAB_SIZE,N_CATS, T, frontend, useSavedData);

%% sift border fix
if strcmp (frontend,'sift')
    fprintf('Fixing sift borders\n');
    %trim border bogosity from dense sift generated DMaps
    for i = 1:numel(DMap)
        height = size(DMap{i}, 1);
        width = size(DMap{i}, 2);
        DMap{i} = DMap{i}(SIFTBorder+1:height-SIFTBorder,SIFTBorder+1:width-SIFTBorder);
    end
end

% save L1BagsPlus file
outputFn = SaveDMapForCSLForest(DMap, Labels, ImgLinks, frontend, uniqueString, N_EM_STARTS, VOCAB_SIZE, K, N_VOCAB_PER_CAT, filesPerCat, useSavedData, rstream);

%% ************** BEGIN CSLFOREST **************
QuickRun(strcat(OutputPath, outputFn), uniqueString);

%% cleanup
diary off;
clearvars inFrontend inK inVOCAB inVocabPerCat inFilesPerCat inUseSavedData inRstream;
delete(gcp('nocreate')); 
