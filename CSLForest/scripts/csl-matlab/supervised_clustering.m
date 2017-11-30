% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [clusters,node_centroids,node_variances,root,feature_space,outRectWins] = supervised_clustering (data, root, idx, node_centroids, node_variances, ff_points, feature_space, centroids, points, DMap, JSSettings, clusterModule)
    %% Kmeans clustering and creation of nodes
    % INPUT:
    % data : histogram of randomly selected features
    % root : training  tree
    % idx : ID of the parent to which the new nodes are to be added
    % node_centroids : empty cell which returns the learned centroids at each node in the tree
    % ff_points : random features selected to split the node
    % feature_space : empty cell which returns the feature points considered to split the data at a node
    % points : data points to split at each node

    % OUTPUT:
    % clusters : returns the clusters formed at the node after kmeans
    % node_centroids : cluster centroids corresponding to the clusters
    % root : returns the training tree with new nodes added

    %default data
    outRectWins = [];

    if strcmp(clusterModule, 'kmeans')
        opts = statset('MaxIter', 30);
        [C,cluster_centroids] = kmeans(data,[],'start',centroids,'options',opts,'emptyaction','drop');%, 'onlinephase','on');
        cluster_variances = ones(size(cluster_centroids, 1), size(cluster_centroids, 2)) * -1; %filler data
    elseif strcmp(clusterModule, 'gmm')
        error('ERROR: GMM not implemented yet (somebody copy it from the C code!');
    elseif strcmp(clusterModule, 'jointstills')
        [C,cluster_centroids,cluster_variances,outRectWins] = JointStillsWrapper(DMap, JSSettings);
    else
        error('ERROR: please set clusterModule to ''kmeans'', ''gmm'', or ''jointstills''.');
    end
    cluster_number = unique(C);
    for i = 1:length(cluster_number)
        clusters{i} = points(C==cluster_number(i));
        [root,ID] = root.addnode(idx, clusters{i});
        node_centroids = q_fifo(node_centroids, 'push', cluster_centroids(i,:));
        node_variances = q_fifo(node_variances, 'push', cluster_variances(i,:));
        feature_space = q_fifo(feature_space, 'push', ff_points);
    end
end

