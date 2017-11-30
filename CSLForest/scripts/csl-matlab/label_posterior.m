% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [predict_label,forest] = label_posterior (forest, test_data, DMapEntry, labels, ntrees, test_point, JSSettings, clusterModule)
    predict_node = zeros(1,ntrees);
    content{ntrees} = {};
    memcnt{ntrees} = {};
    prob{ntrees} = {};
    
    if strcmp(clusterModule, 'jointstills')
        fprintf('Test data pt %d\n', test_point);
        for i = 1:ntrees
            [predict_node(i),forest{i}] = ClassifyData_JointStills(forest{i}, test_data, test_point, DMapEntry, JSSettings);
        end
    else
        for i = 1:ntrees
            [predict_node(i),forest{i}] = ClassifyData(forest{i}, test_data, test_point);
        end
    end

    for i = 1:ntrees
        %Gets the content at that leaf node
        content{i} = forest{i}.Node{predict_node(i),1};

        lset = (1:1:8);

        [memcnt{i}] = determine_membercount(content{i}, lset, labels);
        prob{i} = memcnt{i}/numel(content{i});
    end
    
    forest_count = zeros(1,8)';
    if ntrees == 1
        forest_count = prob{1};
    else
        for i = 1:ntrees

            forest_count = forest_count + prob{i};
        end
    end
    
    predict_labels = find(forest_count == max(forest_count));
    predict_label = predict_labels(1,1);
end

