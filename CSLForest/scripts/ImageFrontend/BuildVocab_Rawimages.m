% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [vocab,VOCAB_SIZE] = BuildVocab_Rawimages(VOCAB_SIZE, ImgLinks)
    allvals = [];
    for nFile = 1:numel(ImgLinks)
        fn = ImgLinks{nFile};
        I = imread(char(fn{1}));
        I = double(I);
        if numel(allvals) == 0
            allvals = reshape(I, 1, numel(I));
        else
            allvals = [allvals reshape(I, 1, numel(I))];
        end
    end
    vocab = unique(allvals)';
    if VOCAB_SIZE == 0 || VOCAB_SIZE > numel(vocab)
        fprintf('Vocab size changed from %d to %d.\n', VOCAB_SIZE, numel(vocab));
        VOCAB_SIZE = numel(vocab);
    else
        load(fullfile('CSLForest', 'resources', 'rstream.mat'), 'rstream');
        opts = statset('Display', 'iter', 'Streams', rstream, 'MaxIter', 20);
        [centers, mincenter, mindist, lower, computed] = anchors(mean(vocab), VOCAB_SIZE, vocab);
        [Idx, vocab] = kmeans(vocab, VOCAB_SIZE, 'start', centers, 'Distance', 'sqEuclidean',...
                'onlinephase', 'on','emptyaction','drop','Options', opts);
    end
end