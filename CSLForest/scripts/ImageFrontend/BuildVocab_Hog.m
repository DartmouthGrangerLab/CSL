% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [vocab] = BuildVocab_Hog (VOCAB_SIZE, N_CATS)
    global ResourcePath;
    global VocabCatFile;
    
    load('rstream');
    opts = statset('Display', 'iter', 'Streams', rstream, 'MaxIter', 20);
    fprintf('Starting vocab building with vocab size:%d, number of categories:%d\n', VOCAB_SIZE, N_CATS);
    Feats = GatherFeatures(ResourcePath, VocabCatFile, VOCAB_SIZE, N_CATS);    
    
    % using built-in kmeans but with our own calc of starting 'anchors' seems to be causeing problems...
%     [centers, mincenter, mindist, lower, computed] = anchors(mean(Feats), VOCAB_SIZE, Feats);
%     [Idx, vocab] = kmeans(Feats, VOCAB_SIZE, 'start', centers, 'Distance', 'sqEuclidean',...
%                 'onlinephase', 'on', 'emptyaction', 'drop', 'Options', opts);
    % using built-in kmeans but with 'clusters' option for starting points.
    [Idx, vocab] = kmeans(Feats, VOCAB_SIZE, 'start', 'cluster', 'Distance', 'sqEuclidean',...
            'onlinephase', 'on', 'emptyaction', 'drop', 'Options', opts);
end


function [FeaturesForLevel] = GatherFeatures (ResourcePath, CatFile, VOCAB_SIZE, N_CATS)
    global N_VOCAB_PER_CAT;
    global ImgPath;
    load('rstream');
    
    VocabFileList = importdata(strcat(ResourcePath, '/', 'VocabFileList'));
    opts = statset('Display', 'iter', 'Streams', rstream, 'MaxIter', 20);

    FeaturesForLevel = [];
    [CatDirs] = importdata(strcat(ResourcePath, CatFile), ' ');
    for nDir = 1:min(N_CATS, numel(CatDirs))
        for nFile = 1:N_VOCAB_PER_CAT
            fnc = strcat(ImgPath, char(CatDirs(nDir)), '/', VocabFileList((nDir-1)*N_VOCAB_PER_CAT + nFile));
            fn = fnc{1};

            [Features, Locations] = GetHOGFeaturesFromFile(fn);

            [centers, mincenter, mindist, lower, computed] = anchors(round(mean(Features)), VOCAB_SIZE, Features);

            [Idx, KMFeatures] = kmeans(Features, VOCAB_SIZE, 'start', centers, 'Distance', 'sqEuclidean',...
                 'onlinephase', 'on', 'emptyaction', 'drop', 'Options', opts);

            FeaturesForLevel = vertcat(FeaturesForLevel, KMFeatures); %Features now being the kmeans clustered version
        end
    end
    
end
    
    