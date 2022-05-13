% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function centroids = simple_means (data, dataByLabels, maxk)
    % return maxk centroids with an even number, if possible, in each class

    centroids = [];
    d = size(data,1); % number of data points
    c = size(dataByLabels,1); % number of categories
    if maxk >= d
        centroids = data;
    else
        meansPerClass = zeros(1, c);
        meansPerClass(:) = floor(maxk/c);
    
        if sum(meansPerClass) < maxk
            % get correct number of centroids overall
            numNeeded = maxk - sum(meansPerClass);
            bonusClusters = randsample(1:c,numNeeded,0); % WITHOUT replacement
            for i = 1:numel(bonusClusters)
                meansPerClass(bonusClusters(i)) = meansPerClass(bonusClusters(i)) + 1;
            end
        end
    
        for idx = 1:c
            classData = dataByLabels{idx,2};
            if size(classData,1) > meansPerClass(idx) % don't try to make centroids without min amount of data
                [~,ctrs] = kmeans(classData, meansPerClass(idx), 'emptyaction', 'drop');
            else
                ctrs = classData;
            end
            centroids = vertcat(centroids, ctrs);
        end
    
        % if we don't have enough centroids by contribution from each class
        if size(centroids,1) < maxk
        	rem_k = maxk - size(centroids,1);
            pts = randperm(d);
            ctrs = data(pts(1:rem_k),:);
            centroids = vertcat(centroids, ctrs);
        end
    end
    
end
