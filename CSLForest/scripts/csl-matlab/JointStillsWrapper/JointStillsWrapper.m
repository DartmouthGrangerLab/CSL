% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [C,cluster_centroids,cluster_variances,OutRectWins] = JointStillsWrapper (DMap, JSSettings)
    load rstream;
    Win_Prior_Mean = JSSettings.Win_Prior_Mean;
    Win_Prior_Variance = JSSettings.Win_Prior_Variance;
    K = JSSettings.K;
    VOCAB_SIZE = JSSettings.VOCAB_SIZE;
    
    T = VOCAB_SIZE + 1;
    N = numel(DMap);
    
    fprintf('Running JointStills on %d datapoints\n', numel(DMap));
    
    %% Initialize GMM parameters, FG Windows
    [Means,Variances,MixCoeffs,InitWindows] = ...
        EM_Init_Using_Windows(DMap, T, K, floor((2.0*N)/(3.0*K)), rstream, JSSettings);
    
    %% Conduct Expectation Maximization
    evalc('[OutRectWins,C,cluster_centroids,cluster_variances,~,~] = ForeGd_EM(DMap, InitWindows, Means, Variances, MixCoeffs, T, Win_Prior_Mean, Win_Prior_Variance, JSSettings);');
    cluster_centroids = cluster_centroids(:,1:VOCAB_SIZE);
    cluster_variances = cluster_variances(:,1:VOCAB_SIZE);
end