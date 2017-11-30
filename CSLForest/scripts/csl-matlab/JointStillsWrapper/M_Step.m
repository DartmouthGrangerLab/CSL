% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [RectWins,Means,Variances,MixCoeffs] = M_Step (DMap, RectWins, Means, Variances, Gamma, VOCAB_SIZE, PYR_LEVELS, C, tolFac, Win_Prior_Mean, Win_Prior_Variance)
    K = size(Means,1);
    N = size(Gamma, 1);
    ZERO_OFFSET = 0.0000000001;
    
    %% Estimate new mixing coefficients
    for k = 1:K
        MixCoeffs(k) = sum(Gamma(:,k))/ N + ZERO_OFFSET;
    end
    
    %% Estimate New Foregrounds
    for i = 1:N
        RectWinsTemp(1,:) = CalculateOptimalForegroundRect(DMap{i}, Means, Variances, Gamma(i,:), VOCAB_SIZE, PYR_LEVELS, C, tolFac, Win_Prior_Mean, Win_Prior_Variance);
        %by Eli - solves issue that cosegment_bbox sometimes returns [0,0,0,0] (aka it fails):
        if numel(RectWinsTemp(RectWinsTemp==0)) == 0 %else leave old value
            RectWins(i,:) = RectWinsTemp;
        else %leave old value
            fprintf('WARNING: failed to calculate optimal foreground rect for image %d\n', i);
        end
    end
    
    for i = 1:N
        H(i,:) = CalcPyramidWindowHist(DMap{i}, RectWins(i,:), VOCAB_SIZE, PYR_LEVELS);
    end
    
    %% Estimate GMM Means
    M = size(Means, 2);
    for k = 1:K
        Numerator = zeros(1, M);
        for i = 1:N
            Numerator = Numerator + Gamma(i,k) .* H(i,:);
        end
        Means(k,:) = Numerator ./ sum(Gamma(:,k));
    end
    
    %% Estimate GMM Variance
    for k = 1:K
        for j = 1:M
            Variances(k,j) = 0;
            for i = 1:N
                Variances(k,j) = Variances(k,j) + Gamma(i,k) * (H(i, j) - Means(k,j))^2;
            end
            Variances(k,j) = Variances(k,j) ./ sum(Gamma(:,k)) + ZERO_OFFSET;
        end
    end
end


