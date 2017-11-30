% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [] = LoadSupportingData (matFileName)
    load(matFileName); %loads 'description', 'TrainH', 'TestH', 'TrainDMapI', 'TestDMapI', 'TrainL', 'TestL', 'TrainRefI', 'TestRefI'
    if ~exist('description','var')
        description = 'no description';
    end
    if ~exist('SIFTBorder','var')
        SIFTBorder = 0;
        fprintf('WARNING: assuming SIFTBorder == 0 since it wasn''t passed in.\n');
    end
    fprintf(strcat('Running with dataset: ', description, '\n'));
    global TRAINLABELS; TRAINLABELS = TrainL;
    global TESTLABELS; TESTLABELS = TestL;
    global TRAINREFIMGS; TRAINREFIMGS = TrainRefI;
    global TRAINDMAPI; TRAINDMAPI = TrainDMapI;
    global TRAINDMAP; TRAINDMAP = TrainDMap;
    global TESTDMAP; TESTDMAP = TestDMap;
    global DMAP; DMAP = DMap;
    global TESTREFIMGS; TESTREFIMGS = TestRefI;
    global TESTDMAPI; TESTDMAPI = TestDMapI;
    global TRAINWINDOWS;
    global TESTWINDOWS;
    if ~exist('windows','var')
        TRAINWINDOWS = [];
        TESTWINDOWS = [];
        fprintf('WARNING: no windows passed in.\n');
    else
        TRAINWINDOWS = windows(TrainDMapI, :);
        TESTWINDOWS = windows(TestDMapI, :);
    end
    global TRAINIMGLINKS; TRAINIMGLINKS = ImgLinks(TrainDMapI);
    global TESTIMGLINKS; TESTIMGLINKS = ImgLinks(TestDMapI);
    global FRONTEND; FRONTEND = frontend;
    global SIFTBORDER; SIFTBORDER = SIFTBorder;
    global VOCAB_SIZE; VOCAB_SIZE = VOCAB_SIZE;
    global K; K = numel(unique(TRAINLABELS));
end