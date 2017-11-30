% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%   http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%   http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [PredLabel] = ForeGd_EM_CSL_Test (DMap, RectWins, Means, Variances, MixCoeffs, VOCAB_SIZE, Win_Prior_Mean, Win_Prior_Variance, PYR_LEVELS, C, TOL_FAC)
    %% prepare the data
    PixSiftMap = DMap;
    
    %% EM algorithm
    FeatMap = PixSiftMap;
    
    % E-step
    Gamma = E_Step(FeatMap, PixSiftMap, RectWins, Means, Variances, MixCoeffs, VOCAB_SIZE, PYR_LEVELS);
    % M-step
    evalc('[RectWins,~,~,MixCoeffs] = M_Step(FeatMap, PixSiftMap, RectWins, Means, Variances, Gamma, VOCAB_SIZE, PYR_LEVELS, C, TOL_FAC, Win_Prior_Mean, Win_Prior_Variance);');

    %% Estimate Labels
    H = CalcPyramidWindowHist(FeatMap{1}, RectWins(1,:), VOCAB_SIZE, PYR_LEVELS);
    
    BestProb = -Inf;
    for k = 1:size(Means, 1)
        LogProb = CalcGaussLogProb(H, Means(k,:), Variances(k,:));
        if LogProb > BestProb
            BestProb = LogProb;
            PredLabel = k;
        end
    end
end
