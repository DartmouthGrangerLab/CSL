% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [TrainDMapIndices, TrainLabels, TestDMapIndices, TestLabels] = CreateTrainAndTestSets(Labels, N_CATS, fractionTrain)
    if ~exist('fractionTrain','var') || isempty(fractionTrain)
        fractionTrain = 0.5;
    end

    TrainDMapIndices = [];
    TrainLabels = [];
    TestDMapIndices = [];
    TestLabels = [];
    for k = 1:N_CATS
        CatIndices = find(Labels == k);
        TN = ceil(numel(CatIndices) * fractionTrain); %num test
        M = numel(CatIndices) - TN; %num train
        [RandIndices] = myrandperm(numel(CatIndices));
        CatIndices = CatIndices(RandIndices);
        TrainDMapIndices = vertcat(TrainDMapIndices, CatIndices(1:M));
        TrainLabels = vertcat(TrainLabels, Labels(CatIndices(1:M),:));
        
        UniqueTestCount = numel(CatIndices(M+1:end));
        if UniqueTestCount >= TN
            TestDMapIndices = vertcat(TestDMapIndices, CatIndices(M+1:M+TN));
            TestLabels = vertcat(TestLabels, Labels(CatIndices(M+1:M+TN),:));
        else
            TestDMapIndices = vertcat(TestDMapIndices, CatIndices(end-(TN-1):end));
            TestLabels = vertcat(TestLabels, Labels(CatIndices(end-(TN-1):end),:));
        end
    end
end

