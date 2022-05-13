% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% RETURNS: a set of cluster centroids
function centroids = old_simple_means(class_means, maxk)
	N = size(class_means, 1);    
	
	EPS = 0.0000000001;
	means = ones(1, maxk) * -1; % means(i) is the index of the class that's mean for cluster i
	bestDist = ones(1, N) * realmax; % for class i, bestDist(i) gives the shortest distance between this class and the centroid of one of the clusters
    centroids = zeros(N, size(class_means, 2));
	means(1) = 1; % assume the first class is the centroid of the first cluster
  
	%% Create clusters with their centroids 
	for currCluster = 2:maxk
		bestCandidateForClusterCentroid = 0; % idx of the class that's the best candidate for this cluster's centroid
		currBestDistOverall = 0;  % shortest distance between this cluster's centroid and all the considered classes
        % for every class
		for i = 1 : N
            % find the distance between class i and currCluster's current centroid
            dist = sum(( class_means(i,:) - class_means(means(currCluster-1), :)).^2);
                        
            % if this is the cluster this class is closest to, then record that for later
			bestDist(i) = min(dist, bestDist(i) + EPS);

            % if of all the classes possibly belonging to this cluster,
            % this class is the closest to the cluster's centroid, then
            % this class will be the centroid for the cluster
			if bestDist(i) > currBestDistOverall
				currBestDistOverall = bestDist(i);
				bestCandidateForClusterCentroid = i;
			end
		end

		if bestCandidateForClusterCentroid >= 1
			means(currCluster) = bestCandidateForClusterCentroid;
		end
    end

    %% Assign classes to clusters
	for i = 1:N
		shorestDistanceToClosestCluster = realmax;
        % find the cluster the class is closest to and assign the class to that cluster
        for currCluster = 1:maxk
			dist = sum((class_means(i,:) - class_means(means(currCluster),:)).^2);
            if dist < shorestDistanceToClosestCluster
				shorestDistanceToClosestCluster = dist;
                centroids(i,:) = class_means(currCluster, :); 
            end
        end
	end
end
