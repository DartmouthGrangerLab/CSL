% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data log-likelihood 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ObjL,AppL] = Calc_LogL (Gamma, MixCoeffs, FeatMap, RectWins, Means, Variances, VOCAB_SIZE, PYR_LEVELS, FG_SIZE_Mean, FG_SIZE_Var)
    ObjL = 0;
    AppL = 0;
    N = size(Gamma, 1);
    K = size(Means, 1);
    
    for i = 1:N
        H(i,:) = CalcPyramidWindowHist(FeatMap{i}, RectWins(i,:), VOCAB_SIZE, PYR_LEVELS);        
        
        for k = 1:K
            ObjL = ObjL + Gamma(i,k) * (log(MixCoeffs(k)) + CalcGaussLogProb(H(i,:), Means(k,:), Variances(k, :)));
            AppL = AppL + Gamma(i,k) * (log(MixCoeffs(k)) + CalcGaussLogProb(H(i,:), Means(k,:), Variances(k, :)));
        end

        %Prior on size for window
        Denom = size(FeatMap{i}); %(NRows, NCols)
        ObjL = ObjL + CalcGaussLogProb([((RectWins(i, 3) - RectWins(i, 1)) / Denom(2))* ... %Number of cols in window normalized by the total number of cols
                                ((RectWins(i, 4) - RectWins(i, 2)) / Denom(1))], ... %Number of rows in window normalized by the total number of rows
                                FG_SIZE_Mean(1)*FG_SIZE_Mean(2), FG_SIZE_Var(1));
    end
end


