% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% DESCRIPTION: Gives the label for the test data 
function [predict_node,tree] = ClassifyData(tree, test_data, test_point)
    idx = 1;
    tree.Node{idx,4}(end + 1,1) = test_point; %root
    while ~determine_leaf(tree, idx)
        children = determine_children(tree, idx);

        new_test  = test_data(1,tree.Node{children(1),3});

        dist = Inf;
        for i = 1:length(children)
            edist = norm(new_test - tree.Node{children(i),2});
            if (dist > edist)
                dist = edist;
                idx = children(i);
                predict_node = idx;
            end
        end
        tree.Node{idx,4}(end + 1,1) = test_point;
    end
end
