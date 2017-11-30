% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [RectWins,PredLabels,Means,Variances,Gammas,ResultH] = ForeGd_EM (DMap, RectWins, Means, Variances, MixCoeffs, VOCAB_SIZE, Win_Prior_Mean, Win_Prior_Variance, JSSettings)
    %% EM algorithm
    Li = [];
    Li(1) = -Inf;

    FeatMap = DMap;
    for it = 2:JSSettings.EM_MAX_IT
        %E-step
        %assigns each image to a cluster based on foreground histogram
        Gammas = E_Step(DMap, RectWins, Means, Variances, MixCoeffs, VOCAB_SIZE, JSSettings.PYR_LEVELS);
        
        %M-step
        %adjusts foreground locations to match GMM cluster means
        %calculates new image histograms
        %adjusts GMM cluster means to match new foregrounds
        fprintf('It:%d\n', it);
        [RectWins,Means,Variances,MixCoeffs] = M_Step(DMap, RectWins, Means, Variances, ...
                Gammas, VOCAB_SIZE, JSSettings.PYR_LEVELS, JSSettings.C, JSSettings.TOL_FAC, Win_Prior_Mean, Win_Prior_Variance);
        
        %Evaluate data log-likelihood
        [Li(it),AppL(it)] = Calc_LogL(Gammas, MixCoeffs, FeatMap, RectWins, Means, Variances, ...
                VOCAB_SIZE, JSSettings.PYR_LEVELS, Win_Prior_Mean, Win_Prior_Variance);

        dLi = (Li(it) - Li(it-1)) / (Li(it));
        if abs(dLi) < JSSettings.LL_THRESH
            break;
        end

        if Li(it) + eps < Li(it-1)
            Li(it) = -inf;
            AppL(it) = -inf;
            fprintf('LL ERROR!!!\n');
            break;
        end
    end

    %% Estimate Labels
    for i = 1:numel(FeatMap)
        BestProb = -Inf;
        
        ResultH(i,:) = CalcPyramidWindowHist(FeatMap{i}, RectWins(i,:), VOCAB_SIZE, JSSettings.PYR_LEVELS);

        for k = 1:size(Means, 1)
            LogProb = CalcGaussLogProb(ResultH, Means(k,:), Variances(k, :));
            if LogProb > BestProb
                BestProb = LogProb;
                PredLabels(i) = k;
            end
        end
    end
end
