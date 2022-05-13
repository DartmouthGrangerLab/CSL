% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [VOCAB_SIZE,vocab] = DatasetPreprocessor(VOCAB_SIZE, N_CATS, ImgLinks, frontend, vocab, rstream)
    global ResourcePath; % bbt adding ResourcePath here so that the data that is preprocessed is the data that is actually used for the model run.
    global DatasetPath;
    
    fprintf('Doing Dataset Preprocessing\n');
    
    %% Quantize images in dataset (generate document map)
    if numel(vocab) == 0
        generateVocab = 1;
    else
        generateVocab = 0;
    end
    
    DetermineVocabData(rstream);
    
    % create pool if it timed out
    currPool = gcp('nocreate');
    if isempty(currPool)
        poolsize = parcluster; % get pool size from default profile
        parpool(poolsize);
    end
        
    if strcmp(frontend, 'sift')
        if generateVocab
            [vocab] = BuildVocab_SIFT(VOCAB_SIZE, N_CATS);
        end
        parfor nFile = 1:numel(ImgLinks)
            fn = ImgLinks{nFile};
            DMap{nFile} = GetQuantizedImg_SIFT(fn{1}, vocab);
        end
        
    elseif strcmp(frontend, 'concentricsubtraction')
        %*** CONCENTRIC SUBTRACTION ***
        QuantImg = {};
        parfor nFile = 1:numel(ImgLinks)
            fn = ImgLinks{nFile};
            I = imread(char(fn{1}));
            [m, n, r] = size(I);
            if (r == 3)
                I = double(rgb2gray(I));
            else
                I = double(I);
            end
            QuantImg{nFile} = GetCenterSurround(I, 0);
        end
        if generateVocab
            [vocab, VOCAB_SIZE] = BuildVocab_Concentricsubtraction(VOCAB_SIZE, QuantImg);
        end
        parfor nFile = 1:numel(QuantImg)
            I = QuantImg{nFile};
            %I = I{1};
            [m, n, r] = size(I);
            for i = 1:m
                for j = 1:n
                    for k = 1:r
                        I(i, j, k) = CalculateBestFitVocabIndex(I(i, j, k), vocab);
                    end
                end
            end
            DMap{nFile} = I;
        end
        
    elseif strcmp(frontend, 'hog')     
        if generateVocab
            [vocab] = BuildVocab_Hog(VOCAB_SIZE, N_CATS); %call SIFT version on Looting imagery data
        end
        parfor nFile = 1:numel(ImgLinks)
            fn = ImgLinks{nFile};
            [DMap{nFile},Filter{nFile}] = GetQuantizedImg_Hog(fn{1}, vocab);
        end
        
    elseif strcmp(frontend, 'mser')
        error('not currently supported');
            
    elseif strcmp(frontend, 'surf')     
        error('not currently supported');
        
    elseif strcmp(frontend, 'liop')
        error('not currently supported');
    
    elseif strcmp(frontend, 'raw-images')
        %*** RAW IMAGES ***
        if generateVocab
            [vocab, VOCAB_SIZE] = BuildVocab_Rawimages(VOCAB_SIZE, ImgLinks);
        end
        parfor nFile = 1:numel(ImgLinks)
            fn = ImgLinks{nFile};
            I = imread(char(fn{1}));
            [m, n, r] = size(I);
            I = double(I);
             for i = 1:m
                for j = 1:n
                    for k = 1:r
                        I(i, j, k) = CalculateBestFitVocabIndex(I(i, j, k), vocab);
                    end
                end
            end
            DMap{nFile} = I;
        end
    
    elseif strcmp(frontend, 'msharris')  
        %*** Multiscale Harris ***
        if generateVocab
            [vocab] = BuildVocab_MSHarris(VOCAB_SIZE, N_CATS);
        end
       
        parfor nFile = 1:numel(ImgLinks)
            fn = ImgLinks{nFile};
            DMap{nFile} = GetQuantizedImg_MSHarris(fn{1}, vocab);
        end
        
    else
        error('Invalid frontend specified');
    end
            
    mkdir(DatasetPath);
    if exist('Filter')
        save(strcat(DatasetPath, 'Data_', frontends, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS)), 'DMap', 'Filter', '-v7.3');
    else
        save(strcat(DatasetPath, 'Data_', frontend, '_V', num2str(VOCAB_SIZE), 'Cats', num2str(N_CATS)), 'DMap', '-v7.3');
    end
    fprintf('Done with Dataset Preprocessing\n');
end
