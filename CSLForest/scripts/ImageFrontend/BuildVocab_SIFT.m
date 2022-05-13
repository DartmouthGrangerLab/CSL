% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function vocab = BuildVocab_SIFT(VOCAB_SIZE, N_CATS)
    global ResourcePath
    global VocabCatFile
    
    load(fullfile('CSLForest', 'resources', 'rstream.mat'), 'rstream');
    opts = statset('Display', 'iter', 'Streams', rstream, 'MaxIter', 20);
    fprintf('Starting vocab building with vocab size:%d, number of categories:%d\n', VOCAB_SIZE, N_CATS);
    Feats = GatherFeatures(ResourcePath, VocabCatFile, VOCAB_SIZE, N_CATS);    
    
    % using built-in kmeans
    [centers, mincenter, mindist, lower, computed] = anchors(mean(Feats), VOCAB_SIZE, Feats);
    [Idx, vocab] = kmeans(Feats, VOCAB_SIZE, 'start', centers, 'Distance', 'sqEuclidean',...
                'onlinephase', 'on', 'emptyaction', 'drop', 'Options', opts);
end


function FeaturesForLevel = GatherFeatures(ResourcePath, CatFile, VOCAB_SIZE, N_CATS)
    global N_VOCAB_PER_CAT
    global ImgPath
    load(fullfile('CSLForest', 'resources', 'rstream.mat'), 'rstream');
    
    VocabFileList = importdata(strcat(ResourcePath, '/', 'VocabFileList'));
    opts = statset('Display', 'iter', 'Streams', rstream, 'MaxIter', 20);

    numImages = size(VocabFileList, 1);

    FeaturesForLevel = [];
    [CatDirs] = importdata(strcat(ResourcePath, CatFile), ' ');
    for nDir = 1:min(N_CATS, numel(CatDirs))
        for nFile = 1:N_VOCAB_PER_CAT
            fprintf('Preprocessing vocab image %d of %d\n', (nDir-1)*N_VOCAB_PER_CAT + nFile, numImages ); 
            tic;
            fnc = strcat(ImgPath, char(CatDirs(nDir)), '/', VocabFileList((nDir-1)*N_VOCAB_PER_CAT + nFile));
            fn = fnc{1};
            fprintf('GetSiftFeatures from file: %s\n', fn);
            [Features, Locations] = GetSiftFeaturesFromFile(fn);
            TimeSpent = toc;
            fprintf('GetSiftFeatures Single Inner Loop SIFT Time: %d\n', TimeSpent);
            fprintf('GetSiftFeatures Number of Features: %d x %d\n', size(Features));
            TimeSpent = 0;
            
            tic; %using built-in kmeans
            [centers, mincenter, mindist, lower, computed] = anchors(round(mean(Features)), VOCAB_SIZE, Features);
            [Idx, KMFeatures] = kmeans(Features, VOCAB_SIZE, 'start', centers, 'Distance', 'sqEuclidean',...
                 'onlinephase', 'on', 'emptyaction', 'singleton', 'Options', opts);
            nanKMFeatures = isnan(KMFeatures);
            if numel(nanKMFeatures(nanKMFeatures==1)) > 0
                error('NaN in BuildVocab_SIFT');
            end
            TimeSpent = toc;
            fprintf('GetSiftFeatures Single Inner Loop Builtin KMeans Time: %d\n', TimeSpent);
            FeaturesForLevel = vertcat(FeaturesForLevel, KMFeatures); %Features now being the kmeans clustered version

            TimeSpent = 0;
        end
    end
    
end
