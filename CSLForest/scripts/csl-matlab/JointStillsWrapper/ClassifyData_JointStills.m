% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
%DESCRIPTION: Gives the label for the test data 
function [predict_node,tree] = ClassifyData_JointStills (tree, test_data, test_point, DMapEntry, JSSettings)    
    load rstream;
    Win_Prior_Mean = JSSettings.Win_Prior_Mean;
    Win_Prior_Variance = JSSettings.Win_Prior_Variance;
    MixCoeffs = ones(1, JSSettings.K, 1)/JSSettings.K; % uniform mixture coeffs

    InitWindows(1,:) = GetInitialWindows({DMapEntry}, JSSettings.WinMode);
    
    idx = 1;
    tree.Node{idx,4}(end + 1,1) = test_point;
    while (~determine_leaf(tree, idx))
        children = determine_children(tree, idx);
        
        for i = 1:length(children)
            means(i,:) = tree.Node{children(i),2};
            variances(i,:) = tree.Node{children(i),5};
        end

        predLabel = ForeGd_EM_CSL_Test({DMapEntry}, InitWindows, means, variances, MixCoeffs, JSSettings.VOCAB_SIZE, Win_Prior_Mean, Win_Prior_Variance, JSSettings.PYR_LEVELS, JSSettings.C, JSSettings.TOL_FAC);

        idx = children(predLabel);
        predict_node = idx;

        tree.Node{idx,4}(end + 1,1) = test_point;
    end
end

