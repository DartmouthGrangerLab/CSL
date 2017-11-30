% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [Means,Variances,MixCoeffs,InitWindows] = EM_Init_Using_Windows (DMap, VOCAB_SIZE, K, ExcludeN, rstream, JSSettings)
    PYR_LEVELS = JSSettings.PYR_LEVELS;
    
    ZERO_OFFSET = 0.0000000001;
    N = numel(DMap);
        
    InitWindows = GetInitialWindows(DMap, JSSettings.WinMode);
    
    for i = 1:N
        fprintf('i = %d\n', i);
        H(i,:) = CalcPyramidWindowHist(DMap{i}, InitWindows(i,:), VOCAB_SIZE, PYR_LEVELS);
    end
    
    %% Initialize Mixture Coefficients for the topics
    MixCoeffs = ones(1, K) / K; % uniform mixture coeffs
    
    %% Get Initial GMM means
    Means = MyCalcMeanspp(H, K, ExcludeN, JSSettings.NSEEDS_EMINIT);

    %% Estimate Gamma
    Gamma = (1/(K+1)) * ones(N, K);

    %% Estimate Labels
    for i = 1:N
        BestProb = -Inf;
        for k = 1:K
            LogProb = CalcGaussLogProb(H(i,:), Means(k,:), ones(1, numel(Means(k,:))));
            if LogProb > BestProb
                BestProb = LogProb;
                InitLabels(i) = k;
            end
        end
    end
    Means = zeros(K, size(H, 2));
    for i = 1:N
        Means(InitLabels(i),:) = Means(InitLabels(i),:) + H(i,:);
    end
    for k = 1:K
        Means(k,:) = Means(k,:) ./ numel(find(InitLabels == k));
    end

    for i = 1:N
       for k = 1:K
           Dist(k) = norm((H(i, :) - Means(k,:)), 2);
       end
       [~,idx] = min(Dist);
       Gamma(i,idx) = 2 / (K+1);
    end

    %% Estimate variance
    M = size(Means, 2);
    for k = 1:K
        Denom = sum(Gamma(:,k));
        for j = 1:M
            Variances(k,j) = 0;
            for i = 1:N
                Variances(k,j) = Variances(k,j) + Gamma(i,k) * (H(i, j) - Means(k,j))^2;
            end
            Variances(k,j) = Variances(k,j) ./ Denom + ZERO_OFFSET;
        end
    end 
end


function [PairWiseErgy] = CalculatePairWiseEnergy (H)
    N = size(H, 1);
    PairWiseErgy = zeros(N,N);
    for i = 1:N
       for j = i+1:N
           PairWiseErgy(i,j) = norm(H(i,:) - H(j,:), 2);
           PairWiseErgy(j, i) = PairWiseErgy(i, j);
       end
    end
end


function [PrunedIndices] = PruneOutliers (Enrgy)
    N = size(Enrgy, 1);

%     for i = 1:N      
%        [vals,~] = sort(Enrgy(i,:), 'Ascend');
%        EnrgyForWin(i) = mean(vals(1:min(20, N))); % Could change this in conjuncion with threshold for pruning
%     end
% %     AvgEnrgy = mean (EnrgyForWin);
% %     StdEnrgy = std(EnrgyForWin);
    
    cnt = 1;

    for i = 1:N
        if 1 %EnrgyForWin(i) - AvgEnrgy < StdEnrgy   % For best results
            PrunedIndices(cnt) = i;
            cnt = cnt + 1;
        end
    end
end


function [Centroids] = SelectRnd (PairWiseErgy, PrunedIndices, K, ExcludeN)
    CandLst = PrunedIndices;
    for k = 1:K
        rndidx = randi(numel(CandLst));
        Centroids(k) = CandLst(rndidx);
        CandLst(rndidx) = [];
        % and remove the top ExcludeN matches from the candlst
        [~,idxs] = sort(PairWiseErgy(Centroids(k),CandLst), 'Ascend');
        CandLst(idxs(1:ExcludeN)) = [];        
    end
end


function [Means] = MyCalcMeanspp (H, K, ExcludeN, NSeeds)
    PairWiseErgy = CalculatePairWiseEnergy(H);
    PrunedIndices = PruneOutliers(PairWiseErgy);
    
    Candidates = zeros(NSeeds, K);

    for sd = 1:NSeeds
        cnt = zeros(1,K);
        rndlist = SelectRnd(PairWiseErgy, PrunedIndices, K, ExcludeN);%randperm(NewN);
        
        Candidates(sd,:) = rndlist(1:K);
    end
       
    for sd = 1:NSeeds
        Score(sd) = GetMeanScore(H, Candidates(sd,:), PairWiseErgy);  
    end     
    
    [~,Winners] = sort(Score, 'Ascend');
    Means(:,:) = H(Candidates(Winners(1),:),:);    
end


function [Score] = GetMeanScore (H, CentroidIndices, PairWiseErgy)
    K = numel(CentroidIndices);
    N = size(H, 1);
    
    %[Idxs] = kmeans(H, [], 'start', H(CentroidIndices, :));
    
    % Find memberships
    for i = 1:N
       [~,Idxs(i)] = min(PairWiseErgy(i, CentroidIndices));
    end
    
    % For each cluster find total number of samples > N/K
    Score = 0;
    for k = 1:K
        [vals] = find(Idxs == k);
        Score = Score + abs(N/K - numel(vals));
        %Score = Score + val(i);
    end
end

