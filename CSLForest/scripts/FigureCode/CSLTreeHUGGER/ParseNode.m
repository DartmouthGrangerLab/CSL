% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [members, parentChildSets, nums] = ParseNode (theNode, parentNum)
    % Recurse over node children.
    members = cell(1,5);
    parentChildSets = zeros(1,2);
    nums = zeros(1,1);
    if theNode.hasChildNodes
        childNodes = theNode.getChildNodes;
        numChildNodes = childNodes.getLength;

        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            name = char(theChild.getNodeName);
            switch name
                case 'NUM'
                    temp = theChild.getChildNodes;
                    nums(1) = str2num(char(temp.item(0).getData))+1;
                case 'LEVEL'
                    
                case 'NUMCLUSTERS'
                    
                case 'FEATFRAC'
                    
                case 'SEPERABLETHRESH'
                    
                case 'QUALITY'
                    
                case 'MEMCNT'
                    
                case 'TRAINMEMBER'
                    temp = theChild.getChildNodes;
                    members{1,1} = [members{1,1}; str2num(char(temp.item(0).getData))+1];
                case 'TESTMEMBER'
                    temp = theChild.getChildNodes;
                    members{1,4} = [members{1,4}; str2num(char(temp.item(0).getData))+1];
                otherwise
                    continue;
            end

        end
        parentChildSets(1,:) = [parentNum, nums(1)];
        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            name = char(theChild.getNodeName);
            switch name
                case 'NODE'
                    [myChildren, childParents, childNums] = ParseNode(theChild, nums(1));
                    nums = [nums; childNums];
                    members = [members; myChildren];
                    parentChildSets = [parentChildSets; childParents];
                otherwise
                    continue;
            end
        end
    end
end