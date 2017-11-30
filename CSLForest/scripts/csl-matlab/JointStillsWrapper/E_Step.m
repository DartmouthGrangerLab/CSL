% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%   http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%   http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) E step compute posterior  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Gamma = E_Step (DMap, RectWins, Means, Variances, MixCoeffs, VOCAB_SIZE, PYR_LEVELS)
    K = size(Means, 1);
    N = numel(DMap);
   
    for i = 1:N
        H(i,:) = CalcPyramidWindowHist(DMap{i}, RectWins(i,:), VOCAB_SIZE, PYR_LEVELS);
    end
    
    %H = H(:,1:end-1); % trim off the last column of the overall histogram counts, so none of the many extra VOCAB+1 get used.
    Gamma = zeros(N, K);
    for i = 1:N
        for k = 1:K
            Gamma(i,k) = log(MixCoeffs(k)) + CalcGaussLogProb(H(i,:), Means(k,:), Variances(k, :));
        end
    end

    % normalize posterior
    [C, ~] = max(Gamma, [], 2);
    %the below code causes precision errors :(
    for i = 1:N
        %Gamma(i,:) = abs(Gamma(i,:));
        %Gamma(i,:) = Gamma(i,:) - min(squeeze(Gamma(i,:)));
        %Gamma(i,:) = Gamma(i,:) / max(squeeze(Gamma(i,:)));
        %the below code causes precision errors :(
        for k = 1:K
            Gamma(i,k) = exp(Gamma(i,k) - C(i));
        end
        denom = sum(Gamma(i,:));
        Gamma(i,:) = Gamma(i,:) / denom;
    end
end
