% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
%% plot bar graph of mean accuracies for each branching factor
startK=4
endK=40
stepK=4
numRuns = 2;
subj = {'subj1CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_09_2015_15_24_39', 'subj2CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_04_2015_16_18_09', 'subj3CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_13_2015_17_12_15', 'subj4CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_16_2015_14_41_24', 'subj5CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_18_2015_09_46_13', 'subj6CSL_K_40_numRuns_2_minSize_41_maxNodeLevel_99999_Nov_20_2015_05_18_10'};
%Haxby = ['\CSLForest\Haxby\outputHaxby\',subj{idx},'/run_',num2str(run),'_maxk_',num2str(i),'.mat']
%caltech4 = ['\CSLForest\outputCaltech4\frontend-sift_VOCABSIZE-40_K-4_T-0_NEMSTARTS-1_VOCABPERCAT-4_filesPerCat-10-10-10-10\caltech-4Jan_20_2016_17_30_39\run_',num2str(run),'_maxk_',num2str(i),'.mat']

for idx = 1:numel(subj)
    SVMSumAcc = 0; MatSumAcc = 0;
    counter = 0;
    BranchAcc = [];
    for i = startK:stepK:endK
        for run = 1:numRuns
            load(['\CSLForest\Haxby\outputHaxby\',subj{idx},'/run_',num2str(run),'_maxk_',num2str(i),'.mat'], 'MatAccuracy', 'SVMAccuracy')
            SVMSumAcc = SVMSumAcc + SVMAccuracy*100;
            MatSumAcc = MatSumAcc + MatAccuracy;
        end
        MatMeanAcc = MatSumAcc / numRuns;
        BranchAcc = [BranchAcc, MatMeanAcc];
        MatSumAcc = 0;

        counter = counter + 1;

        disp('SVMSumAcc'); disp(SVMSumAcc);
        disp('MatSumAcc'); disp(MatSumAcc);
        %disp('SVMMeanAcc'); disp(SVMMeanAcc);
        disp('MatMeanAcc'); disp(MatMeanAcc);
        disp('BranchAcc'); disp(BranchAcc);
        disp('Counter'); disp(counter);
    end

    SVMMeanAcc = SVMSumAcc / (numRuns * counter);
    fprintf('SVM: Mean Accuracy:%f.\n', SVMMeanAcc);

    x = {};
    x{1} = 'SVM';
    branchF = startK:stepK:endK;
    for N = 1:numel(branchF)
        x{N+1} = int2str(branchF(N));
    end

    BranchAcc = BranchAcc.';
    y = [SVMMeanAcc; BranchAcc];
    disp(y);

    z = [];
    z(1) = y(1);
    for i = 2:numel(y)
        z(i) = 0;
    end

    figure;
    bar(1:11,z,'r')
    hold on;
    bar(2:numel(x),y(2:end))

    title(['Mean Accuracies for SVM and CSL Subject ',num2str(idx)]); %Caltech 4']); 
    set(gca,'XTickLabel',x(1:end))
    ylabel('Mean Accuracy (%)');
    ylim([0,100]);
end
