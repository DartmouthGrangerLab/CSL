% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [centroids] = init_centroids_supervised (data, labels, points, maxk)
    %% Supervised centroid initilization for kmeans
    % INPUT:
    % data : data present at the node
    % labels : Training labels
    % points: Training points corresponding to the data 

    % OUTPUT:
    % centroids: returns initilized centroids for clustering the node
    lset = zeros(length(points), 1);
    for i = 1:length(points)
        lset(i) = labels(points(i));
    end

    label_set = unique(lset);

    dataByLabels = cell(length(label_set), 1);
    for i = 1:length(label_set)
        dataByLabels{i,1} = find(lset==label_set(i));
    end

    for i = 1:length(dataByLabels)
        dataByLabels{i,2} = data(dataByLabels{i,1},:);
    end

    for i = 1:length(dataByLabels)
        class_means(i,:) = sum(dataByLabels{i,2},1)/(size(dataByLabels{i,2},1));
    end

    % labels(points(8)) corresponds to data(8)
    % dataByLabels keeps track, how many points belong to a single label at that node, 
    % the loot case it has two cells, corresponding to 2 categories amd each cell is a histogram of points belonging 
    % to that category so u can just pick rows directly

    if maxk > length(label_set)
        centroids = simple_means(data, dataByLabels, maxk);
    elseif maxk == length(label_set)
        centroids = class_means;
    else
        centroids = old_simple_means(class_means, maxk);
    end
end
