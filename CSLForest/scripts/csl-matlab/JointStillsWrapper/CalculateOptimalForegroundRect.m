% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [RectWins] = CalculateOptimalForegroundRect (DMap, Means, Variances, iGamma, VOCAB_SIZE, PYR_LEVELS, C, TOL_FAC, Win_Prior_Mean, Win_Prior_Variance)
    Mu = Means';
    K = size(Means, 1);
    M = size(Means, 2);
    
    %Calculate the weights
    W = zeros(K*M, 1);
    for k = 1:K
        W((k-1)*M+1:k*M) = iGamma(k) .* (ones(M,1) ./ (Variances(k,:)'));
    end
    
    %Find best matching foreground
    [RectWins] = ml_findBox1a(DMap, Mu(:), W, VOCAB_SIZE*size(DMap,3), K, C, TOL_FAC, PYR_LEVELS, inf, Win_Prior_Mean, Win_Prior_Variance, 1);
end