% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [tree] = ParseTree (theNode)
    childNodes = theNode.getChildNodes;
    numChildren = childNodes.getLength;
    tree = struct;
    for i = 1:numChildren
        theChild = childNodes.item(i-1);
        name = char(theChild.getNodeName);
        switch name
            case 'NODE'
                [nodeRows, parentChildSets, nums] = ParseNode(theChild, 0);
                parentChildSets = parentChildSets(2:end,:);
                parents = zeros(size(parentChildSets, 1), 1);
                nodeRowsSorted = cell(max(parentChildSets(:,2)), 5);
                for i = 1:size(parentChildSets, 1)
                    nodeRowsSorted(nums(i),:) = nodeRows(i,:);
                    parents(parentChildSets(i,2)) = parentChildSets(i,1);
                end
                %parents = parents + 1;
                %parents = [0; parents];
            case 'NUM'
                
            otherwise
                continue;
        end
    end
    tree.Node = nodeRowsSorted;
    tree.Parent = parents;
end