% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [DMap] = PrepareData (VOCAB_SIZE, N_CATS, T, frontend)
    global DatasetPath;
    
    pwz = [];

    load(strcat(DatasetPath, 'Data_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS), '.mat')); % loads DMap (in terms of vocabulary and not in terms of LDA) and Labels
    SiftDMap = DMap;
    
    if T > 0
        fprintf('Loading %s\n', strcat(DatasetPath, 'pwz_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS), 'T', num2str(T), '.mat')); 
        load(strcat(DatasetPath, 'pwz_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS), 'T', num2str(T), '.mat')); % loads pwz
    end
    
    for i = 1:numel(SiftDMap)
        SiftDMap{i}(SiftDMap{i}==0) = VOCAB_SIZE + 1;
        if exist('Filter','var')
            if Filter{1} ~= 0
                SiftDMap{i}(Filter{i}) = VOCAB_SIZE + 1;
            end
        end
    end
    if T > 0
        DMap = ConvertImgToTopic(SiftDMap, pwz);
    else
        DMap = SiftDMap;
    end
end


