% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [] = QuickRun (L1BagsPlusFile)
    global ROOT_DIRECTORY;
    global OutputPath; % at this point, this contains the full path from the top of the root folder through the folder for the run of demo.m
    %% ******************************************
    %user settings
    startK = 8; %starting size for K (branching factor)
    stepK = 10; %step size for K (branching factor)
    endK = 8;%40 %end size for K (branching factor) (multiple of stepK)
    numRuns = 10; %number of times to independently run CSL forest
    minSize = 7; %nodes with less than this number of data points in them will never spawn children (default = 5);
    maxNodeLevel = 99999; %hard depth limit for trees (default = 99999)
    numTrees = 100; %number of trees within a single run/forest (default = 100)
    BF = 0.6; %bagging fraction (default = .6)
    FF = 0.4; %feature fraction. percent of features randomly selected for classification at a given node. more features = slower.
    matlabClusterModule = 'kmeans'; %could be 'kmeans', 'gmm', or 'jointstills' once implemented
    fractionTest = 0.1; %fraction to split off for testing (1-fractionTest = # train) (default = .5)
    runMatlab = 1;
    runJava = 0;
    useImages = 1; %only set to 1 if running demo.m on image data
    %% ******************************************
    
    if strcmp(matlabClusterModule, 'jointstills')
        assert(FF == 0.2, 'FF must be 0.2 for jointstills');
        if minSize < 2 * endK
            minSize = 2 * endK;
            fprintf('minSize too small - switching to %d\n', minSize);
        end
    else
        if minSize < endK + 1
            minSize = endK + 1;
            fprintf('minSize too small - switching to %d\n', minSize);
        end
    end
 
    % unique string for this run of QuickRun
    UNIQUE_STRING = strcat('CSL_K_', num2str(endK), '_numRuns_', num2str(numRuns), '_minSize_', num2str(minSize), '_maxNodeLevel_', num2str(maxNodeLevel), '_', datestr(now, 'mmm_dd_yyyy_HH_MM_SS'));
    
    % make folder for all CSL output
    mkdir(OutputPath, UNIQUE_STRING);
    cslOutputFolder = strcat(OutputPath, UNIQUE_STRING);
    
    warning off backtrace; %removes stacktraces from warnings
    warning off MATLAB:structOnObject;
    warning off stats:kmeans:EmptyCluster;
    diary(strcat(cslOutputFolder, '/diary.txt'));
    
    gcp();
    
    %If running Java version, program will fail to add to java classpath on first run. 
    %Run program again using usedSavedData = 1 [in demo.m] to save time
    if runJava
        if isunix
            javaclasspath(strcat(ROOT_DIRECTORY, '/cslForest/csl-java/CSLForest.jar')); %ASSUMES the matlab current folder is "trunk"
        else
            javaclasspath(strcat(ROOT_DIRECTORY, '\cslForest\csl-java\CSLForest.jar')); %ASSUMES the matlab current folder is "trunk"
        end
        
        try
            import cslforest.*;
            pause(1);
            bt = BatchTrain();
        catch
            error('Addition of CSLForest java to the java classpath was too slow. Please re-run');
        end
    end

    load(L1BagsPlusFile); %loads L1Bags, Labels, DMap, ReferenceImgs, description, frontend, VOCAB_SIZE, N_VOCAB_PER_CAT, maxFilesPerCat, useSavedData, rstream, windows
    N_CATS = numel(unique(Labels)); %number of ground truth classes
    
    fprintf(strcat('Running CSL with dataset:', description, '\n'));

    H = L1Bags;
    Labels = Labels';
    %% split train and test
    for run = 1:numRuns
        [TrainHIndices{run},TrainLabels{run},TestHIndices{run},TestLabels{run}] = CreateTrainAndTestSets(Labels, N_CATS, fractionTest);
        if useImages
            TrainRefImgs{run} = ReferenceImgs(TrainHIndices{run}');
            TestRefImgs{run} = ReferenceImgs(TestHIndices{run}');
        end
        classSizes = hist(TrainLabels{run}, unique(TrainLabels{run}));
        
        %remove excess training points so that we have an equal number for each class
        for classNum = 1:numel(unique(TrainLabels{run}))
            if ~ismember(classNum, find(classSizes==min(classSizes))) 
                indices = find(TrainLabels{run}==classNum, classSizes(classNum) - min(classSizes), 'last');
                TrainLabels{run}(indices) = [];
                TrainHIndices{run}(indices) = [];
                if useImages
                    TrainRefImgs{run}(indices) = [];
                end
            end
        end
    end
    
    %% ******************************************
    java_Acc = zeros(numRuns, endK);
    mat_Acc = zeros(numRuns, endK);
    svm_Test_Acc = zeros(numRuns, 1);
    FP = [];
    FN = [];
    for run = 1:numRuns
        fprintf('BEGIN: Run %d\n', run); 
        TrainH = H(TrainHIndices{run}, :);
        TestH = H(TestHIndices{run}, :);
        if useImages
            TrainDMap = DMap(TrainHIndices{run});
            TestDMap = DMap(TestHIndices{run});
        end
        
        %% SVM
        svm_Test_Pred_Labels = cell(numRuns, 1);
        SVMFailed = 0;
        try
            svmOptions.MaxIter = 150000; %default = 15000 (increase to prevent crashes)
            svm_Test_Pred_Labels{run} = cosmo_classify_matlabsvm(TrainH, TrainLabels{run}(:), TestH, svmOptions);

            svm_Test_Acc(run) = sum(TestLabels{run} == svm_Test_Pred_Labels{run}) / size(TestLabels{run},1);

            fprintf('SVM Accuracy:%f.\n', svm_Test_Acc(run));

            CFMat = zeros(N_CATS, N_CATS);
            for Cnt = 1:numel(svm_Test_Pred_Labels{run})
                if svm_Test_Pred_Labels{run}(Cnt) ~= -1
                    CFMat(TestLabels{run}(Cnt), svm_Test_Pred_Labels{run}(Cnt)) = CFMat(TestLabels{run}(Cnt), svm_Test_Pred_Labels{run}(Cnt)) + 1;                    
                end
            end
            for i = 1:N_CATS
                %format is CFMat(ground truth, predicted)
                svm_TP(run,i) = CFMat(i,i);
                svm_FP(run,i) = sum(CFMat(:,i))-CFMat(i,i);
                svm_FN(run,i) = sum(CFMat(i,:))-CFMat(i,i);
                svm_TPRate(run,i) = 100 * svm_TP(run,i) / (svm_TP(run,i) + svm_FN(run,i));
                svm_FPRate(run,i) = 100 * svm_FP(run,i) / (sum(sum(CFMat(:,:)))-sum(CFMat(i,:))); %FP / (FP + TN)
                svm_FNRate(run,i) = 100 * svm_FN(run,i) / sum(CFMat(i,:)); %FN / (TP + FN)
                svm_Sensitivity(run,i) = 100 * CFMat(i,i) / sum(CFMat(i,:)); %TP / (TP + FN)
                fprintf('Class %d:         Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, svm_Sensitivity(run,i), svm_FPRate(run,i), svm_FP(run,i), svm_FNRate(run,i), svm_FN(run,i));
            end

            fprintf('---------------\n');
        catch
            warning('SVM failed to converge');
            SVMFailed = 1;
        end

        %% CSL
        for maxk = startK:stepK:endK
            fprintf('Branching factor of %d:\n', maxk);
            % unique string for this branching factor for this run
            k_run_unique_str = strcat('run_', num2str(run), '_maxk_', num2str(maxk));
            xmlFileName = strcat(k_run_unique_str, '_xmlResults', '.xml');
            
            %% Matlab
            %TODO: maxNodeLevel NOT implemented
            %TODO: FF not implemented for jointstills
            mat_PredObjLabels{run,maxk} = {};
            if runMatlab
                [mat_PredObjLabels{run,maxk},mat_Acc(run,maxk),forest] = cslforest_supervised_func(TrainH, TrainLabels{run}, TrainDMap, numTrees, maxk, BF, FF, minSize, maxNodeLevel, TestH, TestLabels{run}, TestDMap, matlabClusterModule);
                mat_PredObjLabels{run,maxk} = mat_PredObjLabels{run,maxk}';
                CFMat = confusionmat(TestLabels{run}, mat_PredObjLabels{run,maxk});
                for i = 1:N_CATS
                    %format is CFMat(ground truth, predicted)
                    TP(run,maxk,i) = CFMat(i,i);
                    FP(run,maxk,i) = sum(CFMat(:,i))-CFMat(i,i);
                    FN(run,maxk,i) = sum(CFMat(i,:))-CFMat(i,i);
                    TPRate(run,maxk,i) = 100 * TP(run,maxk,i) / (TP(run,maxk,i) + FN(run,maxk,i));
                    FPRate(run,maxk,i) = 100 * FP(run,maxk,i) / (sum(sum(CFMat(:,:)))-sum(CFMat(i,:))); %FP / (FP + TN)
                    FNRate(run,maxk,i) = 100 * FN(run,maxk,i) / sum(CFMat(i,:)); %FN / (TP + FN)
                    sensitivity(run,maxk,i) = 100 * CFMat(i,i) / sum(CFMat(i,:)); %TP / (TP + FN)
                    fprintf('Class %d:         Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, sensitivity(run,maxk,i), FPRate(run,maxk,i), FP(run,maxk,i), FNRate(run,maxk,i), FN(run,maxk,i));
                end
            end
            
            %% Java
            java_PredObjLabels{run,maxk} = [];
            if runJava
                tic;
                java_PredObjLabels{run,maxk} = bt.TrainAndTest(TrainH, TrainLabels{run}, numTrees, maxk, BF, FF, minSize, maxNodeLevel, strcat(cslOutputFolder, '/', xmlFileName), TestH);
                tocTime = toc;
                fprintf('Java CSL RandomForest: TotalTime = %f\n', tocTime);
                CFMat = confusionmat(TestLabels{run}, java_PredObjLabels{run,maxk});
                java_Acc(run,maxk) = 100 * sum(diag(CFMat))/sum(sum(CFMat));
                fprintf('Java CSL RandomForest: max_k = %d, Accuracy = %f%%.\n', maxk, java_Acc(run,maxk));
                for i = 1:N_CATS
                    %format is CFMat(ground truth, predicted)
                    TP(run,maxk,i) = CFMat(i,i);
                    FP(run,maxk,i) = sum(CFMat(:,i))-CFMat(i,i);
                    FN(run,maxk,i) = sum(CFMat(i,:))-CFMat(i,i);
                    TPRate(run,maxk,i) = 100 * TP(run,maxk,i) / (TP(run,maxk,i) + FN(run,maxk,i));
                    FPRate(run,maxk,i) = 100 * FP(run,maxk,i) / (sum(sum(CFMat(:,:)))-sum(CFMat(i,:))); %FP / (FP + TN)
                    FNRate(run,maxk,i) = 100 * FN(run,maxk,i) / sum(CFMat(i,:)); %FN / (TP + FN)
                    sensitivity(run,maxk,i) = 100 * CFMat(i,i) / sum(CFMat(i,:)); %TP / (TP + FN)
                    fprintf('Class %d:         Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, sensitivity(run,maxk,i), FPRate(run,maxk,i), FP(run,maxk,i), FNRate(run,maxk,i), FN(run,maxk,i));
                end
            end
            
            %% Output
            TrainDMapI = TrainHIndices{run}';
            TestDMapI = TestHIndices{run}';
            TrainL = TrainLabels{run};
            TestL = TestLabels{run};
            if useImages
                TrainRefI = TrainRefImgs{run};
                TestRefI = TestRefImgs{run};
            end
            MatAccuracy = mat_Acc(run,maxk);
            JavaAccuracy = java_Acc(run,maxk);
            SVMAccuracy = svm_Test_Acc(run);
            MatPredL = mat_PredObjLabels{run,maxk};
            JavaPredL = java_PredObjLabels{run,maxk};
            SVMPredL = svm_Test_Pred_Labels{run};
            if useImages
                save(strcat(cslOutputFolder, '/', strcat(k_run_unique_str, '.mat')), '-v7.3', ...
                    'run', ...
                    'maxk', ...
                    'VOCAB_SIZE', ...
                    'MatAccuracy', 'JavaAccuracy', 'SVMAccuracy', ...
                    'MatPredL', 'JavaPredL', 'SVMPredL', ...
                    'maxNodeLevel', ...
                    'TrainH', 'TrainDMap', 'TrainDMapI', 'TrainL', 'TrainRefI', ...
                    'TestH', 'TestDMap', 'TestDMapI', 'TestL', 'TestRefI', ...
                    'description', ...
                    'DMap', ...
                    'frontend', ...
                    'N_VOCAB_PER_CAT', ...
                    'filesPerCat', ...
                    'useSavedData', ...
                    'rstream', ...
                    'windows', ...
                    'ImgLinks', ...
                    'SIFTBorder');
                clear MatAccuracy MatPredL SVMPredL TrainDMapI TestDMapI TrainL TestL TrainRefI TestRefI;
            elseif ~SVMFailed
                save(strcat(cslOutputFolder, '/', strcat(k_run_unique_str, '.mat')), '-v7.3', ...
                    'run', ...
                    'maxk', ...
                    'VOCAB_SIZE', ...
                    'MatAccuracy', 'JavaAccuracy', 'SVMAccuracy', ...
                    'MatPredL', 'JavaPredL', 'SVMPredL', ...
                    'maxNodeLevel', ...
                    'TrainH', 'TrainDMapI', 'TrainL', ...
                    'TestH', 'TestDMapI', 'TestL');
                clear MatAccuracy MatPredL SVMPredL TrainDMapI TestDMapI TrainL TestL TrainRefI TestRefI;
            else
                save(strcat(cslOutputFolder, '/', strcat(k_run_unique_str, '.mat')), '-v7.3', ...
                    'run', ...
                    'maxk', ...
                    'VOCAB_SIZE', ...
                    'MatAccuracy', 'JavaAccuracy', ...
                    'MatPredL', 'JavaPredL', 'SVMPredL', ...
                    'maxNodeLevel', ...
                    'TrainH', 'TrainDMapI', 'TrainL', ...
                    'TestH', 'TestDMapI', 'TestL');
                clear MatAccuracy MatPredL SVMPredL TrainDMapI TestDMapI TrainL TestL TrainRefI TestRefI;
            end
            
            if runMatlab
                MislabledTestData.Labels = TestLabels{run};
                MislabledTestData.PredLabels = mat_PredObjLabels{run,maxk};
                MislabledTestData.kRunUniqueString = strcat(k_run_unique_str, '_matlab');
                MislabledTestData.run = run;
                MislabledTestData.maxk = maxk;
                if useImages
                    MislabledTestData.TestRefImgs = TestRefImgs{run};
                end
                save(strcat(cslOutputFolder, '/', strcat(MislabledTestData.kRunUniqueString, '_mislabeledtestdata.mat')), 'MislabledTestData');
            end
            
            if ~exist('forest','var')
                %CSLTreeHUGGER(strrep(xmlFileName, '.xml', '.mat'));
            else
                %CSLTreeHUGGER(strrep(xmlFileName, '.xml', '.mat'), forest);
                save(strcat(cslOutputFolder, '/'  , strcat(k_run_unique_str, '_forest.mat')), 'forest');
            end
            
            clear mex;
            fprintf('---------------\n');
        end
    end
    
    %% print summary info
    %profile viewer;
    mat_Acc = mat_Acc(:,startK:stepK:size(mat_Acc,2));
    java_Acc = java_Acc(:,startK:stepK:size(java_Acc,2));
    if numel(mat_Acc(mat_Acc ~= 0)) > 0
        acc = mat_Acc;
        fprintf('Displaying MATLAB CSL results.\n');
    else
        acc = java_Acc;
        fprintf('Displaying Java CSL results.\n');
    end
    
    if ~SVMFailed
        fprintf('svm accuracy:\n');
        disp(mean(svm_Test_Acc));
    else 
        fprintf('SVM failed\n');
    end
    
    mean_best_max_k = max(mean(acc, 1));
    stderr_mean_best_max_k = StdErr(max(acc,[],2));
    fprintf('best max_k across runs: %f +/- %f\n', mean_best_max_k, stderr_mean_best_max_k);
    fprintf('means across runs for each branching factor:\n');
    maxkmeans = mean(acc)';
    maxkmeans = maxkmeans(maxkmeans~=0);
    disp(maxkmeans);
    stderrmaxkmeans = StdErr(acc)';
    stderrmaxkmeans = stderrmaxkmeans(stderrmaxkmeans~=0);
    fprintf('std err of means across runs for each branching factor:\n');
    disp(stderrmaxkmeans);
    
    fprintf('CSL Calculations:\n'); 
    for maxk = startK:stepK:endK
        fprintf('Branching factor of %d:\n', maxk);
        for i = 1:N_CATS
            fprintf('Class %d (mean):        Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, mean(sensitivity(:, maxk, i)), mean(FPRate(:, maxk, i)), mean(FP(:, maxk, i)), mean(FNRate(:, maxk, i)), mean(FN(:, maxk, i)));
            fprintf('Class %d (max):         Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, max(sensitivity(:, maxk, i)), max(FPRate(:, maxk, i)), max(FP(:, maxk, i)), max(FNRate(:, maxk, i)), max(FN(:, maxk, i)));
            fprintf('Class %d (min):         Sensitivity = %f%%, FP rate = %f%% (%d), FN rate = %f%% (%d)\n', i, min(sensitivity(:, maxk, i)), min(FPRate(:, maxk, i)), min(FP(:, maxk, i)), min(FNRate(:, maxk, i)), min(FN(:, maxk, i)));
            fprintf('Class %d (stderr):      Sensitivity = %f%%, FP rate = %f%%, FN rate = %f%%\n', i, StdErr(sensitivity(:, maxk, i)), StdErr(FPRate(:, maxk, i)), StdErr(FNRate(:, maxk, i)));
        end
    end
    clear acc;
    
    %% plot ROC
    if N_CATS == 2
        CSLROC(false, TestLabels, svm_ROC, svm_TPRate, svm_FPRate, TPRate, FPRate, fullfile(cslOutputFolder, xmlFileName));
    end
    
    %% plot bar graph of mean accuracies for each branching factor
%     figure;
%     %x = startK:stepK:endK;
%     y = [svm_Mean_Acc maxkmeans];
%     bar(y);
    
    %% save workspace (except bt = cslforest.BatchTrain@3140828f because it's not serializable)
    save(fullfile(cslOutputFolder, 'csl_workspace.mat'), '-v7.3', '-regexp', '^(?!(bt)$).'); %save everything
    diary off;
end

function [stdErr] = StdErr (data)
    stdErr = std(data, 0, 1) / sqrt(length(data));
end

