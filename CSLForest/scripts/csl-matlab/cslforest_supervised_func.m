% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% Description: File contains routine calls for the core components in the algorithm
function [predict_label,Acc,forest] = cslforest_supervised_func (TrainH, TrainLabels, TrainDMap, ntrees, maxk, BF, FF, minSize, maxNodeLevel, TestH, TestLabels, TestDMap, clusterModule)
    % preallocating memory to the cells
    node_centroids{ntrees} = {};
    node_variances{ntrees} = {};
    feature_space{ntrees} = {};
    root{ntrees} = {};
    bagged_points = cell(ntrees, 1);
    
    JSSettings = GatherJointStillsSettings(maxk); %only used when clusterModule == 'jointstills'

    gcp;
    
    tic;
    %Supervised bagging
    for i = 1:ntrees        
        label_set = unique(TrainLabels);
        bagged_points{i} = []; %an array of randomly selected data points from the training dataset (almost equal representation of each category)
        for j = 1:length(label_set)
            idx = find(TrainLabels==label_set(j));
            idx = idx(randperm(length(idx)));
            n = ceil(BF * length(idx));
            bagged_points{i} = [bagged_points{i};idx(1:n)];
        end
    end

    %Supervised batchTrain
    for j = 1:ntrees
        warning off backtrace; %removes stacktraces from warnings
        [root{j},node_centroids{j},node_variances{j},feature_space{j}] = batchTrain_supervised(TrainH, TrainLabels, TrainDMap, bagged_points{j}, FF, node_centroids{j}, node_variances{j}, feature_space{j}, maxk, minSize, maxNodeLevel, JSSettings, clusterModule);
    end
    time = toc;
    fprintf('Matlab CSL RandomForest: TrainTime = %f\n', time);
    
    % Creating a structure for the forest
    forest = Node2Struct(root, node_centroids, node_variances, feature_space, ntrees);

    test_points = size(TestH,1);
    tic;
    for i = 1:test_points
        % Supervised classification
        [predict_label(i),forest] = label_posterior(forest, TestH(i,:), TestDMap{i}, TrainLabels, ntrees, i, JSSettings, clusterModule);
    end
    test = toc;
    fprintf('Matlab CSL RandomForest: TestTime = %f \n', test);

    CF = confusionmat(TestLabels, predict_label);
    diag  = trace(CF);
    Acc = (diag/numel(predict_label)) * 100;
    fprintf('Matlab CSL RandomForest: Accuracy = %f%%\n', Acc);
end


function [JointStillsSettings] = GatherJointStillsSettings (K)
    JointStillsSettings.PYR_LEVELS = 1;
    JointStillsSettings.FG_THRESH = 0.3;
    JointStillsSettings.LL_THRESH = 0.02; %0.02 works for segmented images %0.05 works for caltech 101 4 class and 10 class  as well as msrcv1
    JointStillsSettings.EM_MAX_IT = 20;
    JointStillsSettings.NSEEDS_EMINIT = 5000;
    JointStillsSettings.SIFTBorder = 3;
    JointStillsSettings.PYR_LEVELS = 1;
    JointStillsSettings.C = 0.05;
    JointStillsSettings.TOL_FAC = 0.01;
    JointStillsSettings.VOCAB_SIZE = 40;
    JointStillsSettings.K = K;
    JointStillsSettings.Win_Prior_Mean = [0.5 0.5];
    JointStillsSettings.Win_Prior_Variance = 0.00001*ones(1,2);
    JointStillsSettings.WinMode = 8;
end