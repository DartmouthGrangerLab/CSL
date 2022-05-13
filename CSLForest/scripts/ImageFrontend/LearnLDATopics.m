% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% DESCRIPTION: Determines LDA topics for dataset.
function [] = LearnLDATopics(VOCAB_SIZE, N_CATS, T, frontend)
    global DatasetPath
    
    load(strcat(DatasetPath, 'Data_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS), '.mat'));
    H = [];
    for i = 1:numel(DMap)
        fprintf('Outer loop thru DMap, %d of %d\n', i, numel(DMap));
        DMap{i}(DMap{i}==0) = VOCAB_SIZE + 1;
        H(i, :) = CalcPyramidWindowHist(DMap{i}, [1, 1, size(DMap{i}, 2), size(DMap{i}, 1)], VOCAB_SIZE + 1, 1);
    end
    % this is how it's called in the c++ code Run_LDA(DMap, KK, dp, wp, ALPHA, BETA, SEED); 
    fprintf('Into LDAMex code...\n');
    [pdz,pwz] = LDAMexInterface(H, T, 50/T, 200/VOCAB_SIZE, 1);
    save(strcat(DatasetPath, 'pwz_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS), 'T', num2str(T)), 'pwz');            
end
