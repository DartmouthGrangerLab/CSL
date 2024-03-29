% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function bagged_points = supervised_bagging(labels, bf)
    %% Bagging data into random samples for each tree 
    % INPUT:
    % labels : Training labels
    % bf (bagging fraction): the feaction of the total training data used to train individual trees 

    % OUTPUT:
    % bagged_points : a array of randomly selected data points from the training dataset (almost equal representation of each category)
    
    label_set = unique(labels);
    bagged_points = [];
    
    for i = 1:length(label_set)
        idx = find(labels==label_set(i));
        idx = idx(randperm(length(idx)));
        n = ceil(bf * length(idx));
        bagged_points = [bagged_points;idx(1:n)];
    end
end
