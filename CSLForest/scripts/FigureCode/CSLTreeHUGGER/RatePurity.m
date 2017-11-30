% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [isLeaf, purity, pitPurity, members] = RatePurity (handleNum)
    global NODEPOINTERS;
    global TRAINLABELS;
    global TESTLABELS;
    global MEMBERTYPE;
    
    children = determine_children(NODEPOINTERS, handleNum);
    
    classList = BuildClassList(children);

    isLeaf = 1;
    classTallies = zeros(max(classList), 1);
    if strcmp(MEMBERTYPE, 'TRAINMEMBER')
        labelTruthTallies = zeros(numel(unique(TRAINLABELS)), 1); %assumes labels are sequential
        members = NODEPOINTERS.Node{handleNum, 1}';
    else %'TESTMEMBER'
        labelTruthTallies = zeros(numel(unique(TESTLABELS)), 1); %assumes labels are sequential
        members = NODEPOINTERS.Node{handleNum, 4}';
    end
    if numel(children) ~= 0
        isLeaf = 0;
    end
    memberCount = numel(members);
    for i = 1:numel(members)
        try
            classNum = classList(members(i)+1);
            classTallies(classNum) = classTallies(classNum) + 1;
        catch
            classNum = 0;
        end
        if strcmp(MEMBERTYPE, 'TRAINMEMBER')
            labelTruthTallies(TRAINLABELS(members(i))) = labelTruthTallies(TRAINLABELS(members(i))) + 1;
        else %'TESTMEMBER'
            labelTruthTallies(TESTLABELS(members(i))) = labelTruthTallies(TESTLABELS(members(i))) + 1;
        end
    end
    purity = max(classTallies) / memberCount;
    pitPurity = max(labelTruthTallies(1), memberCount-labelTruthTallies(1)) / memberCount;
end