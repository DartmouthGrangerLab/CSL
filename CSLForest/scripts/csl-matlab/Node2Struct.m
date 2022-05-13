% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function forest = Node2Struct(root, node_centroids, node_variances, feature_space, ntrees)
    forest{ntrees} = {};
    temp{ntrees} = {};
    for i = 1:ntrees
        forest{i} = struct(root{i});
        temp{i} = struct2cell(forest{i});
        for j = 1:length(node_centroids{i})
            temp{1,i}{1}{j+1,2} = node_centroids{1,i}{1,j};
            temp{1,i}{1}{j+1,3} = feature_space{1,i}{1,j};

            temp{1,i}{1}{j+1,4} = [];

            temp{1,i}{1}{j+1,5} = node_variances{1,i}{1,j}; %variance data (only used for JointStills)
        end
        forest{i}.Node = temp{1,i}{1};
    end
end
