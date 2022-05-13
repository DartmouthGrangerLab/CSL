% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function outputFn = SaveDMapForCSLForest(DMap, Labels, ImgLinks, frontend, description, VOCAB_SIZE, N_VOCAB_PER_CAT, filesPerCat, useSavedData, rstream)
    global OutputPath
    global SIFTBorder
    
    for i = 1:numel(DMap)
        tempMap = reshape(DMap{i}, numel(DMap{i}), 1);
        [histee(i,:), ~] = hist(tempMap, VOCAB_SIZE);
    end
    
    ReferenceImgs = cell(1, numel(ImgLinks));
    for nFile = 1:numel(ImgLinks)
        ImgLink = ImgLinks{nFile};
        imagemat = imread(ImgLink{1});
        ReferenceImgs{nFile} = imagemat;
    end
    
    L1Bags = histee;
    windows = ones(numel(DMap), 4);
    for i = 1:numel(DMap)
        windows(i,3) = size(DMap{i}, 2);
        windows(i,4) = size(DMap{i}, 1);
    end
    
    outputFn = strcat(frontend, '_L1Bags_Labels_Plus_', datestr(now, 'mmm_dd_yyyy_HH_MM_SS_FFF'), '.mat');
    save(strcat(OutputPath, outputFn), 'description', 'L1Bags', 'Labels', 'DMap', 'ReferenceImgs', 'frontend', 'VOCAB_SIZE', 'N_VOCAB_PER_CAT', 'filesPerCat', 'useSavedData', 'rstream', 'windows', 'ImgLinks', 'SIFTBorder', '-v7.3');
end